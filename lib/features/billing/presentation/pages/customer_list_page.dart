import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:twigamoney/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/page_transitions.dart';
import '../../../billing/domain/entities/customer.dart';
import '../bloc/customer/customer_bloc.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(LoadCustomersEvent());
    _searchController.addListener(() {
      context.read<CustomerBloc>().add(SearchCustomersEvent(_searchController.text));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final padding = Responsive.getPadding(context);
    final isDesktop = Responsive.isDesktop(context);

    return BlocListener<CustomerBloc, CustomerState>(
      listener: (context, state) {
        if (state is CustomerError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.failedToLoadCustomers(state.message))),
          );
        } else if (state is CustomerOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(l10n.customerManagement, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          leading: const BackButtonWidget(),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => context.read<CustomerBloc>().add(LoadCustomersEvent()),
              tooltip: l10n.refreshList,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(padding, 8, padding, 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.searchCustomerHint,
                    prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ),
              BlocBuilder<CustomerBloc, CustomerState>(
                builder: (context, state) {
                  if (state is CustomerLoaded) {
                    return _buildHeaderMetrics(state.customers);
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 8),
              Expanded(
                child: RefreshIndicator(
                  color: Theme.of(context).primaryColor,
                  onRefresh: () async {
                    context.read<CustomerBloc>().add(LoadCustomersEvent());
                  },
                  child: BlocBuilder<CustomerBloc, CustomerState>(
                    builder: (context, state) {
                      if (state is CustomerLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is CustomerLoaded) {
                        final filteredCustomers = state.filteredCustomers;
                        if (filteredCustomers.isEmpty) {
                          return _buildEmptyState(state.searchQuery);
                        }
                        return isDesktop
                            ? GridView.builder(
                                padding: EdgeInsets.all(padding),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 3,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: filteredCustomers.length,
                                itemBuilder: (context, index) => _buildModernCustomerCard(filteredCustomers[index]),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.fromLTRB(padding, 8, padding, MediaQuery.of(context).padding.bottom + 80),
                                physics: const BouncingScrollPhysics(),
                                itemCount: filteredCustomers.length,
                                itemBuilder: (context, index) => _buildModernCustomerCard(filteredCustomers[index]),
                              );
                      } else if (state is CustomerError) {
                        return Center(child: Text(state.message));
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/customers/add'),
          icon: const Icon(Icons.person_add_rounded),
          label: Text(l10n.addCustomer, style: const TextStyle(fontWeight: FontWeight.bold)),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildHeaderMetrics(List<Customer> customers) {
    final l10n = AppLocalizations.of(context)!;
    final padding = Responsive.getPadding(context);
    final currency = Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS');
    final symbol = AppTheme.getCurrencySymbol(currency);
    final totalDebt = customers.fold(0.0, (sum, c) => sum + c.currentBalance);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildMetricChip(l10n.total, customers.length.toString(), Icons.people, Colors.blue),
            const SizedBox(width: 8),
            _buildMetricChip(l10n.debt, '$symbol${totalDebt.toStringAsFixed(0)}', Icons.account_balance, Colors.red),
            const SizedBox(width: 8),
            _buildMetricChip(l10n.active, customers.where((c) => c.isActive).length.toString(), Icons.check_circle, Colors.green),
            const SizedBox(width: 8),
            _buildMetricChip(l10n.good, customers.where((c) => c.debtStatus == DebtStatus.good).length.toString(), Icons.thumb_up, Colors.indigo),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String searchQuery) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyStateWidget(
      icon: searchQuery.isEmpty ? Icons.people_outline : Icons.search_off,
      title: searchQuery.isEmpty ? l10n.noCustomersFound : l10n.noCustomersMatchSearch,
      subtitle: searchQuery.isEmpty ? l10n.addFirstCustomer : null,
      onActionPressed: searchQuery.isEmpty 
        ? () => context.push('/customers/add')
        : () => _searchController.clear(),
      actionLabel: searchQuery.isEmpty ? l10n.addCustomer : l10n.clear,
    );
  }

  Widget _buildMetricChip(String label, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernCustomerCard(Customer customer) {
    final l10n = AppLocalizations.of(context)!;
    final status = customer.debtStatus;
    final statusColor = _getDebtStatusColor(status);
    final currency = Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS');
    final symbol = AppTheme.getCurrencySymbol(currency);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showCustomerDetails(customer),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [statusColor.withValues(alpha: 0.2), statusColor.withValues(alpha: 0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone_outlined, size: 12, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            customer.phone,
                            style: TextStyle(color: Colors.grey[500], fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _getDebtStatusText(status, l10n),
                          style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$symbol${customer.currentBalance.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildActionIcon(Icons.history_rounded, () => _viewCustomerTransactions(customer)),
                        const SizedBox(width: 8),
                        _buildActionIcon(Icons.edit_rounded, () => _editCustomer(customer)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }


  void _showCustomerDetails(Customer customer) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(l10n.phone, customer.phone),
              _buildDetailRow(l10n.email, customer.email.isNotEmpty ? customer.email : l10n.notProvided),
              _buildDetailRow(l10n.creditLimit, '${AppTheme.getCurrencySymbol(Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS'))}${customer.creditLimit.toStringAsFixed(2)}'),
              _buildDetailRow(l10n.cashBalance, '${AppTheme.getCurrencySymbol(Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS'))}${customer.currentBalance.toStringAsFixed(2)}'),
              _buildDetailRow(l10n.availableCredit, '${AppTheme.getCurrencySymbol(Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS'))}${customer.availableCredit.toStringAsFixed(2)}'),
              _buildDetailRow(l10n.status, customer.isActive ? l10n.active : l10n.inactive),
              _buildDetailRow(l10n.created, _formatDate(customer.createdAt)),
              _buildDetailRow(l10n.lastTransaction, _formatDate(customer.lastTransaction)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _viewCustomerTransactions(Customer customer) {
    context.push('/customers/transactions/${customer.id}');
  }

  void _editCustomer(Customer customer) {
    context.push('/customers/edit/${customer.id}');
  }

  Color _getDebtStatusColor(DebtStatus status) {
    switch (status) {
      case DebtStatus.paid:
        return Colors.green;
      case DebtStatus.good:
        return Colors.blue;
      case DebtStatus.warning:
        return Colors.orange;
      case DebtStatus.overdue:
        return Colors.red;
    }
  }

  String _getDebtStatusText(DebtStatus status, AppLocalizations l10n) {
    switch (status) {
      case DebtStatus.paid:
        return l10n.paid;
      case DebtStatus.good:
        return l10n.good;
      case DebtStatus.warning:
        return l10n.warning;
      case DebtStatus.overdue:
        return l10n.overdue;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
