import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twigamoney/l10n/app_localizations.dart';
import 'package:twigamoney/core/widgets/page_transitions.dart';
import '../../domain/entities/category.dart';
import '../../presentation/bloc/finance_bloc.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  final List<String> _availableIcons = const [
    'food', 'bills', 'health', 'education', 'shopping', 'transport',
    'entertainment', 'utilities', 'salary', 'investment', 'funds', 'stocks', 'other',
  ];

  final List<Color> _availableColors = const [
    Color(0xFFFF6B6B), Color(0xFF4ECDC4), Color(0xFF45B7D1), Color(0xFFF9CA24),
    Color(0xFF6C5CE7), Color(0xFF00B894), Color(0xFFA29BFE), Color(0xFFFD79A8),
    Color(0xFF2ECC71), Color(0xFFE17055), Color(0xFF0984E3), Color(0xFF636E72),
  ];

  final TextEditingController _nameController = TextEditingController();

  IconData _getIconFromName(String name) {
    switch (name) {
      case 'food': return Icons.restaurant;
      case 'bills': return Icons.receipt;
      case 'health': return Icons.local_hospital;
      case 'education': return Icons.school;
      case 'shopping': return Icons.shopping_bag;
      case 'transport': return Icons.directions_car;
      case 'entertainment': return Icons.movie;
      case 'utilities': return Icons.lightbulb;
      case 'salary': return Icons.work;
      case 'investment': return Icons.trending_up;
      case 'funds': return Icons.account_balance_wallet;
      case 'stocks': return Icons.inventory;
      case 'other': return Icons.category;
      default: return Icons.category;
    }
  }

  void _showCategoryForm([Category? category]) {
    final l10n = AppLocalizations.of(context)!;
    String? localEditingCategoryId;
    String localSelectedIconName;
    Color localSelectedColor;

    if (category != null) {
      localEditingCategoryId = category.id;
      _nameController.text = category.name;
      localSelectedIconName = category.iconName;
      localSelectedColor = category.color;
    } else {
      localEditingCategoryId = null;
      _nameController.clear();
      localSelectedIconName = 'food';
      localSelectedColor = _availableColors[0];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localEditingCategoryId == null ? l10n.addCategory : l10n.editCategory,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.categoryName,
                    prefixIcon: const Icon(Icons.label_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: localSelectedIconName,
                  decoration: InputDecoration(
                    labelText: l10n.icon,
                    prefixIcon: const Icon(Icons.emoji_symbols_outlined),
                  ),
                  items: _availableIcons
                      .map((icon) => DropdownMenuItem(
                            value: icon,
                            child: Row(
                              children: [
                                Icon(_getIconFromName(icon)),
                                const SizedBox(width: 12),
                                Text(icon.toUpperCase()),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setModalState(() => localSelectedIconName = value);
                    }
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.color,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _availableColors.map((color) {
                    return GestureDetector(
                      onTap: () => setModalState(() => localSelectedColor = color),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: localSelectedColor == color
                                ? Colors.black
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_nameController.text.isEmpty) return;
                      
                      final newCategory = Category(
                        id: localEditingCategoryId ?? DateTime.now().millisecondsSinceEpoch.toString(),
                        name: _nameController.text,
                        iconName: localSelectedIconName,
                        colorValue: localSelectedColor.toARGB32(),
                      );

                      if (localEditingCategoryId == null) {
                        context.read<FinanceBloc>().add(AddCategoryEvent(newCategory));
                      } else {
                        context.read<FinanceBloc>().add(UpdateCategoryEvent(newCategory));
                      }
                      Navigator.pop(context);
                    },
                    child: Text(
                      localEditingCategoryId == null ? l10n.add : l10n.update,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButtonWidget(),
        title: Text(l10n.categories, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<FinanceBloc, FinanceState>(
        builder: (context, state) {
          if (state is FinanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CategoriesLoaded) {
            if (state.categories.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.category_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(l10n.noCategoriesYet, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(l10n.addFirstCategory, style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final category = state.categories[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: category.color.withValues(alpha: 0.2),
                      child: Icon(
                        _getIconFromName(category.iconName),
                        color: category.color,
                      ),
                    ),
                    title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _showCategoryForm(category),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            context.read<FinanceBloc>().add(DeleteCategoryEvent(category.id));
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return Center(child: Text(l10n.errorLoadingCategories));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
