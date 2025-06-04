class CurrencyConversion {
  final String result;
  final String baseCode;
  final String targetCode;
  final double conversionRate;
  final double conversionResult;

  CurrencyConversion({
    required this.result,
    required this.baseCode,
    required this.targetCode,
    required this.conversionRate,
    required this.conversionResult,
  });

// Factory constructor to create an instance from JSON
  factory CurrencyConversion.fromJson(Map<String, dynamic> json) {
    return CurrencyConversion(
      result: json['result'],
      baseCode: json['base_code'],
      targetCode: json['target_code'],
      conversionRate: json['conversion_rate'].toDouble(),
      conversionResult: json['conversion_result'].toDouble(),
    );
  }
}

class SupportedCurrencies {
  final String result;
  final List<List<String>> supportedCodes;

  SupportedCurrencies({
    required this.result,
    required this.supportedCodes,
  });

  factory SupportedCurrencies.fromJson(Map<String, dynamic> json) {
    return SupportedCurrencies(
      result: json['result'],
      supportedCodes: List<List<String>>.from(
        json['supported_codes'].map((x) => List<String>.from(x)),
      ),
    );
  }
}

// A model for circuit-specific currency information
class CircuitCurrency {
  final String circuitId;
  final String circuitName;
  final String currencyCode;
  final String currencySymbol;

  CircuitCurrency({
    required this.circuitId,
    required this.circuitName,
    required this.currencyCode,
    required this.currencySymbol,
  });
}