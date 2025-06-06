import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tpm_fp/models/circuit_model.dart';
import 'package:tpm_fp/models/timezone_model.dart';
import 'package:tpm_fp/presenters/time_convert_presenter.dart';

class TimeConverterScreen extends StatefulWidget {
  const TimeConverterScreen({super.key});

  @override
  TimeConverterScreenState createState() => TimeConverterScreenState();
}

class TimeConverterScreenState extends State<TimeConverterScreen> {
  final TimeConverterPresenter _presenter = TimeConverterPresenter();
  final TextEditingController _timezoneSearchController = TextEditingController();
  Circuit? _selectedFromCircuit;
  Timezone? _selectedToTimezone;
  DateTime? _selectedDateTime;
  String _convertedTime = '';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _timezoneSearchController.addListener(_filterTimezones);
  }

  @override
  void dispose() {
    _timezoneSearchController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    try {
      await _presenter.loadCircuits();
      await _presenter.loadTimezones();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterTimezones() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('time_converter_screen'),
      backgroundColor: Colors.black,
      appBar: AppBar(
        key: const Key('time_converter_app_bar'),
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Time Zone Converter',
          key: Key('time_converter_title'),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          key: Key('loading_indicator'),
          color: Colors.red,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          key: const Key('error_message'),
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    if (_presenter.errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _presenter.errorMessage,
          key: const Key('presenter_error_message'),
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    return SingleChildScrollView(
      key: const Key('scroll_view'),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        key: const Key('main_column'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildConverterCard(),
          if (_convertedTime.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildResultCard(),
          ],
          if (_selectedToTimezone != null) ...[
            const SizedBox(height: 20),
            _buildCurrentTimeCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildConverterCard() {
    return Card(
      key: const Key('converter_card'),
      color: Colors.grey[900],
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          key: const Key('converter_column'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCircuitDropdown(),
            const SizedBox(height: 16),
            _buildTimezoneDropdown(),
            const SizedBox(height: 16),
            _buildDateTimePicker(),
            const SizedBox(height: 16),
            if (_selectedFromCircuit != null &&
                _selectedDateTime != null &&
                _selectedToTimezone != null)
              ElevatedButton(
                key: const Key('convert_button'),
                onPressed: _convertTime,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'CONVERT TIME',
                  key: Key('convert_button_text'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimezoneDropdown() {
    return Column(
      key: const Key('timezone_dropdown_column'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'To Timezone',
          key: Key('timezone_label'),
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          key: const Key('timezone_selector'),
          onTap: _showTimezoneSearchDialog,
          child: Container(
            key: const Key('timezone_selector_container'),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              border: Border.all(
                color: _selectedToTimezone != null
                    ? Colors.red
                    : Colors.white70,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedToTimezone?.displayName ?? 'Select a timezone',
                    key: const Key('selected_timezone_text'),
                    style: const TextStyle(color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.white),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showTimezoneSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        List<Timezone> filtered = _presenter.timezones;
        TextEditingController searchController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            void filter(String query) {
              setStateDialog(() {
                filtered = _presenter.timezones
                    .where((tz) => tz.displayName
                        .toLowerCase()
                        .contains(query.toLowerCase()))
                    .toList();
              });
            }

            return Theme(
              data: ThemeData.dark().copyWith(
                dialogBackgroundColor: Colors.grey[900],
              ),
              child: AlertDialog(
                key: const Key('timezone_dialog'),
                backgroundColor: Colors.grey[900],
                title: const Text(
                  'Select Timezone',
                  key: Key('timezone_dialog_title'),
                  style: TextStyle(color: Colors.white),
                ),
                content: SingleChildScrollView(
                  key: const Key('timezone_dialog_content'),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.7,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          key: const Key('timezone_search_field'),
                          controller: searchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search timezone...',
                            hintStyle: const TextStyle(color: Colors.white70),
                            prefixIcon: const Icon(Icons.search, color: Colors.white70),
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
                          onChanged: filter,
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.builder(
                            key: const Key('timezone_list'),
                            shrinkWrap: true,
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final tz = filtered[index];
                              return ListTile(
                                key: Key('timezone_item_${tz.name}'),
                                title: Text(
                                  tz.displayName,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    _selectedToTimezone = tz;
                                    _convertedTime = '';
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCircuitDropdown() {
    return Column(
      key: const Key('circuit_dropdown_column'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'From Circuit',
          key: Key('circuit_label'),
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Circuit>(
          key: const Key('circuit_dropdown'),
          isExpanded: true,
          value: _selectedFromCircuit,
          dropdownColor: Colors.grey[900],
          style: const TextStyle(color: Colors.white),
          hint: const Text(
            'Select a circuit',
            key: Key('circuit_hint_text'),
            style: TextStyle(color: Colors.white70),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          items: _presenter.circuits.map((circuit) {
            return DropdownMenuItem<Circuit>(
              key: Key('circuit_item_${circuit.id}'),
              value: circuit,
              child: Row(
                children: [
                  Text(
                    circuit.flagEmoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      circuit.name,
                      key: Key('circuit_name_${circuit.id}'),
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
              _selectedFromCircuit = value;
              _convertedTime = '';
            });
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
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
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    return Column(
      key: const Key('datetime_picker_column'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date & Time',
          key: Key('datetime_label'),
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            key: const Key('datetime_picker_button'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: _selectedDateTime != null
                      ? Colors.red
                      : Colors.white70,
                ),
              ),
            ),
            onPressed: _pickDateTime,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  _selectedDateTime == null
                      ? 'Select Date & Time'
                      : DateFormat('HH:mm on dd MMM yyyy')
                          .format(_selectedDateTime!),
                  key: Key(_selectedDateTime == null 
                      ? 'datetime_hint_text' 
                      : 'selected_datetime_text'),
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard() {
    return Card(
      key: const Key('result_card'),
      color: Colors.grey[900],
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          key: const Key('result_column'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Converted Time',
              key: Key('result_title'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _convertedTime,
              key: const Key('converted_time_text'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'From: ${_selectedFromCircuit?.name} (${_selectedFromCircuit?.timezone})',
              key: const Key('from_circuit_text'),
              style: TextStyle(
                color: Colors.white70,
                fontStyle: FontStyle.italic,
              ),
            ),
            Text(
              'To: ${_selectedToTimezone?.displayName}',
              key: const Key('to_timezone_text'),
              style: TextStyle(
                color: Colors.white70,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTimeCard() {
    return Card(
      key: const Key('current_time_card'),
      color: Colors.grey[900],
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<String>(
          key: const Key('current_time_future_builder'),
          future: _selectedToTimezone != null
              ? _presenter.getCurrentTimeInTimezone(_selectedToTimezone!.name)
              : Future.value('Select a timezone to see current time'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  key: Key('current_time_loading'),
                  color: Colors.red,
                ),
              );
            }
            if (snapshot.hasError) {
              return Text(
                'Error: ${snapshot.error}',
                key: const Key('current_time_error'),
                style: const TextStyle(color: Colors.white),
              );
            }
            return Column(
              key: const Key('current_time_column'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Time at ${_selectedToTimezone?.displayName ?? "Timezone"}',
                  key: const Key('current_time_title'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  snapshot.data ?? 'Error loading current time',
                  key: const Key('current_time_text'),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
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

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
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

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          _convertedTime = '';
        });
      }
    }
  }

  Future<void> _convertTime() async {
    if (_selectedFromCircuit == null ||
        _selectedDateTime == null ||
        _selectedToTimezone == null) {
      setState(() {
        _errorMessage = 'Please fill all fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _presenter.convertTime(
        dateTime: _selectedDateTime!,
        fromCircuitId: _selectedFromCircuit!.id,
        toTimezone: _selectedToTimezone!.name,
      );

      setState(() {
        _convertedTime = result;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }
}