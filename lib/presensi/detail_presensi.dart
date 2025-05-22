import 'package:flutter/material.dart';

class DetailPresensiPage extends StatefulWidget {
  final String kelas;
  final String mapel;

  const DetailPresensiPage({
    super.key,
    required this.kelas,
    required this.mapel,
  });

  @override
  State<DetailPresensiPage> createState() => _DetailPresensiPageState();
}

class _DetailPresensiPageState extends State<DetailPresensiPage> {
  bool isPresensiDibuka = false;

  void togglePresensi() {
    setState(() {
      isPresensiDibuka = !isPresensiDibuka;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background atas
          Container(
            height: 150,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF71E7FF), Color(0xFF008EBD)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 30,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                        color: const Color(0xFF006181),
                      ),
                      const Spacer(),
                      const Text(
                        'PRESENSI',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006181),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(
                        width: 48,
                      ), // Untuk keseimbangan IconButton
                    ],
                  ),
                ),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // Box informasi mapel
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  widget.mapel,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text('Jadwal  : hari (jam ke-kam ke)'),
                              Text('Kelas    : ${widget.kelas}'),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        isPresensiDibuka = true;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.cyan,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Buka Presensi'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        isPresensiDibuka = false;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.cyan,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Tutup Presensi'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // History presensi
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Hadir',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Icon(Icons.refresh, size: 18),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          height: 80,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.cyan,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        const Text(
                          'Tidak Hadir',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          height: 80,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.cyan,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
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
}
