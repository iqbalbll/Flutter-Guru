import 'package:flutter/material.dart';
import 'package:guru/home/home_page.dart';
import 'package:guru/main_page.dart';
import 'package:guru/home/jadwal.dart';
import 'package:guru/presensi/presensi.dart';
import 'package:guru/profile.dart';
import 'package:guru/quiz/quiz.dart';

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
        '/jadwal': (context) => const JadwalWidget(),
        '/presensi' : (context) => const PresensiPage(), //ini adalah route presensi
        '/quiz' : (context) => const QuizPage(), //ini adalah route quiz
        '/profile' : (context) => const ProfilePage(), //ini adalah route profile
      },
    );
  }
}

