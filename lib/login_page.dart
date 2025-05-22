import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:guru/home/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<int?> login(String email, String password) async {
    final url = Uri.parse('http://3.0.151.126/api/admin/penggunas');
    try {
      final response = await http.get(url);
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List users = jsonResponse['data']; // Ambil list user dari key 'data'
        for (var user in users) {
          if (user['email'] == email &&
              user['password'] == password &&
              user['role'] == 'guru') { // hanya role guru
            return user['id']; // Kembalikan userId
          }
        }
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  void handleLogin() async {
    final email = emailController.text;
    final password = passwordController.text;
    final userId = await login(email, password);

    if (!mounted) return;

    if (userId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', userId); // Simpan userId ke SharedPreferences

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email atau password salah')),
      );
    }
  }

//batas undo
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Tambahkan baris ini
      body: Stack(
        children: [
          // Bagian scrollable (form login)
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 0), // beri jarak agar tidak ketumpuk copyright
            child: Column(
              children: [
                // ... Stack header, form, button, dll ...
                Stack(
                  clipBehavior: Clip.none,
                  children: [
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
                      child: Center(
                        child: Image.asset(
                          "assets/images/atas.png",
                          width: 318,
                        ),
                      ),
                    ),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/logo2.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -50,
                      left: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Color(0xFF008EBD),
                          child: Icon(Icons.person, size: 50, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 80),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 60),
                      ElevatedButton(
                        onPressed: handleLogin,
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
                    ],
                  ),
                ),
                SizedBox(height: 80), // beri jarak bawah agar tidak ketumpuk keyboard/copyright
              ],
            ),
          ),
          // Copyright selalu di bawah layar
          Positioned(
            left: 0,
            right: 0,
            bottom: -3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.copyright, size: 20),
                SizedBox(width: 5),
                Text(
                  "FTBTeam",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
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
