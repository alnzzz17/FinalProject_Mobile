import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final String username;
  
  @HiveField(1)
  final String fullname;
  
  @HiveField(2)
  final String passwordHash;
  
  @HiveField(3)
  final DateTime createdAt;

  UserModel({
    required this.username,
    required this.fullname,
    required this.passwordHash,
    required this.createdAt,
  });
}