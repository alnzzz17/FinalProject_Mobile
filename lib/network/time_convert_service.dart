import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://timeapi.io/api/';
  static const String _availableTimezonesEndpoint = 'timezone/availabletimezones';
  static const String _convertTimezoneEndpoint = 'conversion/converttimezone';
  static const String _currentTimezone = 'Time/current/zone?timeZone=';
  static const Duration _timeoutDuration = Duration(seconds: 10);

  final http.Client client;

  // Constructor with optional client parameter for dependency injection
  ApiService({http.Client? client}) : client = client ?? http.Client();

  Future<List<String>> getAvailableTimezones() async {
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl$_availableTimezonesEndpoint'),
      ).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        return List<String>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to load timezones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while fetching timezones: $e');
    }
  }

  Future<Map<String, dynamic>> convertTimezone({
    required String fromTimeZone,
    required String dateTime,
    required String toTimeZone,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$_baseUrl$_convertTimezoneEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'fromTimeZone': fromTimeZone,
          'dateTime': dateTime,
          'toTimeZone': toTimeZone,
          'dstAmbiguity': '',
        }),
      ).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to convert timezone: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error during timezone conversion: $e');
    }
  }

  Future<Map<String, dynamic>> getCurrentTime(String timezone) async {
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl$_currentTimezone$timezone'),
      ).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get current time: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while getting current time: $e');
    }
  }
}