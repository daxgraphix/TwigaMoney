import 'package:twigamoney/core/widgets/input_label.dart';
import 'package:twigamoney/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:twigamoney/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/page_transitions.dart';
import '../../../billing/domain/entities/customer.dart';
import '../bloc/customer/customer_bloc.dart';

class AddCustomerPage extends StatefulWidget {
  const AddCustomerPage({super.key});

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  double _creditLimit = 0.0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final customer = Customer(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      creditLimit: _creditLimit,
    );

    context.read<CustomerBloc>().add(AddCustomerEvent(customer));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currency = Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS');
    final symbol = AppTheme.getCurrencySymbol(currency);

    return BlocListener<CustomerBloc, CustomerState>(
      listener: (context, state) {
        if (state is CustomerOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/customers');
          }
        } else if (state is CustomerError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.addCustomer, style: const TextStyle(fontWeight: FontWeight.bold)),
          leading: const BackButtonWidget(),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(Responsive.getPadding(context), 16, Responsive.getPadding(context), 100),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InputLabel(text: l10n.fullName),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: l10n.fullName,
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.nameIsRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                InputLabel(text: l10n.phoneNumber),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: l10n.phoneHint,
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.phoneNumberRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                InputLabel(text: l10n.emailAddress),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: l10n.enterValidEmail,
                    prefixIcon: const Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value.trim())) {
                        return l10n.enterValidEmail;
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                InputLabel(text: l10n.addressLine1),
                TextFormField(
                  controller: _addressController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: l10n.addressLine1Hint,
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 24),
                InputLabel(text: l10n.creditLimit),
                TextFormField(
                  initialValue: _creditLimit.toString(),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    prefixText: '$symbol ',
                    prefixIcon: const Icon(Icons.credit_card),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final limit = double.tryParse(value);
                      if (limit == null || limit < 0) {
                        return l10n.enterValidCreditLimit;
                      }
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _creditLimit = double.tryParse(value) ?? 0.0;
                  },
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: PrimaryButton(
          onPressed: _submit,
          icon: Icons.person_add,
          label: l10n.addCustomer,
        ),
      ),
    );
  }
}
