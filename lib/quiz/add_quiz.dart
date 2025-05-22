import 'package:flutter/material.dart';
import 'package:guru/quiz/detail_quiz.dart';

class AddQuiz extends StatefulWidget {
  final String jenisSoal;
  final String pertanyaan;
  final dynamic jawaban;

  const AddQuiz({
    super.key,
    required this.jenisSoal,
    required this.pertanyaan,
    required this.jawaban,
  });

  @override
  State<AddQuiz> createState() => _AddQuizState();
}

class _AddQuizState extends State<AddQuiz> {
  final List<QuizItem> quizItems = [];
  int questionCounter = 1;

  @override
  void initState() {
    super.initState();
    addInitialQuestion();
  }

  void addInitialQuestion() {
    quizItems.add(
      QuizItem(
        number: questionCounter,
        question: widget.pertanyaan,
        type: widget.jenisSoal,
        answer: widget.jawaban,
      ),
    );
  }

  void addNewQuestion() async {
  final newQuizItem = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const DetailQuiz(
        kelas: 'VII A',
        mapel: 'Matematika',
      ),
    ),
  );

  if (newQuizItem != null && newQuizItem is QuizItem) {
    setState(() {
      questionCounter++;
      quizItems.add(
        QuizItem(
          number: questionCounter,
          question: newQuizItem.question,
          type: newQuizItem.type,
          answer: newQuizItem.answer,
        ),
      );
    });
  }
}


  void editQuestion(int index) {
    // implement edit
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background biru
          Container(
            height: 120,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF71E7FF), Color(0xFF008EBD)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Isi konten
          Column(
            children: [
              const SizedBox(height: 50),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Add Quiz',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // agar kanan balance dengan tombol kiri
                ],
              ),

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Pertanyaan Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              '01.',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                widget.pertanyaan.isNotEmpty
                                    ? widget.pertanyaan
                                    : 'Pertanyaan...',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            IconButton(
                              onPressed: () => editQuestion(0),
                              icon: const Icon(Icons.edit, size: 18),
                            ),
                          ],
                        ),
                      ),

                      // Tombol tambah jawaban
                      Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black45,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: addNewQuestion,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Tombol selesai
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Quiz berhasil dibuat')),
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          'Selesai',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class QuizItem {
  final int number;
  String question;
  String type;
  dynamic answer;

  QuizItem({
    required this.number,
    required this.question,
    required this.type,
    required this.answer,
  });
}
