import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:twigamoney/l10n/app_localizations.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/input_label.dart';
import '../../domain/entities/shop.dart';
import '../bloc/shop_bloc.dart';

class CustomerShopSetupPage extends StatefulWidget {
  const CustomerShopSetupPage({super.key});

  @override
  State<CustomerShopSetupPage> createState() => _CustomerShopSetupPageState();
}

class _CustomerShopSetupPageState extends State<CustomerShopSetupPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _address1Controller;
  late TextEditingController _address2Controller;
  late TextEditingController _phoneController;
  late TextEditingController _upiController;
  late TextEditingController _footerController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _address1Controller = TextEditingController();
    _address2Controller = TextEditingController();
    _phoneController = TextEditingController();
    _upiController = TextEditingController();
    _footerController = TextEditingController();

    // Pre-fill from existing shop data if available
    final existingShop = HiveDatabase.shopBox.get('shop_details');
    if (existingShop != null) {
      _nameController.text = existingShop.name;
      _address1Controller.text = existingShop.addressLine1;
      _address2Controller.text = existingShop.addressLine2;
      _phoneController.text = existingShop.phoneNumber;
      _upiController.text = existingShop.upiId;
      _footerController.text = existingShop.footerText;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _phoneController.dispose();
    _upiController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  void _saveAndContinue() {
    if (_formKey.currentState!.validate()) {
      final shop = Shop(
        id: 'default_shop',
        name: _nameController.text,
        addressLine1: _address1Controller.text,
        addressLine2: _address2Controller.text,
        phoneNumber: _phoneController.text,
        upiId: _upiController.text,
        footerText: _footerController.text,
      );

      context.read<ShopBloc>().add(UpdateShopEvent(shop));
    }
  }

  void _skipAndContinue() {
    // Save minimal default shop and continue
    const defaultShop = Shop(
      id: 'default_shop',
      name: 'My Shop',
      addressLine1: 'Shop Address',
      addressLine2: '',
      phoneNumber: '',
      upiId: '',
      footerText: 'Thank you!',
    );
    context.read<ShopBloc>().add(const UpdateShopEvent(defaultShop));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<ShopBloc, ShopState>(
      listener: (context, state) {
        if (state is ShopOperationSuccess) {
          Hive.box('settings').put('onboardingComplete', true);
          if (mounted) {
            context.go('/');
          }
        } else if (state is ShopError) {
          final errorMessage = state.message == 'failedToLoadShop'
              ? l10n.failedToLoadShop
              : state.message == 'failedToUpdateShop'
                  ? l10n.failedToUpdateShop
                  : state.message;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.completeShopSetup),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Intro text
                Text(
                  l10n.shopSetupSubtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                InputLabel(text: l10n.shopName),
                _buildTextField(
                  controller: _nameController,
                  hint: l10n.shopNameHint,
                  validator: AppValidators.required(l10n.required),
                ),
                const SizedBox(height: 15),
                InputLabel(text: l10n.addressLine1),
                _buildTextField(
                  controller: _address1Controller,
                  hint: l10n.addressLine1Hint,
                  validator: AppValidators.required(l10n.required),
                ),
                const SizedBox(height: 15),
                InputLabel(text: l10n.addressLine2Optional),
                _buildTextField(
                  controller: _address2Controller,
                  hint: l10n.addressLine2Hint,
                ),
                const SizedBox(height: 15),
                InputLabel(text: l10n.phoneNumber),
                _buildTextField(
                  controller: _phoneController,
                  hint: l10n.phoneHint,
                  keyboardType: TextInputType.phone,
                  validator: AppValidators.required(l10n.required),
                ),
                const SizedBox(height: 15),
                InputLabel(text: l10n.upiPaymentId),
                _buildTextField(
                  controller: _upiController,
                  hint: l10n.upiHint,
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InputLabel(text: l10n.receiptFooter),
                    Text(l10n.maxChars(150),
                        style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                  ],
                ),
                _buildTextField(
                  controller: _footerController,
                  hint: l10n.thankYouHint,
                  maxLines: 2,
                  maxLength: 150,
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryButton(
                onPressed: _saveAndContinue,
                icon: Icons.check,
                label: l10n.saveAndContinue,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _skipAndContinue,
                child: Text(l10n.skipForNow),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization: TextCapitalization.words,
      validator: validator,
      decoration: InputDecoration(hintText: hint),
    );
  }
}

