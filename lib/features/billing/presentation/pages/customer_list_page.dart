import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../billing/domain/entities/customer.dart';
import '../../../billing/domain/repositories/customer_repository.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Customer> _customers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);
    try {
      final customerRepo = context.read<CustomerRepository>();
      final result = await customerRepo.getCustomers();

      result.fold(
        (failure) {
          if (mounted) {
            final l10n = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.failedToLoadCustomers(failure.toString()))),
            );
          }
        },
        (customers) {
          if (mounted) {
            setState(() {
              _customers = customers;
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorLoadingCustomers(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filteredCustomers = _customers.where((customer) {
      return customer.name.toLowerCase().contains(_searchQuery) ||
             customer.phone.toLowerCase().contains(_searchQuery) ||
             customer.email.toLowerCase().contains(_searchQuery);
    }).toList();

    final padding = Responsive.getPadding(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customerManagement, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Theme.of(context).primaryColor),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCustomers,
            tooltip: l10n.refreshList,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(padding),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchCustomerHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
            _buildHeaderMetrics(),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadCustomers,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredCustomers.isEmpty
                        ? _buildEmptyState()
                        : isDesktop
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
                                padding: EdgeInsets.only(
                                  left: padding,
                                  right: padding,
                                  bottom: MediaQuery.of(context).padding.bottom + 80,
                                ),
                                physics: const BouncingScrollPhysics(),
                                itemCount: filteredCustomers.length,
                                itemBuilder: (context, index) => _buildModernCustomerCard(filteredCustomers[index]),
                              ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/customers/add'),
        icon: const Icon(Icons.person_add),
        label: Text(l10n.addCustomer),
      ),
    );
  }

  Widget _buildHeaderMetrics() {
    final l10n = AppLocalizations.of(context)!;
    final padding = Responsive.getPadding(context);
    final currency = Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS');
    final symbol = AppTheme.getCurrencySymbol(currency);
    final totalDebt = _customers.fold(0.0, (sum, c) => sum + c.currentBalance);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildMetricChip(l10n.total, _customers.length.toString(), Icons.people, Colors.blue),
            const SizedBox(width: 8),
            _buildMetricChip(l10n.debt, '$symbol${totalDebt.toStringAsFixed(0)}', Icons.account_balance, Colors.red),
            const SizedBox(width: 8),
            _buildMetricChip(l10n.active, _customers.where((c) => c.isActive).length.toString(), Icons.check_circle, Colors.green),
            const SizedBox(width: 8),
            _buildMetricChip(l10n.good, _customers.where((c) => c.debtStatus == DebtStatus.good).length.toString(), Icons.thumb_up, Colors.indigo),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty ? l10n.noProductsFound : l10n.noProductsMatchSearch,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                if (_searchQuery.isNotEmpty)
                  TextButton(
                    onPressed: () => _searchController.clear(),
                    child: Text(l10n.clearCache),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricChip(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: color.withValues(alpha: 0.7),
                  fontSize: 10,
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
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: () => _showCustomerDetails(customer),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
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
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.phone,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
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
                      fontSize: 18,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildActionIcon(Icons.history, () => _viewCustomerTransactions(customer)),
                      const SizedBox(width: 8),
                      _buildActionIcon(Icons.edit_outlined, () => _editCustomer(customer)),
                    ],
                  ),
                ],
              ),
            ],
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
              _buildDetailRow(l10n.email, customer.email.isNotEmpty ? customer.email : 'Not provided'),
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

  void _toggleCustomerStatus(Customer customer) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(customer.isActive ? l10n.customerDeactivated : l10n.customerActivated),
        backgroundColor: customer.isActive ? Colors.red : Colors.green,
      ),
    );
  }

  void _deleteCustomer(Customer customer) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteProduct),
        content: Text(l10n.confirmDeleteCustomer(customer.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.customerDeletedSuccessfully),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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

  Widget _buildDesktopCustomerRow(Customer customer) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getDebtStatusColor(customer.debtStatus).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              customer.name.split(' ').map((n) => n[0]).take(2).join('').toUpperCase(),
              style: TextStyle(
                color: _getDebtStatusColor(customer.debtStatus),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    customer.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: customer.isActive ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              Text(
                customer.phone,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            customer.email.isNotEmpty ? customer.email : 'No email',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${AppTheme.getCurrencySymbol(Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS'))}${customer.currentBalance.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: customer.currentBalance > 0 ? Colors.red : Colors.green,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getDebtStatusColor(customer.debtStatus).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getDebtStatusText(customer.debtStatus, l10n),
                  style: TextStyle(color: _getDebtStatusColor(customer.debtStatus), fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'view_transactions':
                _viewCustomerTransactions(customer);
                break;
              case 'edit':
                _editCustomer(customer);
                break;
              case 'toggle_status':
                _toggleCustomerStatus(customer);
                break;
              case 'delete':
                _deleteCustomer(customer);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'view_transactions', child: Text(l10n.viewTransactions)),
            PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
            PopupMenuItem(value: 'toggle_status', child: Text(customer.isActive ? l10n.deactivate : l10n.activate)),
            PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileCustomerRow(Customer customer) {
    final l10n = AppLocalizations.of(context)!;
    final isSmallPhone = MediaQuery.of(context).size.width < 380;

    return Row(
      children: [
        Container(
          width: isSmallPhone ? 42 : 48,
          height: isSmallPhone ? 42 : 48,
          decoration: BoxDecoration(
            color: _getDebtStatusColor(customer.debtStatus).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(isSmallPhone ? 21 : 24),
          ),
          child: Center(
            child: Text(
              customer.name.split(' ').map((n) => n[0]).take(2).join('').toUpperCase(),
              style: TextStyle(
                color: _getDebtStatusColor(customer.debtStatus),
                fontWeight: FontWeight.bold,
                fontSize: isSmallPhone ? 14 : 16,
              ),
            ),
          ),
        ),
        SizedBox(width: isSmallPhone ? 10 : 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      customer.name,
                      style: TextStyle(
                        fontSize: isSmallPhone ? 14 : 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: customer.isActive ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              Text(
                customer.phone,
                style: TextStyle(fontSize: isSmallPhone ? 12 : 13, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (customer.email.isNotEmpty)
                Text(
                  customer.email,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${AppTheme.getCurrencySymbol(Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS'))}${customer.currentBalance.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: isSmallPhone ? 13 : 15,
                fontWeight: FontWeight.bold,
                color: customer.currentBalance > 0 ? Colors.red : Colors.green,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallPhone ? 6 : 8,
                vertical: isSmallPhone ? 2 : 4,
              ),
              decoration: BoxDecoration(
                color: _getDebtStatusColor(customer.debtStatus).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _getDebtStatusText(customer.debtStatus, l10n),
                style: TextStyle(
                  color: _getDebtStatusColor(customer.debtStatus),
                  fontSize: isSmallPhone ? 10 : 11,
                ),
              ),
            ),
          ],
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'view_transactions':
                _viewCustomerTransactions(customer);
                break;
              case 'edit':
                _editCustomer(customer);
                break;
              case 'toggle_status':
                _toggleCustomerStatus(customer);
                break;
              case 'delete':
                _deleteCustomer(customer);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'view_transactions', child: Text(l10n.viewTransactions)),
            PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
            PopupMenuItem(value: 'toggle_status', child: Text(customer.isActive ? l10n.deactivate : l10n.activate)),
            PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
          ],
        ),
      ],
    );
  }
}
