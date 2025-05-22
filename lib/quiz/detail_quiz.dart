import 'package:flutter/material.dart';
import 'package:guru/quiz/add_quiz.dart';

class DetailQuiz extends StatefulWidget {
  final String kelas;
  final String mapel;

  const DetailQuiz({super.key, required this.kelas, required this.mapel});

  @override
  State<DetailQuiz> createState() => _DetailQuizState();
}

class _DetailQuizState extends State<DetailQuiz> {
  final TextEditingController _pertanyaanController = TextEditingController();
  final TextEditingController _esaiController = TextEditingController();

  String _jenisSoal = 'Pilihan Ganda';
  List<TextEditingController> _opsiControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void dispose() {
    _pertanyaanController.dispose();
    _esaiController.dispose();
    for (var ctrl in _opsiControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _addOpsi() {
    setState(() {
      _opsiControllers.add(TextEditingController());
    });
  }

  void _removeOpsi(int index) {
    setState(() {
      _opsiControllers.removeAt(index);
    });
  }

  Widget _buildOpsiFields({bool isCheckbox = false}) {
    return Column(
      children: [
        for (int i = 0; i < _opsiControllers.length; i++)
          Row(
            children: [
              if (isCheckbox)
                const Icon(Icons.check_box_outline_blank)
              else
                Text('${String.fromCharCode(97 + i)}.'),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _opsiControllers[i],
                  decoration: InputDecoration(
                    hintText: isCheckbox
                        ? "Checkbox ${i + 1}"
                        : "Opsi ${String.fromCharCode(97 + i)}",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: _opsiControllers.length > 1
                    ? () => _removeOpsi(i)
                    : null,
              ),
            ],
          ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _addOpsi,
            icon: const Icon(Icons.add),
            label: const Text("Tambah Opsi"),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
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
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                        color: const Color(0xFF006181),
                      ),
                      const Spacer(),
                      const Text(
                        'Add Quiz',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006181),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
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
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Pertanyaan",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _pertanyaanController,
                            decoration: InputDecoration(
                              hintText: "Masukkan pertanyaan",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF008EBD),
                              foregroundColor: Colors.white,
                            ),
                            child:
                                const Text("Upload Gambar (opsional)"),
                          ),
                          const SizedBox(height: 16),
                          const Text("Jenis Jawaban",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _jenisSoal,
                            items: ['Pilihan Ganda', 'Checkbox', 'Esai']
                                .map((jenis) {
                              return DropdownMenuItem(
                                value: jenis,
                                child: Text(jenis),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _jenisSoal = value!;
                                if (_jenisSoal != 'Esai') {
                                  _opsiControllers = [
                                    TextEditingController(),
                                    TextEditingController(),
                                  ];
                                }
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_jenisSoal == 'Pilihan Ganda') ...[
                            const Text("Jawaban Opsi (a, b, c, dst)",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            _buildOpsiFields(),
                          ] else if (_jenisSoal == 'Checkbox') ...[
                            const Text("Jawaban Checkbox",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            _buildOpsiFields(isCheckbox: true),
                          ] else if (_jenisSoal == 'Esai') ...[
                            const Text("Jawaban Esai",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _esaiController,
                              maxLines: null,
                              minLines: 5,
                              decoration: InputDecoration(
                                hintText: "Jawaban dalam bentuk esai",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddQuiz(
                                      jenisSoal: _jenisSoal,
                                      pertanyaan:
                                          _pertanyaanController.text,
                                      jawaban: _jenisSoal == 'Esai'
                                          ? _esaiController.text
                                          : _opsiControllers
                                              .map((c) => c.text)
                                              .toList(),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF008EBD),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text("Add"),
                            ),
                          ),
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
}
