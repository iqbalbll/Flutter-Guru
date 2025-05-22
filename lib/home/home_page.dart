import 'package:flutter/material.dart';
import 'package:guru/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 800, // Tinggi cukup untuk menampilkan seluruh Stack
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Background Container
                  Container(
                    width: double.infinity,
                    height: 334,
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
                  ),

                  // Tombol menu (profile + logout)
                    Positioned(
                      top: 30,
                      right: 10,
                      child: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'profile') {
                            Navigator.pushNamed(context, '/profile');
                          } else if (value == 'logout') {
                            _showLogoutDialog(context);
                          }
                        },
                        icon: Icon(
                          Icons.menu,
                          size: 40,
                          color: Colors.white,
                        ),
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem<String>(
                            value: 'profile',
                            child: Text('Profile'),
                          ),
                          PopupMenuItem<String>(
                            value: 'logout',
                            child: Text('Logout'),
                          ),
                        ],
                      ),
                    ),



                  // Logo kiri atas
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Image.asset(
                      "assets/images/logo2.png",
                      width: 150,
                      fit: BoxFit.contain,
                    ),
                  ),

                  // Logo tengah
                  Positioned(
                    top: 70,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Image.asset(
                        "assets/images/logoHome.png",
                        width: 380,
                      ),
                    ),
                  ),

                  // Dashboard Guru
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 375,
                    child: Column(
                      children: [
                        Container(
                          width: 320,
                          height: 150,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            shadows: [
                              BoxShadow(
                                color: Color(0x3F000000),
                                blurRadius: 20,
                                offset: Offset(-2, -2),
                                spreadRadius: 0,
                              ),
                              BoxShadow(
                                color: Color(0x3F000000),
                                blurRadius: 30,
                                offset: Offset(2, 2),
                                spreadRadius: -11,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 10),
                              Image.asset(
                                "assets/images/logoDashboard.png",
                                width: 120,
                              ),
                              SizedBox(width: 10),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Dashboard Guru",
                                    style: TextStyle(
                                      color: Color(0xFF006080),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Cek Jadwal Mengajar Disini",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/jadwal');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF008EBD),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 8,
                                      ),
                                    ),
                                    child: Text(
                                      "Lihat",
                                      style: TextStyle(
                                        color: Color(0xFF71E7FF),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Menu bawah
                  Positioned(
                    top: 565,
                    left: 18,
                    right: 18,
                    child: Container(
                      width: 210,
                      height: 185,
                      decoration: ShapeDecoration(
                        color: Color(0xFF008EBD),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        shadows: [
                          BoxShadow(
                            color: Color(0x3F000000),
                            blurRadius: 20,
                            offset: Offset(-2, -2),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color(0x3F000000),
                            blurRadius: 30,
                            offset: Offset(2, 2),
                            spreadRadius: -11,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _menuItem(
                            Icons.notifications_active_outlined,
                            "Presensi",
                            () {
                              Navigator.pushNamed(context, '/presensi');
                            },
                          ),
                          _menuItem(
                            Icons.auto_stories_outlined,
                            "Quiz",
                            () {
                              Navigator.pushNamed(context, '/quiz');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Footer
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.copyright, size: 20),
                SizedBox(width: 5),
                Text(
                  "FTBTeam",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget untuk menu
  Widget _menuItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        height: 120,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          shadows: [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 20,
              offset: Offset(-2, -2),
              spreadRadius: 0,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Popup Konfirmasi Logout
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Konfirmasi Logout"),
        content: Text("Apakah Anda yakin ingin logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("Tidak"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Tutup dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: Text("Ya"),
          ),
        ],
      ),
    );
  }
}
