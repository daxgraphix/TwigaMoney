import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:twigamoney/l10n/app_localizations.dart';

import '../bloc/product_bloc.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/csv_service.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/page_transitions.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Load products from repository
    context.read<ProductBloc>().add(LoadProducts());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButtonWidget(),
        title: Text(l10n.productManagement,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'export':
                  _exportProducts();
                  break;
                case 'import':
                  _importProducts();
                  break;
                case 'template':
                  _downloadTemplate();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    const Icon(Icons.download, size: 20),
                    const SizedBox(width: 8),
                    Text(l10n.exportCsv),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    const Icon(Icons.upload, size: 20),
                    const SizedBox(width: 8),
                    Text(l10n.importCsv),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'template',
                child: Row(
                  children: [
                    const Icon(Icons.description, size: 20),
                    const SizedBox(width: 8),
                    Text(l10n.downloadTemplate),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _searchController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: l10n.searchProducts,
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),

          Expanded(
            child: BlocConsumer<ProductBloc, ProductState>(
              listener: (context, state) {
                if (state.status == ProductStatus.success &&
                    state.message != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(state.message!),
                        backgroundColor: Colors.green),
                  );
                } else if (state.status == ProductStatus.error &&
                    state.message != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(state.message!),
                        backgroundColor: Colors.red),
                  );
                }
              },
              builder: (context, state) {
                if (state.status == ProductStatus.loading &&
                    state.products.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.products.isEmpty) {
                  if (state.status == ProductStatus.error) {
                    return Center(child: Text('${l10n.error}: ${state.message}'));
                  }
                  return EmptyStateWidget(
                    icon: Icons.inventory_2_outlined,
                    title: l10n.noProductsFound,
                    subtitle: l10n.addFirstProduct,
                    onActionPressed: () => context.push('/products/add'),
                    actionLabel: l10n.addProduct,
                  );
                }

                final filteredProducts = state.products
                    .where((product) =>
                        product.name.toLowerCase().contains(_searchQuery))
                    .toList();

                if (filteredProducts.isEmpty && _searchQuery.isNotEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.search_off,
                    title: l10n.noProductsMatchSearch,
                    onActionPressed: () => _searchController.clear(),
                    actionLabel: l10n.clear,
                  );
                }

                if (filteredProducts.isEmpty && _searchQuery.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.inventory_2_outlined,
                    title: l10n.noProductsFound,
                    subtitle: l10n.addFirstProduct,
                    onActionPressed: () => context.push('/products/add'),
                    actionLabel: l10n.addProduct,
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.only(
                    left: Responsive.getPadding(context),
                    right: Responsive.getPadding(context),
                    top: 16,
                    bottom: 100,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    final isLowStock = product.stock <= product.minStockThreshold;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppTheme.softShadow,
                          border: Border.all(
                            color: isLowStock 
                              ? Colors.red.withValues(alpha: 0.2) 
                              : Colors.grey.withValues(alpha: 0.05)
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  width: 6,
                                  color: isLowStock ? Colors.red : AppTheme.primaryColor,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                product.name,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              '${AppTheme.getCurrencySymbol(Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS'))}${product.price.toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.primaryColor,
                                                  fontSize: 16),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          product.category,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            _buildStockIndicator(product.stock, product.minStockThreshold),
                                            const Spacer(),
                                            _buildActionIconButton(
                                              icon: Icons.edit_outlined,
                                              color: Colors.blue,
                                              onTap: () => context.push('/products/edit/${product.id}', extra: product),
                                            ),
                                            const SizedBox(width: 8),
                                            _buildActionIconButton(
                                              icon: Icons.add_box_outlined,
                                              color: Colors.green,
                                              onTap: () => _returnItem(context, product),
                                              tooltip: l10n.restock,
                                            ),
                                            const SizedBox(width: 8),
                                            _buildActionIconButton(
                                              icon: Icons.delete_outline,
                                              color: Colors.red,
                                              onTap: () => _confirmDelete(context, product),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/products/add'),
        label: Text(l10n.addProduct, style: const TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStockIndicator(int stock, int threshold) {
    final l10n = AppLocalizations.of(context)!;
    final bool isLow = stock <= threshold;
    final color = isLow ? Colors.red : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isLow ? Icons.warning_amber_rounded : Icons.check_circle_outline, 
               size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '${l10n.stock}: $stock',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIconButton({required IconData icon, required Color color, required VoidCallback onTap, String? tooltip}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Product product) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (innerContext) {
        return AlertDialog(
          title: Text(l10n.deleteProduct),
          content: Text(l10n.confirmDeleteProduct(product.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(innerContext),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                context.read<ProductBloc>().add(DeleteProduct(product.id));
                Navigator.pop(innerContext);
              },
              child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
     );
   }

  void _returnItem(BuildContext context, Product product) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (innerContext) {
        final TextEditingController quantityController = TextEditingController(text: '1');
        return AlertDialog(
          title: Text(l10n.returnProduct(product.name)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                decoration: InputDecoration(
                  labelText: l10n.quantityToReturn,
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(innerContext),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                final quantity = int.tryParse(quantityController.text) ?? 0;
                if (quantity > 0) {
                  context.read<ProductBloc>().add(
                    UpdateStock(
                      product.id,
                      product.stock + quantity,
                    ),
                  );
                  Navigator.pop(innerContext);
                }
              },
              child: Text(l10n.restock),
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportProducts() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final state = context.read<ProductBloc>().state;
      if (state.status == ProductStatus.loaded) {
        final filePath = await CsvService.exportProducts(state.products, l10n);
        if (filePath != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.productsExportedTo(filePath)),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importProducts() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final products = await CsvService.importProducts();
      if (products.isNotEmpty && mounted) {
        // Import products
        for (final product in products) {
          context.read<ProductBloc>().add(AddProduct(product));
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.productsImportedSuccessfully(products.length)),
            backgroundColor: Colors.green,
          ),
        );

        // Reload products
        context.read<ProductBloc>().add(LoadProducts());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadTemplate() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      // For template, we'll just show a message since it's for reference
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.csvTemplate),
          content: Text(l10n.csvTemplateNote),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.success.toUpperCase()),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

