import 'package:tpm_fp/models/currency_model.dart';
import 'package:tpm_fp/network/currency_service.dart';
import 'package:tpm_fp/models/circuit_model.dart';
import 'package:tpm_fp/models/data/circuit_data.dart';

class CurrencyPresenter {
  final CurrencyService _currencyService = CurrencyService();

  Future<CurrencyConversion> convertCurrency({
    required String from,
    required String to,
    required double amount,
  }) async {
    return await _currencyService.convertCurrency(
      from: from,
      to: to,
      amount: amount,
    );
  }

  Future<SupportedCurrencies> getSupportedCurrencies() async {
    return await _currencyService.getSupportedCurrencies();
  }

  // Get default currencies
  List<String> getDefaultCurrencies() {
    return ['USD', 'EUR', 'IDR', 'JPY', 'GBP'];
  }

  // Get currency for a specific circuit using CircuitRepository
  String getCurrencyForCircuit(String circuitId) {
    return CircuitRepository.getCurrencyForCircuit(circuitId);
  }

  // Get unique list of currencies from all circuits
  List<String> getCircuitCurrencies() {
    return CircuitRepository.circuits
        .map((circuit) => circuit.currency)
        .toSet()
        .toList();
  }

  // Get circuits that use a specific currency
  List<Circuit> getCircuitsByCurrency(String currencyCode) {
    return CircuitRepository.circuits
        .where((circuit) => circuit.currency == currencyCode)
        .toList();
  }

  // Get all circuits
  List<Circuit> getAllCircuits() {
    return CircuitRepository.circuits;
  }
}