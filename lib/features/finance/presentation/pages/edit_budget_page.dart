import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:twigamoney/core/widgets/page_transitions.dart';
import 'package:twigamoney/core/widgets/input_label.dart';
import 'package:twigamoney/core/widgets/primary_button.dart';
import 'package:twigamoney/core/utils/responsive.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/category.dart';
import '../../presentation/bloc/finance_bloc.dart';
import 'package:twigamoney/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseSelectCategory), backgroundColor: Colors.orange),
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
        content: Text(widget.budget == null ? l10n.budgetCreated : l10n.budgetUpdated),
        backgroundColor: Colors.green,
      ),
    );

    if (context.canPop()) { context.pop(); } else { context.go('/'); }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButtonWidget(),
        title: Text(widget.budget == null ? l10n.newBudget : l10n.editBudget,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: Responsive.getPadding(context)),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              InputLabel(text: l10n.budgetName),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: l10n.budgetNameHint,
                  prefixIcon: const Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterBudgetName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InputLabel(text: l10n.category),
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
                        return l10n.pleaseSelectCategory;
                      }
                      return null;
                    },
                    builder: (FormFieldState<String> state) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.category),
                          errorText: state.errorText,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategoryId,
                            hint: Text(l10n.selectCategory),
                            isExpanded: true,
                            items: categories.map((category) {
                              return DropdownMenuItem<String>(
                                value: category.id,
                                child: Row(
                                  children: [
                                    Icon(category.icon,
                                        color: category.color, size: 20),
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
              InputLabel(text: l10n.budgetAmount),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: l10n.priceHint,
                  prefixIcon: const Icon(Icons.money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterValidAmount;
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return l10n.pleaseEnterValidAmount;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InputLabel(text: l10n.budgetPeriod),
              FormField<String>(
                initialValue: _budgetPeriod,
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: DropdownButton<String>(
                      value: state.value,
                      items: [
                        DropdownMenuItem(value: 'daily', child: Text(l10n.daily)),
                        DropdownMenuItem(
                            value: 'weekly', child: Text(l10n.weekly)),
                        DropdownMenuItem(
                            value: 'monthly', child: Text(l10n.monthly)),
                        DropdownMenuItem(
                            value: 'yearly', child: Text(l10n.yearly)),
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
              PrimaryButton(
                onPressed: _submit,
                label:
                    widget.budget == null ? l10n.addBudget : l10n.updateBudget,
              ),
            ],
          ),
        ),
      ),
    );
  }
}



