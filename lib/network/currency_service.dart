import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tpm_fp/models/currency_model.dart';

class CurrencyService {
  static const String _apiKey = 'b9ce9115871c1790f0ae9ce3';
  static const String _baseUrl = 'https://v6.exchangerate-api.com/v6';

  Future<CurrencyConversion> convertCurrency({
    required String from,
    required String to,
    required double amount,
  }) async {
    final url = '$_baseUrl/$_apiKey/pair/$from/$to/$amount';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return CurrencyConversion.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to convert currency: ${response.statusCode}');
    }
  }

  Future<SupportedCurrencies> getSupportedCurrencies() async {
    final url = '$_baseUrl/$_apiKey/codes';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return SupportedCurrencies.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load supported currencies: ${response.statusCode}');
    }
  }

  // Fallback if the API fails or is unavailable
  Map<String, double> getHardcodedRates() {
    return {
      'USD': 1.0,
      'EUR': 0.85,
      'GBP': 0.73,
      'JPY': 110.0,
      'IDR': 14300.0,
      'QAR': 3.64,
      'ARS': 95.0,
      'MYR': 4.15,
      'THB': 32.5,
      'AUD': 1.35,
    };
  }
}