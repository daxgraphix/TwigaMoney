import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/responsive.dart';
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

  String? _editingCategoryId;
  final TextEditingController _nameController = TextEditingController();
  String _selectedIcon = 'food';
  Color _selectedColor = const Color(0xFFFF6B6B);

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

  @override
  void initState() {
    super.initState();
    context.read<FinanceBloc>().add(LoadCategoriesEvent());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _openForm({Category? category}) {
    if (category != null) {
      _editingCategoryId = category.id;
      _nameController.text = category.name;
      _selectedIcon = category.iconName;
      _selectedColor = category.color;
    } else {
      _editingCategoryId = null;
      _nameController.clear();
      _selectedIcon = _availableIcons.first;
      _selectedColor = _availableColors.first;
    }
    _showFormBottomSheet();
  }

  void _showFormBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
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
                _editingCategoryId == null ? 'Add Category' : 'Edit Category',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  prefixIcon: Icon(Icons.label_outline),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedIcon,
                decoration: const InputDecoration(
                  labelText: 'Icon',
                  prefixIcon: Icon(Icons.emoji_symbols_outlined),
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
                    setState(() => _selectedIcon = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Color>(
                initialValue: _selectedColor,
                decoration: const InputDecoration(
                  labelText: 'Color',
                  prefixIcon: Icon(Icons.palette_outlined),
                ),
                items: _availableColors
                    .map((color) => DropdownMenuItem(
                          value: color,
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text('#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}'),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedColor = value);
                  }
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveCategory,
                      child: Text(_editingCategoryId == null ? 'Add' : 'Save'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _saveCategory() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    final category = Category(
      id: _editingCategoryId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      colorValue: _selectedColor.toARGB32(),
      iconName: _selectedIcon,
    );

    if (_editingCategoryId == null) {
      context.read<FinanceBloc>().add(AddCategoryEvent(category));
    } else {
      context.read<FinanceBloc>().add(UpdateCategoryEvent(category));
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_editingCategoryId == null
            ? 'Category added'
            : 'Category updated'),
      ),
    );
  }

  void _confirmDelete(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<FinanceBloc>().add(DeleteCategoryEvent(category.id));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('"${category.name}" deleted')),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.getPadding(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<FinanceBloc, FinanceState>(
        builder: (context, state) {
          if (state is FinanceLoading && state is! CategoriesLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = state is CategoriesLoaded ? state.categories : <Category>[];

          if (categories.isEmpty && state is! FinanceLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No categories yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create your first category',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: EdgeInsets.fromLTRB(padding, 16, padding, padding + 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Responsive.isMobile(context) ? 2 : (Responsive.isTablet(context) ? 3 : 4),
              childAspectRatio: 1.0,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: GestureDetector(
                    onTap: () => _openForm(category: category),
                    onLongPress: () => _confirmDelete(category),
                    child: Container(
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: category.color.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: category.color,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              category.icon,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            category.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
