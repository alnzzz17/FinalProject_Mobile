import 'package:tpm_fp/models/feedback_model.dart';

class FeedbackData {
  static List<FeedbackModel> get defaultFeedbacks {
    return [
      FeedbackModel(
        id: 'default_1',
        username: 'system',
        fullname: 'Erllyta',
        type: 'impression',
        content: 'Mata kuliah ini sangat menarik dan memberikan banyak wawasan baru mengenai teknologi dan pemrograman mobile.',
        createdAt: DateTime(2025, 6, 8),
      ),
      FeedbackModel(
        id: 'default_2',
        username: 'system',
        fullname: 'Erllyta',
        type: 'impression',
        content: 'Tugas-tugasnya membantu saya mengeksplor bidang ini dan berkembang lebih jauh lagi.',
        createdAt: DateTime(2025, 6, 8),
      ),
      FeedbackModel(
        id: 'default_3',
        username: 'system',
        fullname: 'Erllyta',
        type: 'impression',
        content: 'Rasio antara kuliah daring dan luring, serta antara tugas individu dan kelompok yang seimbang, membuat saya tetap fokus dan tidak merasa jenuh.',
        createdAt: DateTime(2025, 6, 8),
      ),
      FeedbackModel(
        id: 'default_4',
        username: 'system',
        fullname: 'Erllyta',
        type: 'message',
        content: 'Untuk gambaran atau kriteria projek akhir sebaiknya disampaikan di awal semester. Dengan demikian, mahasiswa bisa mempersiapkan diri dengan baik dan merencanakan projek akhirnya sambil belajar sehingga persiapan dan pengerjaannya menjadi lebih matang.',
        createdAt: DateTime(2025, 6, 8),
      ),
    ];
  }
}