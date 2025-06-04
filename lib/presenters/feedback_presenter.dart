import 'package:tpm_fp/models/feedback_model.dart';
import 'package:tpm_fp/network/feedback_service.dart';
import 'package:tpm_fp/models/user_model.dart';

class FeedbackPresenter {
  final FeedbackRepository _repository = FeedbackRepository();
  UserModel? _currentUser;

  void setCurrentUser(UserModel? user) {
    _currentUser = user;
  }

  Future<List<FeedbackModel>> getAllFeedbacks() async {
    return await _repository.getAllFeedbacks();
  }

  Future<List<FeedbackModel>> getUserFeedbacks() async {
    if (_currentUser == null) return [];
    return await _repository.getFeedbacksByUser(_currentUser!.username);
  }

  Future<bool> addFeedback(String type, String content) async {
    try {
      final currentUser = _currentUser;
      if (currentUser == null || currentUser.username.isEmpty) {
        throw Exception('User session expired. Please login again.');
      }

      final feedback = FeedbackModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: currentUser.username,
        fullname: currentUser.fullname,
        type: type,
        content: content,
        createdAt: DateTime.now(),
      );

      await _repository.addFeedback(feedback);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateFeedback(FeedbackModel feedback, String newContent) async {
    try {
      final currentUser = _currentUser;
      if (currentUser == null || feedback.username != currentUser.username) {
        return false;
      }

      final updatedFeedback = FeedbackModel(
        id: feedback.id,
        username: feedback.username,
        fullname: feedback.fullname,
        type: feedback.type,
        content: newContent,
        createdAt: feedback.createdAt,
      );

      await _repository.updateFeedback(updatedFeedback);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteFeedback(FeedbackModel feedback) async {
    if (_currentUser == null || feedback.username != _currentUser!.username) {
      return false;
    }

    await _repository.deleteFeedback(feedback.id);
    return true;
  }
}
