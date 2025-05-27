import 'package:flutter/material.dart';
import 'package:guru/presensi/detail_presensi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PresensiPage extends StatefulWidget {
  const PresensiPage({super.key});

  @override
  State<PresensiPage> createState() => _PresensiPageState();
}

class _PresensiPageState extends State<PresensiPage> {
  String? selectedKelas;
  String? selectedMapel;
  bool isLoading = true;
  
  // Data yang akan difilter berdasarkan guru
  List<String> listKelas = [];
  List<String> listMapel = [];
  Map<String, List<String>> mapelPerKelas = {};
  
  // Data guru dan jadwal
  Map<String, dynamic>? currentGuru;
  List<Map<String, dynamic>> jadwalGuru = [];
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadDataGuru();
  }

  // Fungsi untuk mengambil data login user dan data guru
  Future<void> _loadDataGuru() async {
    try {
      setState(() {
        isLoading = true;
      });

      // 1. Ambil userId dari SharedPreferences (data login)
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getInt('userId'); // Sesuaikan dengan format yang digunakan di login
      
      if (userId == null) {
        _showError('User tidak ditemukan. Silakan login kembali.');
        return;
      }

      print('Loaded userId from SharedPreferences: $userId');

      // 2. Ambil data guru berdasarkan userId
      await _getDataGuru();
      
      // 3. Ambil jadwal berdasarkan guru_id
      if (currentGuru != null) {
        await _getJadwalGuru(currentGuru!['id']);
      }

    } catch (e) {
      _showError('Gagal memuat data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fungsi untuk mengambil data guru berdasarkan userId dari API
  Future<void> _getDataGuru() async {
    try {
      print('Fetching guru data for userId: $userId');
      
      final response = await http.get(
        Uri.parse('http://3.0.151.126/api/admin/gurus'),
      );
      
      if (response.statusCode == 200) {
        final guruData = json.decode(response.body);
        print('Guru data response: $guruData');
        
        // Cari guru dengan pengguna_id yang sesuai
        final guru = guruData['data'].firstWhere(
          (item) => item['pengguna_id'] == userId,
          orElse: () => null,
        );
        
        print('Found guru: $guru');
        
        if (guru != null) {
          currentGuru = guru;
        } else {
          throw Exception('Data guru tidak ditemukan untuk userId: $userId');
        }
      } else {
        throw Exception('Gagal mengambil data guru: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching guru data: $e');
      throw e;
    }
  }

  // Fungsi untuk mengambil jadwal berdasarkan guru_id dari API
  Future<void> _getJadwalGuru(int guruId) async {
    try {
      print('Fetching jadwal for guruId: $guruId');
      
      // Ambil data jadwal, mata pelajaran, dan kelas secara bersamaan
      final responses = await Future.wait([
        http.get(Uri.parse('http://3.0.151.126/api/admin/jadwal-pelajarans')),
        http.get(Uri.parse('http://3.0.151.126/api/admin/mata-pelajarans')),
        http.get(Uri.parse('http://3.0.151.126/api/admin/kelas')),
      ]);
      
      if (responses.every((response) => response.statusCode == 200)) {
        final jadwalData = json.decode(responses[0].body);
        final mapelData = json.decode(responses[1].body);
        final kelasData = json.decode(responses[2].body);
        
        print('Jadwal data response: ${jadwalData['data'].length} items');
        
        // Buat map untuk lookup mata pelajaran dan kelas
        Map<int, String> mapelLookup = {};
        Map<int, String> kelasLookup = {};
        
        for (var mapel in mapelData['data']) {
          mapelLookup[mapel['id']] = mapel['nama'] ?? mapel['nama_mapel'] ?? 'Unknown';
        }
        
        for (var kelas in kelasData['data']) {
          kelasLookup[kelas['id']] = kelas['nama'] ?? kelas['nama_kelas'] ?? 'Unknown';
        }
        
        // Filter jadwal berdasarkan guru_id dan convert ke format yang dibutuhkan
        jadwalGuru = [];
        for (var jadwal in jadwalData['data']) {
          if (jadwal['guru_id'] == guruId) {
            final mataPelajaran = mapelLookup[jadwal['mapel_id']] ?? 'Mata Pelajaran Tidak Diketahui';
            final namaKelas = kelasLookup[jadwal['kelas_id']] ?? 'Kelas Tidak Diketahui';
            
            jadwalGuru.add({
              'jadwal_id': jadwal['id'],
              'guru_id': jadwal['guru_id'],
              'kelas': namaKelas,
              'mata_pelajaran': mataPelajaran,
              'hari': jadwal['hari'],
              'jam_mulai': jadwal['jam_mulai'],
              'jam_selesai': jadwal['jam_selesai'],
            });
          }
        }
        
        print('Found ${jadwalGuru.length} jadwal for guru');
        
        // Proses data untuk dropdown
        _processJadwalData();
      } else {
        throw Exception('Gagal mengambil data jadwal');
      }
    } catch (e) {
      print('Error fetching jadwal: $e');
      throw e;
    }
  }

  // Fungsi untuk memproses data jadwal menjadi list kelas dan mapel
  void _processJadwalData() {
    Set<String> kelasSet = {};
    Map<String, Set<String>> mapelPerKelasTemp = {};
    
    for (var jadwal in jadwalGuru) {
      String kelas = jadwal['kelas'];
      String mapel = jadwal['mata_pelajaran'];
      
      kelasSet.add(kelas);
      
      if (!mapelPerKelasTemp.containsKey(kelas)) {
        mapelPerKelasTemp[kelas] = {};
      }
      mapelPerKelasTemp[kelas]!.add(mapel);
    }
    
    // Convert ke format yang dibutuhkan
    listKelas = kelasSet.toList()..sort();
    mapelPerKelas = {};
    
    mapelPerKelasTemp.forEach((kelas, mapelSet) {
      mapelPerKelas[kelas] = mapelSet.toList()..sort();
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background atas
          Container(
            height: 180,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF71E7FF), Color(0xFF008EBD)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // SafeArea untuk isi halaman
          SafeArea(
            child: Column(
              children: [
                // AppBar sederhana
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 35),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                        color: const Color(0xFF006181),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'PRESENSI',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF006181),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Container Putih dengan Box Shadow
                Expanded(
                  child: Container(
                    width: double.infinity,
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
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: isLoading 
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Info Guru - hanya tampil jika currentGuru tidak null dan memiliki nama
                              if (currentGuru != null && currentGuru!['nama'] != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.blue.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.person, color: Colors.blue.shade600),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Guru: ${currentGuru!['nama']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],

                              // Dropdown Kelas
                              const Text(
                                'Kelas',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              buildDropdown(
                                value: selectedKelas,
                                hint: "Pilih kelas",
                                items: listKelas,
                                onChanged: (value) {
                                  setState(() {
                                    selectedKelas = value;
                                    selectedMapel = null;
                                    // Update list mapel berdasarkan kelas yang dipilih
                                    listMapel = value != null ? (mapelPerKelas[value] ?? []) : [];
                                  });
                                },
                              ),
                              const SizedBox(height: 20),

                              // Dropdown Mapel
                              const Text(
                                'Mapel',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              buildDropdown(
                                value: selectedMapel,
                                hint: selectedKelas == null 
                                  ? "Pilih kelas terlebih dahulu"
                                  : "Pilih mapel",
                                items: listMapel,
                                onChanged: selectedKelas == null 
                                  ? null 
                                  : (value) {
                                      setState(() {
                                        selectedMapel = value;
                                      });
                                    },
                              ),
                              const SizedBox(height: 30),

                              // Tombol NEXT
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    elevation: 6,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    shadowColor: Colors.black.withOpacity(0.3),
                                  ),
                                  onPressed: () {
                                    if (selectedKelas == null || selectedMapel == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Harap pilih kelas dan mapel!')),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailPresensiPage(
                                            kelas: selectedKelas!,
                                            mapel: selectedMapel!,
                                          ),
                                        )
                                      );
                                    }
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                    child: Text(
                                      'NEXT',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
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

  Widget buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required void Function(String?)? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: onChanged == null ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0x3F000000),
            blurRadius: 20,
            offset: const Offset(-2, -2),
          ),
          BoxShadow(
            color: const Color(0x3F000000),
            blurRadius: 30,
            offset: const Offset(2, 2),
            spreadRadius: -11,
          ),
        ],
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(
          hint,
          style: TextStyle(
            color: onChanged == null ? Colors.grey : Colors.black54,
          ),
        ),
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(
          Icons.arrow_drop_down_sharp,
          color: onChanged == null ? Colors.grey : Colors.black54,
        ),
        onChanged: onChanged,
        items: items
            .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
      ),
    );
  }
}
