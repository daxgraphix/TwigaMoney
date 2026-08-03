import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/category.dart';
import '../../presentation/bloc/finance_bloc.dart';

class EditBudgetPage extends StatefulWidget {
  final Budget? budget;

  const EditBudgetPage({super.key, this.budget});

  @override
  State<EditBudgetPage> createState() => _EditBudgetPageState();
}

class _EditBudgetPageState extends State<EditBudgetPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  String? _selectedCategoryId;
  String _budgetPeriod = 'monthly';

  @override
  void initState() {
    super.initState();
    context.read<FinanceBloc>().add(LoadCategoriesEvent());
    final budget = widget.budget;
    _nameController = TextEditingController(text: budget?.name ?? '');
    _amountController = TextEditingController(
        text: budget != null ? budget.amount.toStringAsFixed(2) : '');
    _selectedCategoryId = budget?.categoryId;
    _budgetPeriod = budget != null
        ? budget.period.name
        : 'monthly';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category'), backgroundColor: Colors.orange),
      );
      return;
    }

    final amount = double.parse(_amountController.text);
    final now = DateTime.now();
    final budget = Budget(
      id: widget.budget?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      amount: amount,
      categoryId: _selectedCategoryId!,
      period: _budgetPeriod == 'weekly'
          ? BudgetPeriod.weekly
          : _budgetPeriod == 'yearly'
          ? BudgetPeriod.yearly
          : _budgetPeriod == 'custom'
          ? BudgetPeriod.custom
          : BudgetPeriod.monthly,
      startDate: widget.budget?.startDate ?? now,
      endDate: widget.budget?.endDate,
      spent: widget.budget?.spent ?? 0.0,
    );

    if (widget.budget == null) {
      context.read<FinanceBloc>().add(AddBudgetEvent(budget));
    } else {
      context.read<FinanceBloc>().add(UpdateBudgetEvent(budget));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.budget == null ? 'Budget created' : 'Budget updated'),
        backgroundColor: Colors.green,
      ),
    );

    if (context.canPop()) { context.pop(); } else { context.go('/'); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.budget == null ? 'New Budget' : 'Edit Budget'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Theme.of(context).primaryColor),
          onPressed: () { if (context.canPop()) { if (context.canPop()) { context.pop(); } else { context.go('/'); } } else { context.go('/'); } },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.getPadding(context)),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Budget Name',
                  hintText: 'e.g., Monthly Marketing',
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a budget name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              BlocBuilder<FinanceBloc, FinanceState>(
                builder: (context, state) {
                  List<Category> categories = [];
                  if (state is CategoriesLoaded) {
                    categories = state.categories;
                  }
                  
                  return FormField<String>(
                    initialValue: _selectedCategoryId,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                    builder: (FormFieldState<String> state) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Category',
                          prefixIcon: const Icon(Icons.category),
                          errorText: state.errorText,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategoryId,
                            hint: const Text('Select Category'),
                            isExpanded: true,
                            items: categories.map((category) {
                              return DropdownMenuItem<String>(
                                value: category.id,
                                child: Row(
                                  children: [
                                    Icon(category.icon, color: category.color, size: 20),
                                    const SizedBox(width: 10),
                                    Text(category.name),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              state.didChange(value);
                              setState(() => _selectedCategoryId = value);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Budget Amount',
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
             const SizedBox(height: 16),
              FormField<String>(
                initialValue: _budgetPeriod,
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Budget Period',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: DropdownButton<String>(
                      value: state.value,
                      items: const [
                        DropdownMenuItem(value: 'daily', child: Text('Daily')),
                        DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                        DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                        DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                      ],
                      onChanged: (value) {
                        state.didChange(value);
                        setState(() => _budgetPeriod = value!);
                      },
                      isExpanded: true,
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(widget.budget == null ? 'Create Budget' : 'Update Budget'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



