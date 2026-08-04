import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/hive_database.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../bloc/billing_bloc.dart';
import '../../../../core/widgets/back_button_widget.dart';

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

  // ignore: unused_field
  bool _isQuickScanMode = false;

  void _addManualToCart() {
    final name = _productNameController.text.trim();
    final priceStr = _priceController.text.replaceAll(',', '');
    final price = double.tryParse(priceStr) ?? 0;
    final qty = int.tryParse(_qtyController.text) ?? 1;
    final discountPercent = double.tryParse(_discountController.text) ?? 0;
    
    final l10n = AppLocalizations.of(context)!;
    if (name.isEmpty && _selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectProductMessage)),
      );
      return;
    }

    if (price <= 0) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterValidPriceMessage)),
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
          category: l10n.manualCategory,
          updatedAt: DateTime.now(),
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
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.productAddedToCart),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }


  Widget _buildQtyButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
    Color? color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 24,
            color: color ?? (isDark ? Colors.white70 : Colors.grey.shade700),
          ),
        ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, productState) {
        if (productState.status == ProductStatus.loaded) {
          _availableProducts = productState.products;
        }
        
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.newSale, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            leading: const BackButtonWidget(),
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
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: AppTheme.softShadow,
                          border: Border.all(
                            color: isDark ? AppTheme.darkBorderColor : Colors.grey.shade100,
                          ),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.addItem,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppTheme.secondaryColor,
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Product Selection / Search
                            Autocomplete<Product>(
                              displayStringForOption: (Product p) => p.name,
                              optionsBuilder: (TextEditingValue textEditingValue) {
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
                                    hintText: l10n.searchProductHint,
                                    prefixIcon: const Icon(Icons.search),
                                    filled: true,
                                    fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
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
                            const SizedBox(height: 20),
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
                                  child: ElevatedButton.icon(
                                    onPressed: _addManualToCart,
                                    icon: const Icon(Icons.add_shopping_cart, size: 20),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                    ),
                                    label: Text(l10n.addToCart),
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
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = billingState.cartItems[index];
                            return Dismissible(
                              key: Key('cart_${item.product.id}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 28),
                              ),
                              onDismissed: (direction) {
                                context.read<BillingBloc>().add(RemoveProductFromCartEvent(item.product.id));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isDark ? AppTheme.darkBorderColor : Colors.grey.shade200,
                                    width: 1,
                                  ),
                                  boxShadow: AppTheme.softShadow,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // Product Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.product.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '$symbol${item.product.price.toStringAsFixed(0)}',
                                              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey.shade600, fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Quantity Controls
                                      Container(
                                        decoration: BoxDecoration(
                                          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Row(
                                          children: [
                                            _buildQtyButton(
                                              icon: Icons.remove,
                                              onPressed: () {
                                                if (item.quantity > 1) {
                                                  context.read<BillingBloc>().add(UpdateQuantityEvent(item.product.id, item.quantity - 1));
                                                } else {
                                                  context.read<BillingBloc>().add(RemoveProductFromCartEvent(item.product.id));
                                                }
                                              },
                                              isDark: isDark,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              child: Text(
                                                '${item.quantity}',
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                              ),
                                            ),
                                            _buildQtyButton(
                                              icon: Icons.add,
                                              onPressed: () {
                                                context.read<BillingBloc>().add(UpdateQuantityEvent(item.product.id, item.quantity + 1));
                                              },
                                              isDark: isDark,
                                              color: primary,
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      const SizedBox(width: 16),
                                      
                                      // Total for this item
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '$symbol${item.total.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: primary,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => context.push('/checkout'),
                              icon: const Icon(Icons.arrow_forward),
                              label: Text(l10n.proceedToCheckout),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
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
