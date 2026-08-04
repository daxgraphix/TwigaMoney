import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/account.dart';
import '../../presentation/bloc/account_cubit.dart';
import '../../../../core/widgets/page_transitions.dart';

class EditAccountPage extends StatefulWidget {
  final Account? account;

  const EditAccountPage({super.key, this.account});

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  AccountType _selectedType = AccountType.checking;
  String _currency = 'TZS';

  @override
  void initState() {
    super.initState();
    final acc = widget.account;
    _nameController = TextEditingController(text: acc?.name ?? '');
    _balanceController = TextEditingController(text: acc != null ? acc.balance.toStringAsFixed(2) : '0.00');
    _selectedType = acc?.type ?? AccountType.checking;
    _currency = acc?.currency ?? 'TZS';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final account = Account(
      id: widget.account?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      type: _selectedType,
      balance: double.tryParse(_balanceController.text.replaceAll(',', '.')) ?? 0.0,
      currency: _currency,
    );

    if (widget.account == null) {
      context.read<AccountCubit>().addAccount(account);
    } else {
      context.read<AccountCubit>().updateAccount(account);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.account == null ? 'Account created' : 'Account updated'),
        backgroundColor: Colors.green,
      ),
    );

    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/accounts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButtonWidget(),
        title: Text(widget.account == null ? 'New Account' : 'Edit Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Account Name',
                  hintText: 'e.g., Main Wallet',
                  prefixIcon: Icon(Icons.label_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Please enter an account name';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AccountType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Account Type',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: AccountType.checking, child: Text('Checking')),
                  DropdownMenuItem(value: AccountType.savings, child: Text('Savings')),
                  DropdownMenuItem(value: AccountType.credit, child: Text('Credit')),
                  DropdownMenuItem(value: AccountType.investment, child: Text('Investment')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _selectedType = value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _balanceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Initial Balance',
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a balance';
                  final amount = double.tryParse(value.replaceAll(',', '.'));
                  if (amount == null) return 'Please enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _currency,
                decoration: const InputDecoration(
                  labelText: 'Currency',
                  prefixIcon: Icon(Icons.currency_exchange),
                ),
                items: const [
                  DropdownMenuItem(value: 'TZS', child: Text('TZS (TSh)')),
                  DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _currency = value);
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(widget.account == null ? 'Create Account' : 'Update Account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
