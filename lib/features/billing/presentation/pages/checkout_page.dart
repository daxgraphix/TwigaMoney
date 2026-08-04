import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:hive/hive.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/page_transitions.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../bloc/billing_bloc.dart';

import '../../../../core/data/hive_database.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (didPop) return;
          // Don't clear cart on back, user might want to edit
          context.pop();
        },
        child: Scaffold(
          appBar: AppBar(
            leading: const BackButtonWidget(),
            title: Text(AppLocalizations.of(context)!.checkout,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: BlocConsumer<BillingBloc, BillingState>(
            listener: (context, state) {
              final l10n = AppLocalizations.of(context)!;
              if (state.saleCompleted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(l10n.success),
                    backgroundColor: Colors.green));
                context.go('/');
              } else if (state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.error!),
                    backgroundColor: Colors.red));
              }
            },
            builder: (context, billingState) {
              final l10n = AppLocalizations.of(context)!;
              return BlocBuilder<ShopBloc, ShopState>(
                  builder: (context, shopState) {
                String upiId = '';
                String shopName = 'Shop';

                if (shopState is ShopLoaded) {
                  upiId = shopState.shop.upiId;
                  shopName = shopState.shop.name;
                }

                final currency = Hive.box('settings')
                    .get('selectedCurrency', defaultValue: 'TZS');
                final symbol = AppTheme.getCurrencySymbol(currency);
                final rate = AppTheme.getExchangeRate(currency);
                final convertedTotal = billingState.totalAmount * rate;

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Summary Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: AppTheme.softShadow,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    l10n.totalAmount,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$symbol${convertedTotal.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 42,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.itemsInCart(billingState.cartItems.length),
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            Text(
                              l10n.orderDetails,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            
                            // Itemized List
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isDark ? AppTheme.darkBorderColor : Colors.grey.shade100),
                              ),
                              child: Column(
                                children: [
                                  ...billingState.cartItems.map((item) {
                                    final itemPrice = item.product.price * rate;
                                    final itemTotal = item.total * rate;
                                    return Column(
                                      children: [
                                        ListTile(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                          title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                          subtitle: Text('$itemPrice × ${item.quantity}'),
                                          trailing: Text(
                                            '$symbol${itemTotal.toStringAsFixed(0)}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                        ),
                                        if (item != billingState.cartItems.last)
                                          Divider(height: 1, indent: 20, endIndent: 20, color: isDark ? AppTheme.darkBorderColor : Colors.grey.shade100),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),
                            
                            if (upiId.isNotEmpty) ...[
                               Center(
                                 child: Column(
                                   children: [
                                     Text(
                                       l10n.scanToPay,
                                       style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                     ),
                                     const SizedBox(height: 16),
                                     Container(
                                       padding: const EdgeInsets.all(16),
                                       decoration: BoxDecoration(
                                         color: Colors.white,
                                         borderRadius: BorderRadius.circular(20),
                                         boxShadow: AppTheme.softShadow,
                                       ),
                                       child: PrettyQrView.data(
                                         data: 'upi://pay?pa=$upiId&pn=$shopName&am=${convertedTotal.toStringAsFixed(2)}&cu=$currency',
                                         decoration: const PrettyQrDecoration(
                                           shape: PrettyQrSmoothSymbol(),
                                         ),
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                               const SizedBox(height: 40),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Payment Action Bar
                    Container(
                      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 20),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, -5),
                          ),
                        ],
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final useVerticalLayout = constraints.maxWidth < 320;
                          
                          final printButton = OutlinedButton(
                            onPressed: () {
                              // Could add a "Print Receipt" toggle here
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(56),
                            ),
                            child: Text(l10n.printReceipt),
                          );

                          final completeButton = ElevatedButton.icon(
                            onPressed: billingState.isProcessingSale ? null : () {
                              final currentShiftId = HiveDatabase.settingsBox.get('currentShiftId', defaultValue: 'sale_${DateTime.now().millisecondsSinceEpoch}');
                              context.read<BillingBloc>().add(
                                    CompleteSaleEvent(
                                      shiftId: currentShiftId,
                                    ),
                                  );
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(56),
                            ),
                            icon: const Icon(Icons.check_circle_rounded),
                            label: FittedBox(
                              child: Text(billingState.isProcessingSale ? l10n.processing : l10n.completeSale),
                            ),
                          );

                          if (useVerticalLayout) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                completeButton,
                                const SizedBox(height: 12),
                                printButton,
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(
                                child: printButton,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: completeButton,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              });
            },

          ),
        ));
  }
}
