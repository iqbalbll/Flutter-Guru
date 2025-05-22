import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'home/home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  XFile? _image;
  int? userId;

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId'); // Simpan userId saat login
    });
  }

  Future<String?> fetchProfilePhotoUrl() async {
    if (userId == null) return null;
    final response = await http.get(
      Uri.parse('http://3.0.151.126/api/admin/penggunas/$userId'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final profilePic = data['data']['profile_picture'];
      return 'http://3.0.151.126/storage/$profilePic';
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchNamaDanNip() async {
    if (userId == null) return null;
    final response = await http.get(
      Uri.parse('http://3.0.151.126/api/admin/gurus'),
    );
    print('userId: $userId');
    print('API response: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['data'] is List) {
        // Cari guru dengan pengguna_id yang sesuai userId login
        final guru = data['data'].firstWhere(
          (item) => item['pengguna_id'] == userId,
          orElse: () => null,
        );
        if (guru != null) {
          return {
            'nama_lengkap': guru['nama_lengkap'],
            'nip': guru['nip'],
          };
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Container
              Container(
                constraints: BoxConstraints(maxWidth: screenWidth * 0.95),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(screenWidth * 0.08),
                    bottomRight: Radius.circular(screenWidth * 0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: Offset(screenWidth * 0.01, screenWidth * 0.01),
                      blurRadius: screenWidth * 0.08,
                      spreadRadius: -screenWidth * 0.03,
                    ),
                  ],
                ),
                padding: EdgeInsets.fromLTRB(
                  screenWidth * 0.06,
                  screenWidth * 0.1,
                  screenWidth * 0.06,
                  screenWidth * 0.06,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Tombol Back
                    Flexible(
                      flex: 1,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const HomePage()),
                          );
                        },
                        color: const Color(0xFF006181),
                      ),
                    ),
                    // Judul tengah
                    Flexible(
                      flex: 3,
                      child: Center(
                        child: Text(
                          'Profile Page',
                          style: TextStyle(
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    // Spacer kanan supaya title tetap di tengah
                    Flexible(
                      flex: 1,
                      child: Container(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Konten utama hanya foto profil
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FutureBuilder<String?>(
                        future: fetchProfilePhotoUrl(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                            return CircleAvatar(
                              radius: 100,
                              backgroundColor: Colors.grey[300],
                              child: const Icon(
                                Icons.person,
                                size: 100,
                                color: Colors.white,
                              ),
                            );
                          }
                          return CircleAvatar(
                            radius: 100,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: NetworkImage(snapshot.data!),
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      FutureBuilder<Map<String, dynamic>?>(
                        future: fetchNamaDanNip(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                            return const Text('Nama dan NIP tidak tersedia');
                          }
                          final namaLengkap = snapshot.data!['nama_lengkap'] ?? '-';
                          final nip = snapshot.data!['nip'] ?? '-';
                          return Column(
                            children: [
                              Text(
                                namaLengkap,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'NIP: $nip',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

