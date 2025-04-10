import 'package:flutter/material.dart';
import 'package:guru/login_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFD27D),
              Color(0xFF4CA6A8),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView( // Tambahkan ini
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/logo2.png", width: 150),
                SizedBox(height: 20),
                Text(
                  "Selamat Datang!",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF006181),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Di PancaLearn SMPN 5 Lamongan.",
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF006181),
                  ),
                ),
                SizedBox(height: 30),
                Image.asset("assets/images/logo1.png", width: 318),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF71E7FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 23, vertical: 15),
                    child: Text(
                      "Masuk untuk melanjutkan",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF006181),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
