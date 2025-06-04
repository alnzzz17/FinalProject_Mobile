import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tpm_fp/models/feedback_model.dart';
import 'package:tpm_fp/presenters/feedback_presenter.dart';
import 'package:tpm_fp/models/user_model.dart';

class FeedbackScreen extends StatefulWidget {
  final UserModel? currentUser;
  const FeedbackScreen({super.key, this.currentUser});

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final FeedbackPresenter _presenter = FeedbackPresenter();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _contentController = TextEditingController();
  String _selectedType = 'impression';
  List<FeedbackModel> _feedbacks = [];
  bool _isLoading = false;

  bool _isEditing = false;
  FeedbackModel? _editingFeedback;

  Future<void> _editFeedback(FeedbackModel feedback) async {
    setState(() {
      _isEditing = true;
      _editingFeedback = feedback;
      _selectedType = feedback.type;
      _contentController.text = feedback.content;
    });
  }

  Future<void> _cancelEdit() async {
    setState(() {
      _isEditing = false;
      _editingFeedback = null;
      _contentController.clear();
    });
  }

  Future<void> _updateFeedback() async {
    if (!_formKey.currentState!.validate()) return;
    if (_editingFeedback == null) return;

    setState(() => _isLoading = true);

    try {
      final success = await _presenter.updateFeedback(
        _editingFeedback!,
        _contentController.text,
      );

      if (success) {
        _contentController.clear();
        await _loadFeedbacks();
        Get.snackbar(
          'Success',
          'Feedback updated',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        _cancelEdit();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed('/login');
      });
      return;
    }
    _presenter.setCurrentUser(widget.currentUser);
    _loadFeedbacks();
  }

  Future<void> _loadFeedbacks() async {
    setState(() => _isLoading = true);
    _feedbacks = await _presenter.getAllFeedbacks();
    setState(() => _isLoading = false);
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.currentUser == null) {
        // Redirect to login if user is not authenticated
        Get.offAllNamed('/login');
        return;
      }

      await _presenter.addFeedback(
        _selectedType,
        _contentController.text,
      );

      _contentController.clear();
      await _loadFeedbacks();

      Get.snackbar(
        'Success',
        'Feedback submitted',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteFeedback(FeedbackModel feedback) async {
    setState(() => _isLoading = true);
    final success = await _presenter.deleteFeedback(feedback);

    if (success) {
      await _loadFeedbacks();
      Get.snackbar(
        'Success',
        'Feedback deleted',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed to delete feedback',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Feedback',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading && _feedbacks.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildFeedbackForm(),
                  const SizedBox(height: 20),
                  _buildFeedbackList(),
                ],
              ),
            ),
    );
  }

  Widget _buildFeedbackForm() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add Feedback',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Type',
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'impression',
                    child: Text('Impression',
                        style: TextStyle(color: Colors.white)),
                  ),
                  DropdownMenuItem(
                    value: 'message',
                    child:
                        Text('Message', style: TextStyle(color: Colors.white)),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  labelText: 'Content',
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your feedback';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isEditing ? _updateFeedback : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 30),
                ),
                child: Text(_isEditing ? 'Update' : 'Submit'),
              ),
              if (_isEditing)
                TextButton(
                  onPressed: _cancelEdit,
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'All Feedbacks',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 8),
        _feedbacks.isEmpty
            ? const Center(
                child: Text(
                  'No feedbacks yet',
                  style: TextStyle(color: Colors.white70),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _feedbacks.length,
                itemBuilder: (context, index) {
                  final feedback = _feedbacks[index];
                  final isCurrentUser =
                      widget.currentUser?.username == feedback.username;

                  return Card(
                    color: Colors.grey[900],
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(
                        '${feedback.type.toUpperCase()} · ${feedback.fullname}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feedback.content,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Posted on ${formatDateTime(feedback.createdAt)}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: isCurrentUser
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () => _editFeedback(feedback),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _deleteFeedback(feedback),
                                ),
                              ],
                            )
                          : null,
                    ),
                  );
                },
              ),
      ],
    );
  }
}
