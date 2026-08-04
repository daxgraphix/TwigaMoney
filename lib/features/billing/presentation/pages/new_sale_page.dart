import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/hive_database.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../bloc/billing_bloc.dart';

class NewSalePage extends StatefulWidget {
  const NewSalePage({super.key});

  @override
  State<NewSalePage> createState() => _NewSalePageState();
}

class _NewSalePageState extends State<NewSalePage> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController(text: '1');
  final TextEditingController _discountController = TextEditingController(text: '0');
  final TextEditingController _notesController = TextEditingController();
  String? _selectedProductId;
  List<Product> _availableProducts = [];

  @override
  void initState() {
    super.initState();
    // Load products for selection dropdown
    context.read<ProductBloc>().add(LoadProducts());
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addManualToCart() {
    final name = _productNameController.text.trim();
    final price = double.tryParse(_priceController.text) ?? 0;
    final qty = int.tryParse(_qtyController.text) ?? 1;
    final discountPercent = double.tryParse(_discountController.text) ?? 0;
    
    if ((name.isEmpty && _selectedProductId == null) || price <= 0 || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid product name and price'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final productName = name.isNotEmpty ? name : 
        _availableProducts.firstWhere((p) => p.id == _selectedProductId, orElse: () => Product.empty()).name;
    
    // Calculate effective price after discount for the item
    final discountAmount = (price * qty) * (discountPercent.clamp(0, 100) / 100);
    final discountedTotal = (price * qty) - discountAmount;
    final effectiveUnitPrice = qty > 0 ? discountedTotal / qty : price;
    
    final productToAdd = _selectedProductId != null 
      ? _availableProducts.firstWhere((p) => p.id == _selectedProductId).copyWith(price: effectiveUnitPrice)
      : Product(
          id: 'manual_${DateTime.now().millisecondsSinceEpoch}',
          name: productName,
          barcode: '',
          price: effectiveUnitPrice,
          costPrice: effectiveUnitPrice,
          stock: 999,
          lastStockUpdate: DateTime.now(),
          category: 'Manual',
        );

    context
        .read<BillingBloc>()
        .add(AddProductToCartEvent(productToAdd, quantity: qty));
        
    setState(() {
      _productNameController.clear();
      _priceController.clear();
      _qtyController.text = '1';
      _discountController.text = '0';
      _notesController.clear();
      _selectedProductId = null;
    });
    
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.productAddedToCart),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final billingState = context.watch<BillingBloc>().state;
    final currency =
        HiveDatabase.settingsBox.get('selectedCurrency', defaultValue: 'TZS');
    final symbol = AppTheme.getCurrencySymbol(currency);
    final primary = AppTheme.primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, productState) {
        if (productState.status == ProductStatus.loaded) {
          _availableProducts = productState.products;
        }
        
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.newSale, style: const TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              if (billingState.cartItems.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    onPressed: () {
                      context.read<BillingBloc>().add(ClearCartEvent());
                    },
                    icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
                    tooltip: l10n.clearAll,
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Item Selection Section ---
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppTheme.softShadow,
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.addItem,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                IconButton.filledTonal(
                                  onPressed: () {
                                    // Placeholder for barcode scanner
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Barcode scanner coming soon!')),
                                    );
                                  },
                                  icon: const Icon(Icons.qr_code_scanner),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Product Autocomplete / Search
                            Autocomplete<Product>(
                              displayStringForOption: (Product p) => p.name,
                              optionsBuilder: (TextEditingValue textEditingValue) {
                                if (textEditingValue.text == '') {
                                  return const Iterable<Product>.empty();
                                }
                                return _availableProducts.where((Product p) {
                                  return p.name.toLowerCase().contains(textEditingValue.text.toLowerCase());
                                });
                              },
                              onSelected: (Product p) {
                                setState(() {
                                  _selectedProductId = p.id;
                                  _productNameController.text = p.name;
                                  _priceController.text = p.price.toStringAsFixed(0);
                                });
                              },
                              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                                return TextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  decoration: InputDecoration(
                                    labelText: l10n.searchProduct,
                                    hintText: 'Start typing...',
                                    prefixIcon: const Icon(Icons.search),
                                    suffixIcon: controller.text.isNotEmpty 
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            controller.clear();
                                            setState(() {
                                              _selectedProductId = null;
                                              _productNameController.clear();
                                              _priceController.clear();
                                            });
                                          },
                                        )
                                      : null,
                                  ),
                                  onChanged: (val) {
                                    _productNameController.text = val;
                                    if (_selectedProductId != null) {
                                      setState(() => _selectedProductId = null);
                                    }
                                  },
                                );
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: _priceController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: '${l10n.price} ($symbol)',
                                      prefixIcon: const Icon(Icons.payments_outlined),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 1,
                                  child: TextField(
                                    controller: _qtyController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: l10n.qty,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _discountController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: l10n.discountPercent,
                                      prefixIcon: const Icon(Icons.percent, size: 20),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _addManualToCart,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    child: Text(l10n.addToCart),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // --- Cart Section ---
                      if (billingState.cartItems.isNotEmpty) ...[
                        Text(
                          l10n.currentCart,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: billingState.cartItems.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = billingState.cartItems[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isDark ? AppTheme.darkBorderColor : Colors.grey.shade200),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('$symbol${item.product.price.toStringAsFixed(0)} × ${item.quantity}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$symbol${item.total.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: primary,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                                      onPressed: () {
                                        if (item.quantity > 1) {
                                          context.read<BillingBloc>().add(UpdateQuantityEvent(item.product.id, item.quantity - 1));
                                        } else {
                                          context.read<BillingBloc>().add(RemoveProductFromCartEvent(item.product.id));
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add_circle_outline, color: primary),
                                      onPressed: () {
                                        context.read<BillingBloc>().add(UpdateQuantityEvent(item.product.id, item.quantity + 1));
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ] else ...[
                        Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 40),
                              Icon(Icons.shopping_basket_outlined, size: 64, color: Colors.grey.withValues(alpha: 0.5)),
                              const SizedBox(height: 16),
                              Text(
                                l10n.cartIsEmpty,
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              // --- Bottom Summary ---
              if (billingState.cartItems.isNotEmpty)
                Container(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.total, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          Text(
                            '$symbol${billingState.totalAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.save),
                              label: Text(l10n.quickSave),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => context.push('/checkout'),
                              icon: const Icon(Icons.arrow_forward),
                              label: Text(l10n.proceedToCheckout),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );

  }
}
