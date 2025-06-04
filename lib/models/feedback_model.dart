import 'package:hive/hive.dart';

part 'feedback_model.g.dart';

@HiveType(typeId: 1)
class FeedbackModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String username;
  
  @HiveField(2)
  final String fullname;
  
  @HiveField(3)
  final String type;
  
  @HiveField(4)
  final String content;
  
  @HiveField(5)
  final DateTime createdAt;

  FeedbackModel({
    required this.id,
    required this.username,
    required this.fullname,
    required this.type,
    required this.content,
    required this.createdAt,
  });
}

String formatDateTime(DateTime dateTime) {
  return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
}