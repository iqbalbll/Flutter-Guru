import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DetailPresensiPage extends StatefulWidget {
  final String kelas;
  final String mapel;

  const DetailPresensiPage({
    super.key,
    required this.kelas,
    required this.mapel,
  });

  @override
  State<DetailPresensiPage> createState() => _DetailPresensiPageState();
}

class _DetailPresensiPageState extends State<DetailPresensiPage> {
  bool isPresensiDibuka = false;
  String waktuText = '';
  bool isLoading = true;
  List<Map<String, dynamic>> allSiswa = [];
  List<Map<String, dynamic>> siswaHadir = [];
  List<Map<String, dynamic>> siswaTidakHadir = [];
  bool isLoadingSiswa = false;
  bool isCreatingAbsensi = false;
  int? currentAbsensiId;
  String? absensiCode; // Kode absensi untuk siswa

  @override
  void initState() {
    super.initState();
    fetchJadwal();
  }

  // Generate kode absensi unik
  String generateAbsensiCode() {
    final now = DateTime.now();
    return '${widget.kelas}${widget.mapel}${now.hour}${now.minute}${now.second}';
  }

  Future<void> fetchJadwal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final penggunaId = prefs.getInt('pengguna_id');

      print('Debug - Token: $token');
      print('Debug - Pengguna ID: $penggunaId');
      print('Debug - Selected Kelas: ${widget.kelas}');
      print('Debug - Selected Mapel: ${widget.mapel}');

      if (token == null || penggunaId == null) {
        setState(() {
          waktuText = 'User belum login';
          isLoading = false;
        });
        return;
      }

      // Get guru data
      final guruResponse = await http.get(
        Uri.parse('http://3.0.151.126/api/admin/guru'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (guruResponse.statusCode != 200) {
        setState(() {
          waktuText = 'Gagal mengambil data guru';
          isLoading = false;
        });
        return;
      }

      final guruData = json.decode(guruResponse.body)['data'] as List;
      final guru = guruData.firstWhere(
        (item) => item['pengguna_id'] == penggunaId,
        orElse: () => null,
      );

      if (guru == null) {
        setState(() {
          waktuText = 'Data guru tidak ditemukan';
          isLoading = false;
        });
        return;
      }

      final guruId = guru['id'];
      print('Debug - Guru ID: $guruId');

      // Get jadwal data
      final jadwalResponse = await http.get(
        Uri.parse('http://3.0.151.126/api/admin/jadwal-pelajarans'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (jadwalResponse.statusCode == 200) {
        final data = json.decode(jadwalResponse.body)['data'] as List;
        print('Debug - Jadwal Data: $data');

        final jadwal = data.firstWhere((item) {
          return item['guru_id'] == guruId &&
              item['kelas_id'].toString() == widget.kelas &&
              item['mapel_id'].toString() == widget.mapel;
        }, orElse: () => null);

        if (jadwal != null) {
          final jamMulai = jadwal['jam_mulai'].toString().substring(0, 5);
          final jamSelesai = jadwal['jam_selesai'].toString().substring(0, 5);
          setState(() {
            waktuText = '$jamMulai - $jamSelesai';
            isLoading = false;
          });
        } else {
          setState(() {
            waktuText = 'Jadwal tidak ditemukan';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          waktuText = 'Gagal mengambil jadwal';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Debug - Error: $e');
      setState(() {
        waktuText = 'Terjadi error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchSiswaByKelas() async {
    setState(() {
      isLoadingSiswa = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      print('Debug - Fetching siswa for kelas_id: ${widget.kelas}');

      final response = await http.get(
        Uri.parse('http://3.0.151.126/api/admin/siswa'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> siswaList = data['data'];

        // Filter siswa berdasarkan kelas_id
        final List<Map<String, dynamic>> siswaKelas = siswaList
            .where((siswa) => siswa['kelas_id'].toString() == widget.kelas)
            .map((siswa) => Map<String, dynamic>.from(siswa))
            .toList();

        print('Debug - Filtered siswa for kelas ${widget.kelas}: $siswaKelas');

        setState(() {
          allSiswa = siswaKelas;
          siswaTidakHadir = List.from(siswaKelas);
          siswaHadir = [];
          isLoadingSiswa = false;
        });

        // Start polling untuk update real-time
        startPollingAbsensi();
      } else {
        print('Error fetching siswa: ${response.statusCode}');
        setState(() {
          isLoadingSiswa = false;
        });
      }
    } catch (e) {
      print('Error fetching siswa: $e');
      setState(() {
        isLoadingSiswa = false;
      });
    }
  }

  Future<void> createAbsensi() async {
    setState(() {
      isCreatingAbsensi = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final penggunaId = prefs.getInt('pengguna_id');

      if (token == null || penggunaId == null) {
        throw Exception('Token atau pengguna ID tidak ditemukan');
      }

      // Get guru_id
      final guruResponse = await http.get(
        Uri.parse('http://3.0.151.126/api/admin/guru'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (guruResponse.statusCode != 200) {
        throw Exception('Gagal mengambil data guru');
      }

      final guruData = json.decode(guruResponse.body)['data'] as List;
      final guru = guruData.firstWhere(
        (item) => item['pengguna_id'] == penggunaId,
        orElse: () => null,
      );

      if (guru == null) {
        throw Exception('Data guru tidak ditemukan');
      }

      final guruId = guru['id'];

      // Generate kode absensi unik
      absensiCode = generateAbsensiCode();

      // Get current date and time
      final now = DateTime.now();
      final tanggal = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final waktu = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

      // Create absensi data
      final absensiData = {
        'guru_id': guruId,
        'kelas_id': int.parse(widget.kelas),
        'mapel_id': int.parse(widget.mapel),
        'tanggal': tanggal,
        'waktu_buka': waktu,
        'kode_absensi': absensiCode, // Kode untuk siswa
        'status': 'aktif', // Status aktif agar bisa diakses siswa
      };

      print('Debug - Creating absensi with data: $absensiData');

      final response = await http.post(
        Uri.parse('http://3.0.151.126/api/admin/absensis'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(absensiData),
      );

      print('Debug - Absensi response status: ${response.statusCode}');
      print('Debug - Absensi response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['data'] != null && responseData['data']['id'] != null) {
          currentAbsensiId = responseData['data']['id'];
          print('Debug - Created absensi with ID: $currentAbsensiId');
        }

        setState(() {
          isCreatingAbsensi = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Presensi berhasil dibuka\nKode: $absensiCode'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Fetch siswa data after creating absensi
        await fetchSiswaByKelas();
      } else {
        throw Exception('Gagal membuat absensi: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating absensi: $e');
      setState(() {
        isCreatingAbsensi = false;
        isPresensiDibuka = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuka presensi: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> closeAbsensi() async {
    if (currentAbsensiId == null) {
      setState(() {
        isPresensiDibuka = false;
        allSiswa = [];
        siswaHadir = [];
        siswaTidakHadir = [];
        currentAbsensiId = null;
        absensiCode = null;
      });
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final now = DateTime.now();
      final waktuTutup = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

      final updateData = {
        'waktu_tutup': waktuTutup,
        'status': 'ditutup', // Status ditutup agar tidak bisa diakses siswa lagi
      };

      final response = await http.put(
        Uri.parse('http://3.0.151.126/api/admin/absensis/$currentAbsensiId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(updateData),
      );

      print('Debug - Close absensi response: ${response.statusCode}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Presensi berhasil ditutup'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error closing absensi: $e');
    } finally {
      setState(() {
        isPresensiDibuka = false;
        allSiswa = [];
        siswaHadir = [];
        siswaTidakHadir = [];
        currentAbsensiId = null;
        absensiCode = null;
      });
    }
  }

  // Polling untuk mendapatkan update real-time dari absensi siswa
  Future<void> startPollingAbsensi() async {
    if (currentAbsensiId == null || !isPresensiDibuka) return;

    Future.delayed(const Duration(seconds: 5), () async {
      if (currentAbsensiId != null && isPresensiDibuka) {
        await checkAbsensiUpdates();
        startPollingAbsensi(); // Continue polling
      }
    });
  }

  Future<void> checkAbsensiUpdates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Get detail absensi dan daftar siswa yang sudah absen
      final response = await http.get(
        Uri.parse('http://3.0.151.126/api/admin/absensis/$currentAbsensiId/detail'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> detailAbsensi = data['data']['detail_absensi'] ?? [];

        // Update daftar siswa hadir berdasarkan data dari server
        List<Map<String, dynamic>> newSiswaHadir = [];
        List<Map<String, dynamic>> newSiswaTidakHadir = List.from(allSiswa);

        for (var detail in detailAbsensi) {
          final siswaId = detail['siswa_id'];
          final siswa = allSiswa.firstWhere(
            (s) => s['id'] == siswaId,
            orElse: () => {},
          );

          if (siswa.isNotEmpty) {
            newSiswaHadir.add(siswa);
            newSiswaTidakHadir.removeWhere((s) => s['id'] == siswaId);
          }
        }

        setState(() {
          siswaHadir = newSiswaHadir;
          siswaTidakHadir = newSiswaTidakHadir;
        });
      }
    } catch (e) {
      print('Error checking absensi updates: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background atas
          Container(
            height: 150,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF71E7FF), Color(0xFF008EBD)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 30,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                        color: const Color(0xFF006181),
                      ),
                      const Spacer(),
                      const Text(
                        'PRESENSI',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006181),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 20,
                          offset: Offset(-2, -2),
                        ),
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 30,
                          offset: Offset(2, 2),
                          spreadRadius: -11,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // Box informasi mapel
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  widget.mapel,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              isLoading
                                  ? const CircularProgressIndicator()
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Waktu    : $waktuText'),
                                        Text('Kelas    : ${widget.kelas}'),
                                        if (isPresensiDibuka && absensiCode != null)
                                          Container(
                                            margin: const EdgeInsets.only(top: 8),
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.blue.shade200),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Kode Absensi untuk Siswa:',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  absensiCode!,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: isCreatingAbsensi || isPresensiDibuka
                                        ? null
                                        : () async {
                                            setState(() {
                                              isPresensiDibuka = true;
                                            });
                                            await createAbsensi();
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.cyan,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: isCreatingAbsensi
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Text('Buka Presensi'),
                                  ),
                                  ElevatedButton(
                                    onPressed: isPresensiDibuka ? closeAbsensi : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Tutup Presensi'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Tampilkan data siswa jika presensi dibuka
                        if (isPresensiDibuka && !isCreatingAbsensi) ...[
                          Expanded(
                            child: Column(
                              children: [
                                // Statistics
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            'Total Siswa',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          Text(
                                            '${allSiswa.length}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            'Hadir',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          Text(
                                            '${siswaHadir.length}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            'Belum Absen',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          Text(
                                            '${siswaTidakHadir.length}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Daftar Siswa yang sudah absen
                                if (siswaHadir.isNotEmpty) ...[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Sudah Absen',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.green,
                                        ),
                                      ),
                                      Text(
                                        '${siswaHadir.length} siswa',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 120,
                                    child: ListView.builder(
                                      itemCount: siswaHadir.length,
                                      itemBuilder: (context, index) {
                                        final siswa = siswaHadir[index];
                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 4),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: Colors.green.shade200),
                                          ),
                                          child: Row(
                                            children: [
                                              const CircleAvatar(
                                                backgroundColor: Colors.green,
                                                radius: 12,
                                                child: Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  siswa['nama'] ?? 'Nama tidak tersedia',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // Daftar Siswa Belum Absen
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Belum Absen',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.red,
                                      ),
                                    ),
                                    Text(
                                      '${siswaTidakHadir.length} siswa',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                Expanded(
                                  child: isLoadingSiswa
                                      ? const Center(child: CircularProgressIndicator())
                                      : siswaTidakHadir.isEmpty
                                          ? Container(
                                              padding: const EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade50,
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: Colors.green.shade200),
                                              ),
                                              child: const Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.check_circle,
                                                      color: Colors.green,
                                                      size: 48,
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      'Semua siswa sudah absen!',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : ListView.builder(
                                              itemCount: siswaTidakHadir.length,
                                              itemBuilder: (context, index) {
                                                final siswa = siswaTidakHadir[index];
                                                return Container(
                                                  margin: const EdgeInsets.only(bottom: 8),
                                                  padding: const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red.shade50,
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: Colors.red.shade200),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      CircleAvatar(
                                                        backgroundColor: Colors.red.shade100,
                                                        child: Text(
                                                          '${index + 1}',
                                                          style: const TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              siswa['nama'] ?? 'Nama tidak tersedia',
                                                              style: const TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            Text(
                                                              'NISN: ${siswa['nisn'] ?? '-'}',
                                                              style: TextStyle(
                                                                color: Colors.grey.shade600,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const Icon(
                                                        Icons.hourglass_empty,
                                                        color: Colors.orange,
                                                        size: 20,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                ),
                              ],
                            ),
                          ),
                        ] else if (isCreatingAbsensi) ...[
                          // Loading state
                          const Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text(
                                    'Membuka presensi...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ] else ...[
                          // Default state
                          const Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.assignment_outlined,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Buka presensi untuk memulai\nabsensi siswa',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
