import 'package:flutter/material.dart';

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  String? selectedDay;
  List<String> days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

  // Contoh data jadwal berdasarkan hari
  Map<String, List<Map<String, String>>> scheduleData = {
    'Senin': [
      {'kelas': 'XII IPA 1', 'jam': '08:00', 'mapel': 'Matematika'},
      {'kelas': 'XII IPA 2', 'jam': '09:00', 'mapel': 'Fisika'},
    ],
    'Selasa': [
      {'kelas': 'XII IPA 3', 'jam': '10:00', 'mapel': 'Kimia'},
      {'kelas': 'XII IPA 4', 'jam': '11:00', 'mapel': 'Biologi'},
    ],
    'Rabu': [],
    'Kamis': [],
    'Jumat': [],
    'Sabtu': [],
  };

  List<Map<String, String>> get schedule => scheduleData[selectedDay] ?? [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF71E7FF), Color(0xFF008EBD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 10,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'Dasboard Guru',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF008EBD),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Konten bawah
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hari', style: TextStyle(fontSize: 18, color: Colors.white)),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: DropdownButton<String>(
                          value: selectedDay,
                          hint: Text('Pilih Hari'),
                          isExpanded: true,
                          underline: SizedBox(),
                          items: days.map((String day) {
                            return DropdownMenuItem<String>(
                              value: day,
                              child: Text(day),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedDay = newValue;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: schedule.isEmpty
                            ? Center(
                                child: Text(
                                  'Tidak ada jadwal',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              )
                            : ListView.builder(
                                itemCount: schedule.length,
                                itemBuilder: (context, index) {
                                  final item = schedule[index];
                                  return Card(
                                    margin: EdgeInsets.symmetric(vertical: 8),
                                    child: ListTile(
                                      title: Text("Kelas: ${item['kelas']!}"),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Jam: ${item['jam']!}"),
                                          Text("Mapel: ${item['mapel']!}"),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
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
