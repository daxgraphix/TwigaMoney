import 'package:twigamoney/core/widgets/input_label.dart';
import 'package:twigamoney/core/widgets/primary_button.dart';
import 'package:twigamoney/core/widgets/page_transitions.dart';
import 'package:twigamoney/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/account.dart';
import '../../presentation/bloc/account_cubit.dart';
import 'package:twigamoney/l10n/app_localizations.dart';

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

    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.accountSaved),
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButtonWidget(),
        title: Text(widget.account == null ? l10n.addAccount : l10n.editAccount,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          Responsive.getPadding(context),
          16,
          Responsive.getPadding(context),
          100,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputLabel(text: l10n.accountName),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: l10n.accountNameHint,
                  prefixIcon: const Icon(Icons.label_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return l10n.required;
                  return null;
                },
              ),
              const SizedBox(height: 24),
              InputLabel(text: l10n.accountType),
              DropdownButtonFormField<AccountType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
                items: [
                  DropdownMenuItem(
                      value: AccountType.checking, child: Text(l10n.checking)),
                  DropdownMenuItem(
                      value: AccountType.savings, child: Text(l10n.savings)),
                  DropdownMenuItem(
                      value: AccountType.credit, child: Text(l10n.credit)),
                  DropdownMenuItem(
                      value: AccountType.investment,
                      child: Text(l10n.investment)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _selectedType = value);
                },
              ),
              const SizedBox(height: 24),
              InputLabel(text: l10n.balance),
              TextFormField(
                controller: _balanceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: '0.00',
                  prefixIcon: const Icon(Icons.money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return l10n.required;
                  final amount = double.tryParse(value.replaceAll(',', '.'));
                  if (amount == null) return l10n.invalidInput;
                  return null;
                },
              ),
              const SizedBox(height: 24),
              InputLabel(text: l10n.currency),
              DropdownButtonFormField<String>(
                initialValue: _currency,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.currency_exchange),
                ),
                items: [
                  DropdownMenuItem(
                      value: 'TZS', child: Text(l10n.tanzanianShilling)),
                  DropdownMenuItem(value: 'USD', child: Text(l10n.usDollar)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _currency = value);
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: PrimaryButton(
        onPressed: _submit,
        icon: widget.account == null ? Icons.add_circle : Icons.save,
        label: widget.account == null ? l10n.addAccount : l10n.saveChanges,
      ),
    );
  }
}
