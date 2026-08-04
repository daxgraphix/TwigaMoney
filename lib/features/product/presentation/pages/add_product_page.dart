import 'package:twigamoney/core/widgets/input_label.dart';
import 'package:twigamoney/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:twigamoney/l10n/app_localizations.dart';

import '../bloc/product_bloc.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/widgets/page_transitions.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  double _price = 0.0;
  int _stock = 0;
  String _category = 'Other';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final product = Product(
        id: const Uuid().v4(),
        name: _name,
        barcode: const Uuid().v4(), // Auto-generate unique barcode
        price: _price,
        stock: _stock,
        category: _category,
        lastStockUpdate: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<ProductBloc>().add(AddProduct(product));
      if (context.canPop()) { context.pop(); } else { context.go('/'); }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Get currency symbol for price input
    final currency = Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS');
    final symbol = AppTheme.getCurrencySymbol(currency);

    return Scaffold(
        appBar: AppBar(
          leading: const BackButtonWidget(),
          title: Text(l10n.addProduct,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InputLabel(text: l10n.productName),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: l10n.productNameHint,
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: AppValidators.required(l10n.nameIsRequired), // Reuse or create specific
                    onSaved: (value) => _name = value!,
                  ),
                  const SizedBox(height: 24),
                  InputLabel(text: l10n.price),
                  TextFormField(
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: l10n.priceHint,
                      prefixText: '$symbol ',
                      prefixStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                    validator: (value) => AppValidators.price(value, context),
                    onSaved: (value) => _price = double.parse(value!),
                  ),
                  const SizedBox(height: 24),
                  InputLabel(text: l10n.stockQuantity),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: l10n.stockHint,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseEnterValidQuantity;
                      }
                      final stock = int.tryParse(value);
                      if (stock == null || stock < 0) {
                        return l10n.pleaseEnterValidQuantity;
                      }
                      return null;
                    },
                    onSaved: (value) => _stock = int.parse(value!),
                  ),
                  const SizedBox(height: 24),
                  InputLabel(text: l10n.category),
                  FormField<String>(
                    initialValue: _category,
                    builder: (FormFieldState<String> state) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          hintText: l10n.category,
                          errorText: state.errorText,
                        ),
                        child: DropdownButton<String>(
                          value: state.value,
                          items: [
                            DropdownMenuItem(value: 'Food', child: Text(l10n.categoryFood)),
                            DropdownMenuItem(value: 'Beverages', child: Text(l10n.categoryBeverages)),
                            DropdownMenuItem(value: 'Household', child: Text(l10n.categoryHousehold)),
                            DropdownMenuItem(value: 'Personal Care', child: Text(l10n.categoryPersonalCare)),
                            DropdownMenuItem(value: 'Electronics', child: Text(l10n.categoryElectronics)),
                            DropdownMenuItem(value: 'Other', child: Text(l10n.categoryOther)),
                          ],
                          onChanged: (value) {
                            state.didChange(value);
                            setState(() {
                              _category = value!;
                            });
                          },
                          isExpanded: true,
                        ),
                      );
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.category;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: PrimaryButton(
          onPressed: _submit,
          icon: Icons.add_circle,
          label: l10n.addProduct,
        ));
  }
}



