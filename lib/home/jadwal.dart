import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

class JadwalWidget extends StatefulWidget {
  const JadwalWidget({Key? key}) : super(key: key);

  @override
  State<JadwalWidget> createState() => _JadwalWidgetState();
}

class _JadwalWidgetState extends State<JadwalWidget> {
  int? userId;
  Map<String, List<Map<String, dynamic>>> jadwalPerHari = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    print('Loaded userId from SharedPreferences: $userId');
    
    if (userId != null) {
      await fetchJadwalGuru();
    } else {
      print('No userId found in SharedPreferences');
    }
    
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchJadwalGuru() async {
    try {
      print('Fetching guru data for userId: $userId');
      // 1. Ambil data guru berdasarkan userId
      final guruResponse = await http.get(
        Uri.parse('http://3.0.151.126/api/admin/gurus'),
      );
      
      if (guruResponse.statusCode == 200) {
        final guruData = json.decode(guruResponse.body);
        print('Guru data response: $guruData');
        
        // Cari guru dengan pengguna_id yang sesuai
        final guru = guruData['data'].firstWhere(
          (item) => item['pengguna_id'] == userId,
          orElse: () => null,
        );
        
        print('Found guru: $guru');
        
        if (guru != null) {
          final guruId = guru['id'];
          print('Guru ID: $guruId');
          
          // 2. Ambil jadwal berdasarkan guru_id
          await fetchJadwalByGuruId(guruId);
        } else {
          print('No guru found for userId: $userId');
        }
      } else {
        print('Failed to fetch guru data: ${guruResponse.statusCode}');
      }
    } catch (e) {
      print('Error fetching jadwal: $e');
    }
  }

  Future<void> fetchJadwalByGuruId(int guruId) async {
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
        print('Sample jadwal: ${jadwalData['data'].isNotEmpty ? jadwalData['data'][0] : 'No data'}');
        
        // Buat map untuk lookup mata pelajaran dan kelas
        Map<int, String> mapelLookup = {};
        Map<int, String> kelasLookup = {};
        
        for (var mapel in mapelData['data']) {
          mapelLookup[mapel['id']] = mapel['nama'] ?? mapel['nama_mapel'] ?? 'Unknown';
        }
        
        for (var kelas in kelasData['data']) {
          kelasLookup[kelas['id']] = kelas['nama'] ?? kelas['nama_kelas'] ?? 'Unknown';
        }
        
        Map<String, List<Map<String, dynamic>>> tempJadwal = {
          'Senin': [],
          'Selasa': [],
          'Rabu': [],
          'Kamis': [],
          "Jum'at": [],
          'Sabtu': [],
        };
        
        // Map hari dari API (lowercase) ke format tampilan
        Map<String, String> hariMap = {
          'senin': 'Senin',
          'selasa': 'Selasa',
          'rabu': 'Rabu',
          'kamis': 'Kamis',
          'jumat': "Jum'at",
          'sabtu': 'Sabtu',
        };
        
        // Filter jadwal berdasarkan guru_id
        int matchCount = 0;
        for (var jadwal in jadwalData['data']) {
          print('Checking jadwal: guru_id=${jadwal['guru_id']}, looking for=$guruId');
          
          if (jadwal['guru_id'] == guruId) {
            matchCount++;
            final hariFromApi = jadwal['hari'].toString().toLowerCase();
            final hari = hariMap[hariFromApi];
            
            print('Found matching jadwal for hari: $hariFromApi -> $hari');
            
            if (hari != null && tempJadwal.containsKey(hari)) {
              final mataPelajaran = mapelLookup[jadwal['mapel_id']] ?? 'Mata Pelajaran Tidak Diketahui';
              final namaKelas = kelasLookup[jadwal['kelas_id']] ?? 'Kelas Tidak Diketahui';
              
              tempJadwal[hari]!.add({
                'jam_mulai': jadwal['jam_mulai'],
                'jam_selesai': jadwal['jam_selesai'],
                'mata_pelajaran': mataPelajaran,
                'kelas': namaKelas,
              });
            }
          }
        }
        
        print('Total matching jadwal found: $matchCount');
        print('Final tempJadwal: $tempJadwal');
        
        // Urutkan jadwal berdasarkan jam_mulai
        tempJadwal.forEach((hari, jadwalList) {
          jadwalList.sort((a, b) => a['jam_mulai'].compareTo(b['jam_mulai']));
        });
        
        setState(() {
          jadwalPerHari = tempJadwal;
        });
      } else {
        print('Failed to fetch some data:');
        print('Jadwal: ${responses[0].statusCode}');
        print('Mapel: ${responses[1].statusCode}');
        print('Kelas: ${responses[2].statusCode}');
      }
    } catch (e) {
      print('Error fetching jadwal by guru ID: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header container atas
              Container(
                width: double.infinity, // Memenuhi lebar layar
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(screenWidth * 0.08),
                    bottomRight: Radius.circular(screenWidth * 0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: Offset(screenWidth * 0.01, screenWidth * 0.01),
                      blurRadius: screenWidth * 0.08,
                      spreadRadius: -screenWidth * 0.03,
                    ),
                  ],
                ),
                padding: EdgeInsets.fromLTRB(
                  screenWidth * 0.06,
                  screenWidth * 0.06,
                  screenWidth * 0.06,
                  screenWidth * 0.1,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon keluar + teks
                    Flexible(
                      flex: 1,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () {
                              print("Menuju halaman Home...");
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const HomePage()),
                              );
                            },
                            color: const Color(0xFF006181),
                          ),
                          SizedBox(height: screenWidth * 0.01),
                        ],
                      ),
                    ),

                    SizedBox(width: screenWidth * 0.05),

                    // Teks Judul Jadwal
                    Flexible(
                      flex: 3,
                      child: Text(
                        'Jadwal',
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          color: const Color(0xFF006181),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    const Spacer(),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Days Grid Section
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02), // Kurangi padding horizontal
                  child: Column(
                    children: [
                      _buildDayRow('Senin', screenWidth),
                      const SizedBox(height: 23),
                      _buildDayRow('Selasa', screenWidth),
                      const SizedBox(height: 23),
                      _buildDayRow('Rabu', screenWidth),
                      const SizedBox(height: 23),
                      _buildDayRow('Kamis', screenWidth),
                      const SizedBox(height: 23),
                      _buildDayRow("Jum'at", screenWidth),
                      const SizedBox(height: 30),
                      _buildDayRow('Sabtu', screenWidth),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayRow(String day, double screenWidth) {
    return _buildDayCard(day, screenWidth);
  }

  Widget _buildDayCard(String day, double screenWidth) {
    final jadwalHari = jadwalPerHari[day] ?? [];
    
    return Container(
      width: double.infinity, // Memenuhi lebar layar
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01), // Kurangi margin
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(screenWidth * 0.08),
          bottomLeft: Radius.circular(screenWidth * 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(2, 2),
            blurRadius: 30,
            spreadRadius: -11,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05, // Tambah padding dalam
          vertical: screenWidth * 0.04,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              day,
              style: TextStyle(
                fontSize: screenWidth * 0.05, // Perbesar font
                color: const Color(0xFF006181),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 15),
            if (jadwalHari.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.08),
                child: Center( // Center text "Tidak ada jadwal"
                  child: Text(
                    'Tidak ada jadwal',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
          ...jadwalHari.map((jadwal) => Container(
            width: double.infinity, // Memenuhi lebar container
            margin: const EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(screenWidth * 0.03), // Padding responsif
            decoration: BoxDecoration(
              color: const Color(0xFF71E7FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF006181).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${jadwal['jam_mulai']} - ${jadwal['jam_selesai']}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035, // Perbesar font
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF006181),
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                Text(
                  jadwal['mata_pelajaran'],
                  style: TextStyle(
                    fontSize: screenWidth * 0.04, // Perbesar font
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: screenWidth * 0.005),
                Text(
                  'Kelas: ${jadwal['kelas']}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035, // Perbesar font
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    ),
  );
}
}