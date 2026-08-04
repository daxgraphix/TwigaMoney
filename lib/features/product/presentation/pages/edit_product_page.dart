import 'package:twigamoney/l10n/app_localizations.dart';
import 'package:twigamoney/core/widgets/input_label.dart';
import 'package:twigamoney/core/widgets/primary_button.dart';
import 'package:twigamoney/core/widgets/page_transitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../bloc/product_bloc.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_validators.dart';

class EditProductPage extends StatefulWidget {
  final Product product;
  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late double _price;

  @override
  void initState() {
    super.initState();
    _name = widget.product.name;
    _price = widget.product.price;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedProduct = Product(
        id: widget.product.id,
        name: _name,
        barcode: '',
        price: _price,
        costPrice: widget.product.costPrice,
        stock: widget.product.stock,
        minStockThreshold: widget.product.minStockThreshold,
        category: widget.product.category,
        discountPercentage: widget.product.discountPercentage,
        taxPercentage: widget.product.taxPercentage,
        lastStockUpdate: widget.product.lastStockUpdate,
        totalSold: widget.product.totalSold,
        updatedAt: DateTime.now(),
      );

      context.read<ProductBloc>().add(UpdateProduct(updatedProduct));
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
          title: Text(l10n.editProduct,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display Barcode details (immutable block)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1)),
                    ),
                  ),
                  InputLabel(text: l10n.productName),

                  TextFormField(
                    initialValue: _name,
                    textCapitalization: TextCapitalization.words,
                    validator: AppValidators.required(l10n.nameIsRequired),
                    onSaved: (value) => _name = value!,
                  ),
                  const SizedBox(height: 24),

                  InputLabel(text: l10n.price),

                  TextFormField(
                    initialValue: _price.toStringAsFixed(2),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      prefixText: '$symbol ',
                      prefixStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                    validator: (value) => AppValidators.price(value, context),
                    onSaved: (value) => _price = double.parse(value!),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: PrimaryButton(
          onPressed: _submit,
          icon: Icons.save,
          label: l10n.saveChanges,
        ));
  }
}



