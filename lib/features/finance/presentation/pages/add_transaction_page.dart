import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../finance/presentation/bloc/finance_bloc.dart';
import '../../../finance/presentation/bloc/transaction_bloc.dart';
import '../../../finance/domain/entities/transaction.dart';
import '../../../finance/domain/entities/category.dart';
import '../../../finance/domain/entities/account.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
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

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Transaction Type
                  const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SegmentedButton<TransactionType>(
                    segments: const [
                      ButtonSegment(
                        value: TransactionType.expense,
                        label: Text('Expense'),
                        icon: Icon(Icons.arrow_downward),
                      ),
                      ButtonSegment(
                        value: TransactionType.income,
                        label: Text('Income'),
                        icon: Icon(Icons.arrow_upward),
                      ),
                    ],
                    selected: {_type},
                    onSelectionChanged: (Set<TransactionType> selected) {
                      setState(() {
                        _type = selected.first;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Amount
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter an amount';
                      }
                      // Handle comma as decimal separator
                      final cleanedValue = value!.replaceAll(',', '.');
                      final amount = double.tryParse(cleanedValue);
                      if (amount == null || amount <= 0) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Category
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedCategoryId,
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Account
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Account',
                      border: OutlineInputBorder(),
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
                        return 'Please select an account';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date
                  ListTile(
                    title: const Text('Date'),
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
                  ElevatedButton(
                    onPressed: _saveTransaction,
                    child: const Text('Save Transaction'),
                  ),
                ],
              ),
            ),
          );
        },
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