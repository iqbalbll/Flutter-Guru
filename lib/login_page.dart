import 'package:flutter/material.dart';
import 'package:guru/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Gunakan Stack agar Avatar bisa masuk ke dalam Container biru
            Stack(
              clipBehavior: Clip.none, // Agar avatar bisa keluar dari Container
              children: [
                // Bagian atas dengan background biru dan gambar di tengah
                Container(
                  width: 428,
                  height: 334, // Dikurangi tinggi dari Avatar
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF71E7FF), Color(0xFF008EBD)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  child: Center(
                    child: Image.asset("assets/images/atas.png", width: 318),
                  ),
                ),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/logo2.png"),
                      fit: BoxFit.cover,
                    )
                  ),
                ),

                // Avatar diposisikan keluar dari Container biru
                Positioned(
                  bottom: -40, // Posisikan keluar setengah dari Container biru
                  left: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFF008EBD),
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 120), // Sesuaikan jarak agar tampilan tetap rapi
            // Form Input
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: "NIP",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/home');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF71E7FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: Text(
                      "Log-in",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),

            // Gambar di bawah tombol (hilangkan komentar jika ingin ditampilkan)
            // SvgPicture.asset('assets/images/bawah.svg'),
            SizedBox(height: 15),

            // Teks Sign-up
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),);
                  },
                  child: Text(
                    "Signup",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 860,
              left: 150,
              child: Row(
                children: [
                  Icon(
                    Icons.copyright,
                    size: 20,
                  ),
                  Text(
                    "FTBTeam",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
