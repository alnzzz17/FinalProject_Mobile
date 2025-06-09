import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:tpm_fp/network/time_convert_service.dart'; // Sesuaikan path

import 'time_convert_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('ApiService.convertTimezone', () {
    late ApiService apiService;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      apiService = ApiService(client: mockClient);
    });

    test('sends correct POST request with JSON body and headers', () async {
      final mockResponse = {
        "fromTimezone": "Europe/Amsterdam",
        "fromDateTime": "2021-03-14T17:45:00",
        "toTimeZone": "America/Los_Angeles",
        "conversionResult": {
          "year": 2021,
          "month": 3,
          "day": 14,
          "hour": 9,
          "minute": 45,
          "seconds": 0,
          "milliSeconds": 0,
          "dateTime": "2021-03-14T09:45:00",
          "date": "14/03/2021",
          "time": "09:45",
          "timeZone": "America/Los_Angeles",
          "dstActive": true
        }
      };

      // Setup mock
      when(mockClient.post(
        Uri.parse('https://timeapi.io/api/conversion/converttimezone'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fromTimeZone': 'Europe/Amsterdam',
          'dateTime': '2021-03-14 17:45:00',
          'toTimeZone': 'America/Los_Angeles',
          'dstAmbiguity': '',
        }),
      )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      final result = await apiService.convertTimezone(
        fromTimeZone: 'Europe/Amsterdam',
        dateTime: '2021-03-14 17:45:00',
        toTimeZone: 'America/Los_Angeles',
      );

      expect(result['fromTimezone'], 'Europe/Amsterdam');
      expect(result['toTimeZone'], 'America/Los_Angeles');
      expect(result['conversionResult']['hour'], 9);

      verify(mockClient.post(
        Uri.parse('https://timeapi.io/api/conversion/converttimezone'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fromTimeZone': 'Europe/Amsterdam',
          'dateTime': '2021-03-14 17:45:00',
          'toTimeZone': 'America/Los_Angeles',
          'dstAmbiguity': '',
        }),
      )).called(1);
    });

    test('throws exception on failed response', () async {
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Bad Request', 400));

      expect(
        () async => await apiService.convertTimezone(
          fromTimeZone: 'Invalid/Zone',
          dateTime: '2021-03-14 17:45:00',
          toTimeZone: 'America/Los_Angeles',
        ),
        throwsException,
      );
    });
  });
}