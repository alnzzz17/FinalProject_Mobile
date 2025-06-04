import 'package:intl/intl.dart';
import 'package:tpm_fp/models/circuit_model.dart';
import 'package:tpm_fp/models/data/circuit_data.dart';
import 'package:tpm_fp/models/timezone_model.dart';
import 'package:tpm_fp/network/time_convert_service.dart';

class TimeConverterPresenter {
  final ApiService _apiService = ApiService();
  List<Circuit> circuits = [];
  List<Timezone> timezones = [];
  bool isLoading = false;
  String errorMessage = '';

  static const String _dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String _displayFormat = 'HH:mm:ss on EEE, dd MMM yyyy';

  // Loads all circuits from local data
  Future<void> loadCircuits() async {
    circuits = CircuitRepository.circuits;
  }

  // Loads timezones from API
  Future<void> loadTimezones() async {
    try {
      isLoading = true;
      errorMessage = '';
      final timezoneStrings = await _apiService.getAvailableTimezones();
      timezones = timezoneStrings.map((tz) => Timezone.fromApi(tz)).toList();
    } catch (e) {
      errorMessage = 'Failed to load timezones: ${e.toString()}';
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  // Convert time from circuit timezone to selected timezone
  Future<String> convertTime({
    required DateTime dateTime,
    required String fromCircuitId,
    required String toTimezone,
  }) async {
    try {
      isLoading = true;
      errorMessage = '';
      
      // Get the circuit's timezone using CircuitRepository
      final circuit = CircuitRepository.getCircuitById(fromCircuitId);
      if (circuit == null) {
        throw Exception('Circuit not found');
      }
      
      final dateTimeString = DateFormat(_dateTimeFormat).format(dateTime);
      final response = await _apiService.convertTimezone(
        fromTimeZone: circuit.timezone,
        dateTime: dateTimeString,
        toTimeZone: toTimezone,
      );

      final convertedDateTime = DateTime.parse(
        response['conversionResult']['dateTime']
      );
      
      return DateFormat(_displayFormat).format(convertedDateTime);
    } catch (e) {
      errorMessage = 'Failed to convert time: ${e.toString()}';
      return 'Error: ${e.toString()}';
    } finally {
      isLoading = false;
    }
  }
  
  Future<String> getCurrentTimeInTimezone(String timezone) async {
    try {
      final response = await _apiService.getCurrentTime(timezone);
      
      // Parse the response directly to DateTime
      final currentTime = DateTime(
        response['year'],
        response['month'],
        response['day'],
        response['hour'],
        response['minute'],
        response['seconds'],
      );
      
      return DateFormat(_displayFormat).format(currentTime);
    } catch (e) {
      return 'Error getting current time: ${e.toString()}';
    }
  }
}