import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tpm_fp/models/schedule_model.dart';
import 'package:tpm_fp/network/notification_service.dart';
import 'package:tpm_fp/presenters/schedule_presenter.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ScheduleScreenState createState() => ScheduleScreenState();
}

class ScheduleScreenState extends State<ScheduleScreen> {
  final SchedulePresenter _presenter = SchedulePresenter();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  String? _selectedCircuitId;
  String? _selectedType;
  DateTime? _selectedDateTime;

  List<Schedule> _schedules = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initialize();
    NotificationService().setCircuits(_presenter.getCircuits());
  }

  Future<void> _initialize() async {
    await _presenter.init();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() => _isLoading = true);
    _schedules = await _presenter.getSchedules();
    setState(() => _isLoading = false);
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.red,
              onPrimary: Colors.white,
              surface: Colors.grey[900]!,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.grey[900],
          ),
          child: child!,
        );
      },
    );

    if (!mounted) return;

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
        builder: (context, child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: Colors.red,
                onPrimary: Colors.white,
                surface: Colors.grey[900]!,
                onSurface: Colors.white,
              ),
              dialogBackgroundColor: Colors.grey[900],
            ),
            child: child!,
          );
        },
      );

      if (!mounted) return;

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  bool _isEditing = false;
  Schedule? _editingSchedule;

  void _startEdit(Schedule schedule) {
    setState(() {
      _isEditing = true;
      _editingSchedule = schedule;
      _nameController.text = schedule.name;
      _selectedCircuitId = schedule.circuitId;
      _selectedType = schedule.type;
      _selectedDateTime = schedule.dateTime;
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _editingSchedule = null;
      _nameController.clear();
      _selectedCircuitId = null;
      _selectedType = null;
      _selectedDateTime = null;
    });
  }

  Future<void> _saveOrUpdateSchedule() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCircuitId == null ||
        _selectedType == null ||
        _selectedDateTime == null) {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isEditing && _editingSchedule != null) {
        await _presenter.updateSchedule(
          id: _editingSchedule!.id,
          name: _nameController.text,
          circuitId: _selectedCircuitId!,
          type: _selectedType!,
          dateTime: _selectedDateTime!,
        );
      } else {
        await _presenter.saveSchedule(
          name: _nameController.text,
          circuitId: _selectedCircuitId!,
          type: _selectedType!,
          dateTime: _selectedDateTime!,
        );
      }

      _cancelEdit();
      await _loadSchedules();

      Get.snackbar(
        'Success',
        _isEditing ? 'Schedule updated' : 'Schedule saved',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save schedule: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSchedule(String id) async {
    setState(() => _isLoading = true);
    try {
      await _presenter.deleteSchedule(id);
      await _loadSchedules();
      Get.snackbar(
        'Success',
        'Schedule deleted successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete schedule: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('schedule_screen'),
      backgroundColor: Colors.black,
      appBar: AppBar(
        key: const Key('schedule_app_bar'),
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Race Schedule',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading && _schedules.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                key: Key('loading_indicator'),
                color: Colors.red,
              ),
            )
          : SingleChildScrollView(
              key: const Key('schedule_scroll_view'),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildForm(context),
                  const SizedBox(height: 20),
                  _buildScheduleList(),
                ],
              ),
            ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Card(
      key: const Key('schedule_form_card'),
      color: Colors.grey[900],
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                _isEditing ? 'Edit Schedule' : 'Add Schedule',
                key: const Key('form_title'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('name_input'),
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  labelText: 'Schedule Name',
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white70),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter schedule name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                key: const Key('circuit_dropdown'),
                isExpanded: true,
                value: _selectedCircuitId,
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Circuit Location',
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white70),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  filled: true,
                  fillColor: Colors.grey[800],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                items: _presenter.getCircuits().map((circuit) {
                  return DropdownMenuItem<String>(
                    key: Key('circuit_${circuit.id}'),
                    value: circuit.id,
                    child: Row(
                      children: [
                        Text(circuit.flagEmoji),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            circuit.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCircuitId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select circuit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                key: const Key('type_dropdown'),
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
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
                items: _presenter.getScheduleTypes().map((type) {
                  return DropdownMenuItem<String>(
                    key: Key('type_$type'),
                    value: type,
                    child: Text(
                      type,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select session type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('date_time_input'),
                readOnly: true,
                controller: TextEditingController(
                  text: _selectedDateTime != null
                      ? DateFormat('dd/MM/yyyy HH:mm')
                          .format(_selectedDateTime!)
                      : 'Select date & time',
                ),
                style: const TextStyle(color: Colors.white70),
                decoration: InputDecoration(
                  labelText: 'Date & Time',
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white70),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  filled: true,
                  fillColor: Colors.grey[800],
                  suffixIcon:
                      const Icon(Icons.calendar_today, color: Colors.white70),
                ),
                onTap: () => _selectDateTime(context),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                key: const Key('save_button'),
                onPressed: _saveOrUpdateSchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 30),
                ),
                child: Text(
                  _isEditing ? 'Update' : 'Save',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (_isEditing)
                TextButton(
                  key: const Key('cancel_button'),
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

  Widget _buildScheduleList() {
    return Column(
      key: const Key('schedule_list'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Saved Schedules',
          key: Key('saved_schedules_title'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        _schedules.isEmpty
            ? const Center(
                child: Text(
                  'No schedules saved yet',
                  key: Key('empty_schedules_text'),
                ),
              )
            : ListView.builder(
                key: const Key('schedules_list_view'),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _schedules.length,
                itemBuilder: (context, index) {
                  final schedule = _schedules[index];
                  final circuit = _presenter.getCircuitById(schedule.circuitId);

                  return Card(
                    key: Key('schedule_card_${schedule.id}'),
                    color: Colors.grey[900],
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      key: Key('schedule_item_${schedule.id}'),
                      title: Text(
                        schedule.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${circuit?.name ?? 'Unknown circuit'} - ${schedule.type}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy HH:mm')
                                .format(schedule.dateTime),
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            key: Key('edit_button_${schedule.id}'),
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () => _startEdit(schedule),
                          ),
                          IconButton(
                            key: Key('delete_button_${schedule.id}'),
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteSchedule(schedule.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }
}
