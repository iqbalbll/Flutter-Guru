import 'package:flutter/material.dart';
import 'package:guru/quiz/add_quiz.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  String _jenisSoal = 'pilihan';
  List<TextEditingController> _opsiControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  int? _correctAnswerIndex; // untuk menyimpan jawaban yang benar

  // Data yang diperlukan untuk API
  int? _userId;
  int? _guruId;
  int? _kelasId;
  int? _mapelId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load data user dan konversi kelas/mapel ke ID
  Future<void> _loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _userId = prefs.getInt('userId');
      
      // Ambil data guru berdasarkan userId
      await _getGuruData();
      
      // Konversi nama kelas dan mapel ke ID
      await _getKelasMapelIds();
    } catch (e) {
      _showError('Gagal memuat data: $e');
    }
  }

  Future<void> _getGuruData() async {
    try {
      final response = await http.get(
        Uri.parse('http://3.0.151.126/api/admin/gurus'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final guru = data['data'].firstWhere(
          (item) => item['pengguna_id'] == _userId,
          orElse: () => null,
        );
        
        if (guru != null) {
          _guruId = guru['id'];
        }
      }
    } catch (e) {
      print('Error getting guru data: $e');
    }
  }

  Future<void> _getKelasMapelIds() async {
    try {
      final responses = await Future.wait([
        http.get(Uri.parse('http://3.0.151.126/api/admin/kelas')),
        http.get(Uri.parse('http://3.0.151.126/api/admin/mata-pelajarans')),
      ]);
      
      if (responses.every((response) => response.statusCode == 200)) {
        final kelasData = json.decode(responses[0].body);
        final mapelData = json.decode(responses[1].body);
        
        // Cari ID kelas
        final kelas = kelasData['data'].firstWhere(
          (item) => (item['nama'] ?? item['nama_kelas']) == widget.kelas,
          orElse: () => null,
        );
        
        // Cari ID mapel
        final mapel = mapelData['data'].firstWhere(
          (item) => (item['nama'] ?? item['nama_mapel']) == widget.mapel,
          orElse: () => null,
        );
        
        if (kelas != null) _kelasId = kelas['id'];
        if (mapel != null) _mapelId = mapel['id'];
      }
    } catch (e) {
      print('Error getting kelas/mapel IDs: $e');
    }
  }

  @override
  void dispose() {
    _pertanyaanController.dispose();
    _esaiController.dispose();
    for (var ctrl in _opsiControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showError('Gagal memilih gambar: $e');
    }
  }

  void _addOpsi() {
    setState(() {
      _opsiControllers.add(TextEditingController());
    });
  }

  void _removeOpsi(int index) {
    setState(() {
      _opsiControllers.removeAt(index);
      // Reset correct answer jika yang dihapus adalah jawaban benar
      if (_correctAnswerIndex == index) {
        _correctAnswerIndex = null;
      } else if (_correctAnswerIndex != null && _correctAnswerIndex! > index) {
        _correctAnswerIndex = _correctAnswerIndex! - 1;
      }
    });
  }

  Widget _buildOpsiFields({bool isCheckbox = false}) {
    return Column(
      children: [
        for (int i = 0; i < _opsiControllers.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                // Radio button atau checkbox untuk menandai jawaban benar
                if (!isCheckbox)
                  Radio<int>(
                    value: i,
                    groupValue: _correctAnswerIndex,
                    onChanged: (value) {
                      setState(() {
                        _correctAnswerIndex = value;
                      });
                    },
                  )
                else
                  const Icon(Icons.check_box_outline_blank),
                
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
        if (_jenisSoal == 'pilihan' && _correctAnswerIndex == null)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Pilih jawaban yang benar dengan mencentang radio button',
              style: TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Future<void> _submitQuiz() async {
    // Validasi input
    if (_pertanyaanController.text.trim().isEmpty) {
      _showError('Pertanyaan tidak boleh kosong');
      return;
    }

    if (_jenisSoal == 'pilihan' && _correctAnswerIndex == null) {
      _showError('Pilih jawaban yang benar untuk soal pilihan ganda');
      return;
    }

    if (_jenisSoal == 'pilihan' && _opsiControllers.any((ctrl) => ctrl.text.trim().isEmpty)) {
      _showError('Semua opsi pilihan ganda harus diisi');
      return;
    }

    if (_jenisSoal == 'esay' && _esaiController.text.trim().isEmpty) {
      _showError('Jawaban esai tidak boleh kosong');
      return;
    }

    if (_userId == null || _guruId == null || _kelasId == null || _mapelId == null) {
      _showError('Data tidak lengkap. Coba refresh halaman.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Upload soal quiz terlebih dahulu
      final soalId = await _uploadSoalQuiz();
      
      if (soalId != null) {
        // 2. Upload pilihan jawaban jika jenis soal pilihan ganda
        if (_jenisSoal == 'pilihan') {
          await _uploadPilihanJawaban(soalId);
        }
        
        _showSuccess('Quiz berhasil ditambahkan!');
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('Gagal menyimpan quiz: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<int?> _uploadSoalQuiz() async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://3.0.151.126/api/admin/soal-quizzes'),
      );

      // Tambahkan field wajib
      request.fields['user_id'] = _userId.toString();
      request.fields['guru_id'] = _guruId.toString();
      request.fields['kelas_id'] = _kelasId.toString();
      request.fields['mapel_id'] = _mapelId.toString();
      request.fields['pertanyaan'] = _pertanyaanController.text.trim();
      request.fields['jenis_soal'] = _jenisSoal;

      // Tambahkan jawaban berdasarkan jenis soal
      if (_jenisSoal == 'esay') {
        request.fields['jawaban'] = _esaiController.text.trim();
      } else if (_jenisSoal == 'isian') {
        request.fields['jawaban'] = _opsiControllers.first.text.trim();
      }

      // Upload gambar jika ada
      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'gambar',
          _selectedImage!.path,
        ));
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(responseBody);
        return data['data']['id']; // Return ID soal yang baru dibuat
      } else {
        throw Exception('Failed to upload quiz: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading quiz: $e');
    }
  }

  Future<void> _uploadPilihanJawaban(int soalId) async {
    try {
      // Upload semua pilihan jawaban
      for (int i = 0; i < _opsiControllers.length; i++) {
        final response = await http.post(
          Uri.parse('http://3.0.151.126/api/admin/pilihan-jawabans'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'soal_quiz_id': soalId,
            'pilihan': _opsiControllers[i].text.trim(),
            'is_correct': i == _correctAnswerIndex,
          }),
        );

        if (response.statusCode != 200 && response.statusCode != 201) {
          throw Exception('Failed to upload pilihan jawaban ${i + 1}');
        }
      }
    } catch (e) {
      throw Exception('Error uploading pilihan jawaban: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
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
                          // Info Kelas dan Mapel
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.class_, color: Colors.blue.shade600),
                                const SizedBox(width: 8),
                                Text(
                                  'Kelas: ${widget.kelas} | Mapel: ${widget.mapel}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          const Text("Pertanyaan",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _pertanyaanController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: "Masukkan pertanyaan",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Upload Gambar
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.image),
                                label: const Text("Upload Gambar"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF008EBD),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (_selectedImage != null)
                                Expanded(
                                  child: Text(
                                    'Gambar dipilih: ${_selectedImage!.path.split('/').last}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.green,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          const Text("Jenis Soal",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _jenisSoal,
                            items: [
                              const DropdownMenuItem(value: 'pilihan', child: Text('Pilihan Ganda')),
                              const DropdownMenuItem(value: 'isian', child: Text('Isian')),
                              const DropdownMenuItem(value: 'esay', child: Text('Esay')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _jenisSoal = value!;
                                _correctAnswerIndex = null;
                                if (_jenisSoal != 'esay') {
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

                          // Field berdasarkan jenis soal
                          if (_jenisSoal == 'pilihan') ...[
                            const Text("Pilihan Jawaban",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            _buildOpsiFields(),
                          ] else if (_jenisSoal == 'isian') ...[
                            const Text("Jawaban yang Benar",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _opsiControllers.first,
                              decoration: InputDecoration(
                                hintText: "Masukkan jawaban yang benar",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                          ] else if (_jenisSoal == 'esay') ...[
                            const Text("Jawaban Esai",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _esaiController,
                              maxLines: 5,
                              decoration: InputDecoration(
                                hintText: "Jawaban dalam bentuk esai",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),

                          // Tombol Submit
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submitQuiz,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF008EBD),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text("Simpan Quiz"),
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
