import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../finance/presentation/bloc/finance_bloc.dart';
import '../../../finance/presentation/bloc/transaction_bloc.dart';
import '../../../finance/domain/entities/transaction.dart';
import '../../../finance/domain/entities/category.dart';
import '../../../finance/domain/entities/account.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/page_transitions.dart';
import '../../../../core/widgets/primary_button.dart';
import 'package:hive/hive.dart';

import 'package:twigamoney/l10n/app_localizations.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  TransactionType _type = TransactionType.expense;
  String? _selectedCategoryId;
  String? _selectedAccountId;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currency = Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS');
    final symbol = AppTheme.getCurrencySymbol(currency);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButtonWidget(),
        title: Text(l10n.addTransaction, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<FinanceBloc, FinanceState>(
        builder: (context, state) {
          List<Category> categories = [];
          List<Account> accounts = [];

          if (state is CategoriesLoaded) {
            categories = state.categories;
          }
          if (state is AccountsLoaded) {
            accounts = state.accounts;
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Transaction Type
                Text(l10n.type, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SegmentedButton<TransactionType>(
                  segments: [
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text(l10n.expenses),
                      icon: const Icon(Icons.arrow_downward),
                    ),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text(l10n.income),
                      icon: const Icon(Icons.arrow_upward),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (Set<TransactionType> selected) {
                    setState(() {
                      _type = selected.first;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: l10n.description,
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return l10n.required;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Amount
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: l10n.amount,
                    prefixText: '$symbol ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return l10n.required;
                    }
                    // Handle comma as decimal separator
                    final cleanedValue = value!.replaceAll(',', '.');
                    final amount = double.tryParse(cleanedValue);
                    if (amount == null || amount <= 0) {
                      return l10n.invalidInput;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: l10n.category,
                  ),
                  initialValue: _selectedCategoryId,
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Row(
                        children: [
                          Icon(category.icon, color: category.color, size: 20),
                          const SizedBox(width: 10),
                          Text(category.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return l10n.pleaseSelectCategory;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Account
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: l10n.accounts,
                  ),
                  initialValue: _selectedAccountId,
                  items: accounts.map((account) {
                    return DropdownMenuItem(
                      value: account.id,
                      child: Text(account.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAccountId = value;
                    });
                  },
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return l10n.pleaseEnterValidAmount; // Or l10n.required
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.date),
                  subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                      });
                    }
                  },
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: PrimaryButton(
        onPressed: _saveTransaction,
        icon: Icons.save,
        label: l10n.save,
      ),
    );
  }

  void _saveTransaction() {
    if (_formKey.currentState?.validate() ?? false) {
      final transaction = Transaction(
        id: const Uuid().v4(),
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        categoryId: _selectedCategoryId!,
        accountId: _selectedAccountId!,
        type: _type,
      );

      context.read<TransactionBloc>().add(AddTransactionEvent(transaction));
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}