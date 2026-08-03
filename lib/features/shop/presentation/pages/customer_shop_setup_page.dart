import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
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
    return BlocListener<ShopBloc, ShopState>(
      listener: (context, state) {
        if (state is ShopOperationSuccess) {
          Hive.box('settings').put('onboardingComplete', true);
          if (mounted) {
            context.go('/');
          }
        } else if (state is ShopError) {
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
          title: const Text('Complete Your Shop Setup'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.chevron_left,
                size: 28, color: Theme.of(context).primaryColor),
            onPressed: () { if (context.canPop()) { context.pop(); } else { context.go('/'); } },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Intro text
                const Text(
                  'Let\'s set up your shop details. This information will appear on your receipts.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                const InputLabel(text: 'Shop Name *'),
                _buildTextField(
                  controller: _nameController,
                  hint: 'e.g. QuickMart Superstore',
                  validator: AppValidators.required('Required'),
                ),
                const SizedBox(height: 15),
                const InputLabel(text: 'Address Line 1 *'),
                _buildTextField(
                  controller: _address1Controller,
                  hint: 'Street address',
                  validator: AppValidators.required('Required'),
                ),
                const SizedBox(height: 15),
                const InputLabel(text: 'Address Line 2 (Optional)'),
                _buildTextField(
                  controller: _address2Controller,
                  hint: 'City, State, PIN',
                ),
                const SizedBox(height: 15),
                const InputLabel(text: 'Phone Number *'),
                _buildTextField(
                  controller: _phoneController,
                  hint: '+91 9876543210',
                  keyboardType: TextInputType.phone,
                  validator: AppValidators.required('Required'),
                ),
                const SizedBox(height: 15),
                const InputLabel(text: 'UPI ID (Optional)'),
                _buildTextField(
                  controller: _upiController,
                  hint: 'yourname@okaxis',
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const InputLabel(text: 'Receipt Footer'),
                    Text('Max 60 chars',
                        style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                  ],
                ),
                _buildTextField(
                  controller: _footerController,
                  hint: 'Thank you, Visit again!!!',
                  maxLines: 2,
                  maxLength: 60,
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
                label: 'Save & Continue',
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _skipAndContinue,
                child: const Text('Skip for Now'),
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

