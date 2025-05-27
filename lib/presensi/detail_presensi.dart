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

  @override
  void initState() {
    super.initState();
    fetchJadwal();
  }

  Future<void> fetchJadwal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Get guru_id from pengguna_id
      final penggunaId = prefs.getInt('pengguna_id');

      // Debug prints
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

      // First, get guru data to get guru_id
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

      // Now get jadwal data
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
          print('Checking jadwal item: $item');
          print(
            'Comparing with: guruId=$guruId, kelas=${widget.kelas}, mapel=${widget.mapel}',
          );

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

  void togglePresensi() {
    setState(() {
      isPresensiDibuka = !isPresensiDibuka;
    });
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
                      const SizedBox(
                        width: 48,
                      ), // Untuk keseimbangan IconButton
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
                                  : //Text('Waktu    : $waktuText'),
                              Text('Kelas    : ${widget.kelas}'),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        isPresensiDibuka = true;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.cyan,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Buka Presensi'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        isPresensiDibuka = false;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.cyan,
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

                        // History presensi
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Hadir',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Icon(Icons.refresh, size: 18),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          height: 80,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.cyan,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        const Text(
                          'Tidak Hadir',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          height: 80,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.cyan,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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
