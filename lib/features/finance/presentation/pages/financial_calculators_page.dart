import 'dart:math';

import 'package:flutter/material.dart';
import 'package:twigamoney/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/widgets/page_transitions.dart';

class FinancialCalculatorsPage extends StatefulWidget {
  const FinancialCalculatorsPage({super.key});

  @override
  State<FinancialCalculatorsPage> createState() =>
      _FinancialCalculatorsPageState();
}

class _FinancialCalculatorsPageState extends State<FinancialCalculatorsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currency = HiveDatabase.settingsBox
        .get('selectedCurrency', defaultValue: 'TZS') as String;
    final symbol = AppTheme.getCurrencySymbol(currency);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButtonWidget(),
        title: Text(l10n.financialTools,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: [
            Tab(text: l10n.emergencyFundCalculator),
            Tab(text: l10n.goalTracker),
            Tab(text: l10n.retirementPlanner),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _EmergencyFundCalculator(symbol: symbol),
          _GoalTracker(symbol: symbol),
          _RetirementPlanner(symbol: symbol),
        ],
      ),
    );
  }
}

class _EmergencyFundCalculator extends StatefulWidget {
  final String symbol;
  const _EmergencyFundCalculator({required this.symbol});

  @override
  State<_EmergencyFundCalculator> createState() =>
      _EmergencyFundCalculatorState();
}

class _EmergencyFundCalculatorState extends State<_EmergencyFundCalculator> {
  final _monthlyExpensesController = TextEditingController();
  final _emergencyFundController = TextEditingController();
  double? _monthsOfCoverage;

  void _calculate() {
    final expenses = double.tryParse(_monthlyExpensesController.text) ?? 0;
    final fund = double.tryParse(_emergencyFundController.text) ?? 0;
    setState(() {
      _monthsOfCoverage = expenses > 0 ? fund / expenses : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _CalculatorLayout(
      symbol: widget.symbol,
      inputFields: [
        _buildTextField(l10n.monthlyExpenses, _monthlyExpensesController, widget.symbol),
        _buildTextField(l10n.emergencyFund, _emergencyFundController, widget.symbol),
      ],
      calculateLabel: l10n.calculate,
      onCalculate: _calculate,
      result: _monthsOfCoverage == null
          ? null
          : '${_monthsOfCoverage!.toStringAsFixed(1)} ${l10n.monthsOfCoverage}',
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String symbol) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.currency_exchange),
        hintText: '0.00',
      ),
    );
  }

  @override
  void dispose() {
    _monthlyExpensesController.dispose();
    _emergencyFundController.dispose();
    super.dispose();
  }
}

class _GoalTracker extends StatefulWidget {
  final String symbol;
  const _GoalTracker({required this.symbol});

  @override
  State<_GoalTracker> createState() => _GoalTrackerState();
}

class _GoalTrackerState extends State<_GoalTracker> {
  final _targetController = TextEditingController();
  final _currentController = TextEditingController();
  final _monthlyContributionController = TextEditingController();
  double? _monthsToGoal;

  void _calculate() {
    final target = double.tryParse(_targetController.text) ?? 0;
    final current = double.tryParse(_currentController.text) ?? 0;
    final monthly = double.tryParse(_monthlyContributionController.text) ?? 0;
    setState(() {
      _monthsToGoal = monthly > 0 ? (target - current) / monthly : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _CalculatorLayout(
      symbol: widget.symbol,
      inputFields: [
        _buildTextField(l10n.targetAmount, _targetController),
        _buildTextField(l10n.currentAmount, _currentController),
        _buildTextField(l10n.monthlyContribution, _monthlyContributionController),
      ],
      calculateLabel: l10n.calculate,
      onCalculate: _calculate,
      result: _monthsToGoal == null
          ? null
          : _monthsToGoal! < 0
              ? 'Goal reached!'
              : '${_monthsToGoal!.toStringAsFixed(1)} ${l10n.monthsToGoal}',
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.currency_exchange),
        hintText: '0.00',
      ),
    );
  }

  @override
  void dispose() {
    _targetController.dispose();
    _currentController.dispose();
    _monthlyContributionController.dispose();
    super.dispose();
  }
}

class _RetirementPlanner extends StatefulWidget {
  final String symbol;
  const _RetirementPlanner({required this.symbol});

  @override
  State<_RetirementPlanner> createState() => _RetirementPlannerState();
}

class _RetirementPlannerState extends State<_RetirementPlanner> {
  final _currentAgeController = TextEditingController();
  final _retirementAgeController = TextEditingController();
  final _monthlyExpensesController = TextEditingController();
  final _currentSavingsController = TextEditingController();
  final _annualReturnController = TextEditingController(text: '7');
  double? _projectedSavings;
  double? _investmentNeeded;

  void _calculate() {
    final currentAge = double.tryParse(_currentAgeController.text) ?? 0;
    final retirementAge = double.tryParse(_retirementAgeController.text) ?? 0;
    final monthlyExpenses = double.tryParse(_monthlyExpensesController.text) ?? 0;
    final currentSavings = double.tryParse(_currentSavingsController.text) ?? 0;
    final annualReturn = double.tryParse(_annualReturnController.text) ?? 0;

    final years = retirementAge - currentAge;
    if (years <= 0 || monthlyExpenses <= 0) {
      setState(() {
        _projectedSavings = null;
        _investmentNeeded = null;
      });
      return;
    }

    final months = years * 12;
    final monthlyReturn = annualReturn / 12 / 100;
    final growthFactor = pow(1 + monthlyReturn, months);

    final requiredFund = monthlyExpenses * 25;
    final futureValueOfCurrent = currentSavings * growthFactor;
    final monthlyInvestmentNeeded = monthlyReturn > 0
        ? (requiredFund - futureValueOfCurrent) * monthlyReturn /
            (growthFactor - 1)
        : (requiredFund - futureValueOfCurrent) / months;

    setState(() {
      _investmentNeeded = monthlyInvestmentNeeded > 0 ? monthlyInvestmentNeeded : 0;
      _projectedSavings = requiredFund;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final symbol = widget.symbol;
    return _CalculatorLayout(
      symbol: symbol,
      inputFields: [
        _buildTextField(l10n.currentAge, _currentAgeController,TextInputType.number),
        _buildTextField(l10n.retirementAge, _retirementAgeController, TextInputType.number),
        _buildTextField(l10n.monthlyExpenses, _monthlyExpensesController, const TextInputType.numberWithOptions(decimal: true)),
        _buildTextField(l10n.currentAmount, _currentSavingsController, const TextInputType.numberWithOptions(decimal: true)),
        _buildTextField(l10n.expectedReturn, _annualReturnController, const TextInputType.numberWithOptions(decimal: true)),
      ],
      calculateLabel: l10n.calculate,
      onCalculate: _calculate,
      result: _projectedSavings == null
          ? null
          : '$symbol${_projectedSavings!.toStringAsFixed(0)} ${l10n.projectedSavings}',
      secondaryResult: _investmentNeeded == null
          ? null
          : '$symbol${_investmentNeeded!.toStringAsFixed(0)} ${l10n.investmentNeeded}',
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, TextInputType type) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.person),
        hintText: '0',
      ),
    );
  }

  @override
  void dispose() {
    _currentAgeController.dispose();
    _retirementAgeController.dispose();
    _monthlyExpensesController.dispose();
    _currentSavingsController.dispose();
    _annualReturnController.dispose();
    super.dispose();
  }
}

class _CalculatorLayout extends StatelessWidget {
  final String symbol;
  final List<Widget> inputFields;
  final String calculateLabel;
  final VoidCallback onCalculate;
  final String? result;
  final String? secondaryResult;

  const _CalculatorLayout({
    required this.symbol,
    required this.inputFields,
    required this.calculateLabel,
    required this.onCalculate,
    this.result,
    this.secondaryResult,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...inputFields.expand((field) => [field, const SizedBox(height: 16)]),
          ElevatedButton(
            onPressed: onCalculate,
            child: Text(calculateLabel),
          ),
          if (result != null) ...[
            const SizedBox(height: 24),
            _buildResultCard(result!, Colors.green),
            if (secondaryResult != null) ...[
              const SizedBox(height: 12),
              _buildResultCard(secondaryResult!, Colors.blue),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildResultCard(String text, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
