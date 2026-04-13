import 'package:flutter/material.dart';
import '../utils/hr_calculations.dart';

class SalaryCalculatorScreen extends StatefulWidget {
  const SalaryCalculatorScreen({super.key});

  @override
  State<SalaryCalculatorScreen> createState() => _SalaryCalculatorScreenState();
}

class _SalaryCalculatorScreenState extends State<SalaryCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _grossSalaryController = TextEditingController();
  final _dependentsController = TextEditingController(text: '0');
  final _otherDiscountsController = TextEditingController(text: '0.00');

  Map<String, double>? _result;

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  void _calculate() {
    if (_formKey.currentState!.validate()) {
      double grossSalary = double.tryParse(_grossSalaryController.text.replaceAll(',', '.')) ?? 0.0;
      int dependents = int.tryParse(_dependentsController.text) ?? 0;
      double otherDiscounts = double.tryParse(_otherDiscountsController.text.replaceAll(',', '.')) ?? 0.0;

      setState(() {
        _result = HRCalculations.calculateNetSalary(
          grossSalary: grossSalary,
          dependents: dependents,
          otherDiscounts: otherDiscounts,
        );
      });
      
      // Hide keyboard
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _grossSalaryController.dispose();
    _dependentsController.dispose();
    _otherDiscountsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salário Líquido'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dados do Salário',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _grossSalaryController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Salário Bruto (R\$)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe o salário bruto';
                          }
                          if (double.tryParse(value.replaceAll(',', '.')) == null) {
                            return 'Valor inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _dependentsController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Dependentes',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.people),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _otherDiscountsController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Outros Descontos',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.money_off),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _calculate,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Calcular',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 24),
              _buildResultCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resultado',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 30),
            _buildResultRow('Salário Bruto', _result!['grossSalary']!, isPositive: true),
            const SizedBox(height: 12),
            _buildResultRow('Desconto INSS', _result!['inss']!, isPositive: false),
            const SizedBox(height: 12),
            _buildResultRow('Desconto IRRF', _result!['irrf']!, isPositive: false),
            if (_result!['otherDiscounts']! > 0) ...[
              const SizedBox(height: 12),
              _buildResultRow('Outros Descontos', _result!['otherDiscounts']!, isPositive: false),
            ],
            const Divider(height: 30, thickness: 1.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Salário Líquido',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  _formatCurrency(_result!['netSalary']!),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, double value, {required bool isPositive}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          '${isPositive ? '' : '- '}${_formatCurrency(value)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isPositive ? Colors.black87 : Colors.red.shade700,
          ),
        ),
      ],
    );
  }
}
