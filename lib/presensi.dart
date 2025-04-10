import 'package:flutter/material.dart';
import 'package:guru/detail_presensi.dart';

class PresensiPage extends StatefulWidget {
  const PresensiPage({super.key});

  @override
  State<PresensiPage> createState() => _PresensiPageState();
}

class _PresensiPageState extends State<PresensiPage> {
  String? selectedKelas;
  String? selectedMapel;

  // Data kelas dan mapel sesuai kelas
  final List<String> listKelas = ['VII A', 'VII B', 'IX C'];
  final Map<String, List<String>> mapelPerKelas = {
    'VII A': ['Matematika', 'IPA', 'IPS'],
    'VII B': ['Bahasa Indonesia', 'PPKN', 'SBK'],
    'IX C': ['Bahasa Inggris', 'Fisika', 'Biologi'],
  };

  List<String> listMapel = [];

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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                listMapel = mapelPerKelas[value]!;
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
                            hint: "Pilih mapel",
                            items: listMapel,
                            onChanged: (value) {
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
                                    SnackBar(content: Text('Harap pilih kelas dan mapel!')),
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
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
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
      child: DropdownButton<String>(
        value: value,
        hint: Text(hint),
        isExpanded: true,
        underline: SizedBox(),
        icon: const Icon(Icons.arrow_drop_down_sharp),
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
