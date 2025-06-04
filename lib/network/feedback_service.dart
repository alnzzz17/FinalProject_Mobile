import 'package:hive/hive.dart';
import 'package:tpm_fp/models/feedback_model.dart';

class FeedbackRepository {
  static const String _boxName = 'feedbacks';

  Future<Box<FeedbackModel>> get _box async {
    return await Hive.openBox<FeedbackModel>(_boxName);
  }

  Future<List<FeedbackModel>> getAllFeedbacks() async {
    final box = await _box;
    return box.values.toList();
  }

  Future<List<FeedbackModel>> getFeedbacksByUser(String username) async {
    final box = await _box;
    return box.values.where((f) => f.username == username).toList();
  }

  Future<void> addFeedback(FeedbackModel feedback) async {
  try {
    final box = await _box;
    await box.put(feedback.id, feedback);
  } catch (e) {
    rethrow;
  }
}

  Future<void> updateFeedback(FeedbackModel feedback) async {
    final box = await _box;
    await box.put(feedback.id, feedback);
  }

  Future<void> deleteFeedback(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  Future<void> clearAll() async {
    final box = await _box;
    await box.clear();
  }
}