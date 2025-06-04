import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tpm_fp/models/circuit_model.dart';
import 'package:tpm_fp/presenters/currency_presenter.dart';

class CurrencyScreen extends StatefulWidget {
  @override
  _CurrencyScreenState createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final CurrencyPresenter _presenter = CurrencyPresenter();
  final TextEditingController _amountController = TextEditingController();
  final int _maxInputLength = 20;
  
  double _convertedAmount = 0.0;
  double _conversionRate = 0.0;
  bool _isLoading = false;
  String _selectedFromCurrency = 'USD';
  String _selectedToCurrency = 'IDR';
  Circuit? _selectedCircuit;
  List<String> _currencies = [];
  List<String> _defaultCurrencies = [];
  List<Circuit> _circuits = [];

  @override
  void initState() {
    super.initState();
    _defaultCurrencies = _presenter.getDefaultCurrencies();
    _circuits = _presenter.getAllCircuits();
    _loadSupportedCurrencies();
    _amountController.addListener(() => setState(() {}));
  }

  Future<void> _loadSupportedCurrencies() async {
    setState(() => _isLoading = true);
    try {
      final supportedCurrencies = await _presenter.getSupportedCurrencies();
      setState(() {
        _currencies = supportedCurrencies.supportedCodes
            .map((codePair) => codePair[0])
            .toList();
        if (_circuits.isNotEmpty) {
          _selectedToCurrency = _presenter.getCurrencyForCircuit(_circuits.first.id);
        }
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load currencies: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      setState(() => _currencies = _defaultCurrencies);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _convertCurrency() async {
    if (_amountController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter an amount',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      Get.snackbar(
        'Error',
        'Please enter a valid number',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _presenter.convertCurrency(
        from: _selectedFromCurrency,
        to: _selectedToCurrency,
        amount: amount,
      );
      setState(() {
        _convertedAmount = result.conversionResult;
        _conversionRate = result.conversionRate;
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to convert currency: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Currency Converter',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading && _currencies.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildConverterCard(),
                  if (_conversionRate > 0) ...[
                    const SizedBox(height: 20),
                    _buildResultCard(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildConverterCard() {
    return Card(
      color: Colors.grey[900],
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAmountField(),
            const SizedBox(height: 16),
            _buildCircuitDropdown(),
            const SizedBox(height: 16),
            _buildCurrencyDropdowns(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _convertCurrency,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'CONVERT',
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

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amount',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            hintText: 'Enter amount to convert',
            hintStyle: const TextStyle(color: Colors.white54),
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
            prefixIcon: const Icon(Icons.money, color: Colors.white70),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            LengthLimitingTextInputFormatter(_maxInputLength),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              '${_amountController.text.length}/$_maxInputLength characters',
              style: TextStyle(
                color: _amountController.text.length == _maxInputLength
                    ? Colors.red
                    : Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircuitDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Circuit Location',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Circuit>(
          isExpanded: true,
          value: _selectedCircuit,
          dropdownColor: Colors.grey[900],
          style: const TextStyle(color: Colors.white),
          hint: const Text(
            'Select a circuit location',
            style: TextStyle(color: Colors.white70),
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
          items: _circuits.map((circuit) {
            return DropdownMenuItem<Circuit>(
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
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (circuit) {
            if (circuit != null) {
              setState(() {
                _selectedCircuit = circuit;
                _selectedToCurrency = _presenter.getCurrencyForCircuit(circuit.id);
                _convertedAmount = 0.0;
                _conversionRate = 0.0;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildCurrencyDropdowns() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'From Currency',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedFromCurrency,
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                items: _currencies
                    .map((currency) => DropdownMenuItem(
                          value: currency,
                          child: Text(
                            currency,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedFromCurrency = value!);
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(Icons.swap_horiz, color: Colors.white),
          onPressed: () {
            if (_selectedCircuit != null) {
              setState(() {
                final temp = _selectedFromCurrency;
                _selectedFromCurrency = _selectedToCurrency;
                _selectedToCurrency = temp;
              });
            }
          },
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'To Currency',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedToCurrency,
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                items: _presenter
                    .getCircuitCurrencies()
                    .map((currency) => DropdownMenuItem(
                          value: currency,
                          child: Text(
                            currency,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedToCurrency = value!);
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard() {
    return Card(
      color: Colors.grey[900],
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '${_amountController.text} $_selectedFromCurrency =',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            Text(
              '${_convertedAmount.toStringAsFixed(2)} $_selectedToCurrency',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '1 $_selectedFromCurrency = ${_conversionRate.toStringAsFixed(6)} $_selectedToCurrency',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            if (_selectedCircuit != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Currency for ${_selectedCircuit!.location}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}