import 'package:flutter/material.dart';
import 'package:guru/home_page.dart';
import 'package:guru/main_page.dart';
import 'package:guru/jadwal.dart';
import 'package:guru/presensi.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const MainPage(),
        '/home' : (context) => const HomePage(), // GANTI KE MainPage
        '/jadwal': (context) => const JadwalPage(),
        '/presensi' : (context) => const PresensiPage(), //ini adalah route presensi
        // '/quiz' : (context) => const   ini adalah route quiz
      },
    );
  }
}

