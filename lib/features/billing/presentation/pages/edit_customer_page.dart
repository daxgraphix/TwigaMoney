import 'package:twigamoney/core/widgets/input_label.dart';
import 'package:twigamoney/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:twigamoney/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/page_transitions.dart';
import '../../../billing/domain/entities/customer.dart';
import '../bloc/customer/customer_bloc.dart';

class EditCustomerPage extends StatefulWidget {
  final Customer? customer;

  const EditCustomerPage({super.key, this.customer});

  @override
  State<EditCustomerPage> createState() => _EditCustomerPageState();
}

class _EditCustomerPageState extends State<EditCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  late double _creditLimit;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name ?? '');
    _emailController = TextEditingController(text: widget.customer?.email ?? '');
    _phoneController = TextEditingController(text: widget.customer?.phone ?? '');
    _addressController = TextEditingController(text: widget.customer?.address ?? '');
    _creditLimit = widget.customer?.creditLimit ?? 0.0;
    _isActive = widget.customer?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate() || widget.customer == null) return;

    final updatedCustomer = widget.customer!.copyWith(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      creditLimit: _creditLimit,
      isActive: _isActive,
    );

    context.read<CustomerBloc>().add(UpdateCustomerEvent(updatedCustomer));
  }

  void _delete() {
    if (widget.customer == null) return;
    context.read<CustomerBloc>().add(DeleteCustomerEvent(widget.customer!.id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currency = Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS');
    final symbol = AppTheme.getCurrencySymbol(currency);

    if (widget.customer == null) {
      return Scaffold(
        appBar: AppBar(
          leading: const BackButtonWidget(),
          title: Text(l10n.editCustomer, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: const Center(child: Text('Customer not found')),
      );
    }

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
          leading: const BackButtonWidget(),
          title: Text(l10n.editCustomer, style: const TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text(l10n.deleteCustomer),
                    content: Text(l10n.confirmDeleteCustomer(widget.customer?.name ?? '')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _delete();
                        },
                        child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
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
                InputLabel(text: l10n.email),
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
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(l10n.active),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: PrimaryButton(
          onPressed: _submit,
          icon: Icons.save,
          label: l10n.updateCustomer,
        ),
      ),
    );
  }
}
