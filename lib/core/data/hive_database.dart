import 'dart:convert';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/product/data/models/product_model.dart';
import '../../features/shop/data/models/shop_model.dart';
import '../../features/finance/domain/entities/transaction.dart';
import '../../features/finance/domain/entities/category.dart';
import '../../features/finance/domain/entities/account.dart';
import '../../features/finance/domain/entities/budget.dart';
import '../../features/finance/domain/entities/recurring_transaction.dart';
import '../../features/billing/domain/entities/sales_transaction.dart';
import '../../features/product/domain/entities/stock_movement.dart';
import '../../features/billing/domain/entities/customer.dart';
import '../../features/billing/domain/entities/customer_transaction.dart';

class HiveDatabase {
  static const String productBoxName = 'products';
  static const String shopBoxName = 'shop';
  static const String settingsBoxName = 'settings';
  static const String transactionBoxName = 'transactions';
  static const String categoryBoxName = 'categories';
  static const String accountBoxName = 'accounts';
  static const String budgetBoxName = 'budgets';
  static const String recurringTransactionBoxName = 'recurring_transactions';
  static const String salesTransactionBoxName = 'sales_transactions';
  static const String stockMovementBoxName = 'stock_movements';
  static const String customerBoxName = 'customers';
  static const String customerTransactionBoxName = 'customer_transactions';
  static const String plannerEventsBoxName = 'planner_events';
  static const String plannerNotesBoxName = 'planner_notes';

  static Future<void> init() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final entities = Directory(dir.path).listSync(recursive: false);
      for (final entity in entities) {
        if (entity is File && entity.path.endsWith('.lock')) {
          try {
            entity.deleteSync();
          } catch (_) {}
        }
      }
    } catch (_) {}

    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(ProductModelAdapter());
    Hive.registerAdapter(ShopModelAdapter());
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(RecurringIntervalAdapter());
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(AccountTypeAdapter());
    Hive.registerAdapter(AccountAdapter());
    Hive.registerAdapter(BudgetPeriodAdapter());
    Hive.registerAdapter(BudgetAdapter());
    Hive.registerAdapter(RecurringTransactionAdapter());
    Hive.registerAdapter(SalesTransactionAdapter());
    Hive.registerAdapter(MovementTypeAdapter());
    Hive.registerAdapter(StockMovementAdapter());
    Hive.registerAdapter(CustomerAdapter());
    Hive.registerAdapter(CustomerTransactionTypeAdapter());
    Hive.registerAdapter(CustomerTransactionAdapter());

    // Open Boxes
    await Hive.openBox<ProductModel>(productBoxName);
    await Hive.openBox<ShopModel>(shopBoxName);
    await Hive.openBox(settingsBoxName);
    await Hive.openBox<Transaction>(transactionBoxName);
    await Hive.openBox<Category>(categoryBoxName);
    await Hive.openBox<Account>(accountBoxName);
    await Hive.openBox<Budget>(budgetBoxName);
    await Hive.openBox<RecurringTransaction>(recurringTransactionBoxName);
    await Hive.openBox<SalesTransaction>(salesTransactionBoxName);
    await Hive.openBox<StockMovement>(stockMovementBoxName);
    await Hive.openBox<Customer>(customerBoxName);
    await Hive.openBox<CustomerTransaction>(customerTransactionBoxName);
    await Hive.openBox(plannerEventsBoxName);
    await Hive.openBox(plannerNotesBoxName);

    await _addDefaultData();
  }

  static Future<void> _addDefaultData() async {
    final categoryBox = HiveDatabase.categoryBox;
    if (categoryBox.isEmpty) {
      final categories = [
        Category(id: '1', name: 'Food', colorValue: 0xFFFF6B6B, iconName: 'food'),
        Category(id: '2', name: 'Transport', colorValue: 0xFF4ECDC4, iconName: 'transport'),
        Category(id: '3', name: 'Entertainment', colorValue: 0xFF45B7D1, iconName: 'entertainment'),
        Category(id: '4', name: 'Shopping', colorValue: 0xFFF9CA24, iconName: 'shopping'),
        Category(id: '5', name: 'Salary', colorValue: 0xFF6C5CE7, iconName: 'salary'),
        Category(id: '6', name: 'Investment', colorValue: 0xFF00B894, iconName: 'investment'),
        Category(id: '7', name: 'Other', colorValue: 0xFFA29BFE, iconName: 'other'),
      ];
      for (final c in categories) {
        await categoryBox.put(c.id, c);
      }
    }
    final accountBox = HiveDatabase.accountBox;
    if (accountBox.isEmpty) {
      final accounts = [
        Account(id: '1', name: 'Main Account', type: AccountType.checking, balance: 0.0),
      ];
      for (final a in accounts) {
        await accountBox.put(a.id, a);
      }
    }
  }

  static Box<ProductModel> get productBox => Hive.box<ProductModel>(productBoxName);
  static Box<ShopModel> get shopBox => Hive.box<ShopModel>(shopBoxName);
  static Box get settingsBox => Hive.box(settingsBoxName);
  static Box<Transaction> get transactionBox => Hive.box<Transaction>(transactionBoxName);
  static Box<Category> get categoryBox => Hive.box<Category>(categoryBoxName);
  static Box<Account> get accountBox => Hive.box<Account>(accountBoxName);
  static Box<Budget> get budgetBox => Hive.box<Budget>(budgetBoxName);
  static Box<RecurringTransaction> get recurringTransactionBox =>
      Hive.box<RecurringTransaction>(recurringTransactionBoxName);
  static Box<SalesTransaction> get salesTransactionBox =>
      Hive.box<SalesTransaction>(salesTransactionBoxName);
  static Box<StockMovement> get stockMovementBox =>
      Hive.box<StockMovement>(stockMovementBoxName);
  static Box<Customer> get customerBox => Hive.box<Customer>(customerBoxName);
  static Box<CustomerTransaction> get customerTransactionBox =>
      Hive.box<CustomerTransaction>(customerTransactionBoxName);
  static Box get plannerEventsBox => Hive.box(plannerEventsBoxName);
  static Box get plannerNotesBox => Hive.box(plannerNotesBoxName);

  static Map<String, dynamic> _toMap(Object? v) {
    final m = <String, dynamic>{};
    void put(String k, dynamic val) => m[k] = val;

    if (v is ProductModel) {
      put('json', v.toJson());
    } else if (v is ShopModel) {
      put('json', v.toJson());
    } else if (v is SalesTransaction) {
      put('json', v.toJson());
    } else if (v is Customer) {
      put('json', v.toJson());
    } else if (v is Transaction) {
      put('json', v.toJson());
    } else if (v is CustomerTransaction) {
      put('json', v.toJson());
    } else if (v is Category) {
      put('json', v.toJson());
    } else if (v is Account) {
      put('json', v.toJson());
    } else if (v is Budget) {
      put('json', v.toJson());
    } else if (v is RecurringTransaction) {
      put('json', v.toJson());
    } else if (v is StockMovement) {
      put('json', v.toJson());
    } else if (v is Map) {
      return Map<String, dynamic>.from(v);
    } else if (v is num || v is bool || v is String) {
      put('value', v);
    } else {
      put('value', v?.toString());
    }
    return m;
  }

  static Map<String, dynamic> _boxToMap(Box box) {
    final out = <String, dynamic>{};
    for (final key in box.keys) {
      out[key.toString()] = _toMap(box.get(key));
    }
    return out;
  }

  static Future<String> exportAllData() async {
    final data = <String, dynamic>{
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'boxes': <String, dynamic>{
        productBoxName: _boxToMap(productBox),
        shopBoxName: _boxToMap(shopBox),
        settingsBoxName: _boxToMap(settingsBox),
        transactionBoxName: _boxToMap(transactionBox),
        categoryBoxName: _boxToMap(categoryBox),
        accountBoxName: _boxToMap(accountBox),
        budgetBoxName: _boxToMap(budgetBox),
        recurringTransactionBoxName: _boxToMap(recurringTransactionBox),
        salesTransactionBoxName: _boxToMap(salesTransactionBox),
        stockMovementBoxName: _boxToMap(stockMovementBox),
        customerBoxName: _boxToMap(customerBox),
        customerTransactionBoxName: _boxToMap(customerTransactionBox),
        plannerEventsBoxName: _boxToMap(plannerEventsBox),
        plannerNotesBoxName: _boxToMap(plannerNotesBox),
      },
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  static Future<void> importAllData(String jsonString) async {
    final decoded = jsonDecode(jsonString);
    final data = decoded is Map
        ? Map<String, dynamic>.from(decoded)
        : <String, dynamic>{};
    final raw = (data['boxes'] as Map?) ?? data;
    final boxes = Map<String, dynamic>.from(raw);
    await _clearAllBoxes();
    await _populateBoxes(boxes);
  }

  static Future<void> _clearAllBoxes() async {
    await Future.wait([
      productBox.clear(),
      shopBox.clear(),
      settingsBox.clear(),
      transactionBox.clear(),
      customerBox.clear(),
      categoryBox.clear(),
      accountBox.clear(),
      budgetBox.clear(),
      recurringTransactionBox.clear(),
      salesTransactionBox.clear(),
      stockMovementBox.clear(),
      customerTransactionBox.clear(),
      plannerEventsBox.clear(),
      plannerNotesBox.clear(),
    ]);
  }

  static Future<void> _populateBoxes(Map<String, dynamic> boxes) async {
    // Products
    final productData = boxes[productBoxName];
    if (productData is Map) {
      for (final entry in productData.entries) {
        final m = entry.value as Map<String, dynamic>;
        await productBox.put(entry.key, ProductModel.fromJson(m['json'] ?? m));
      }
    }

    // Shop
    final shopData = boxes[shopBoxName];
    if (shopData is Map) {
      for (final entry in shopData.entries) {
        final m = entry.value as Map<String, dynamic>;
        await shopBox.put(entry.key, ShopModel.fromJson(m['json'] ?? m));
      }
    }

    // Settings
    final settings = boxes[settingsBoxName];
    if (settings is Map) {
      for (final e in settings.entries) {
        final val = e.value;
        if (val is Map && val.containsKey('value')) {
          await settingsBox.put(e.key, val['value']);
        } else {
          await settingsBox.put(e.key, val);
        }
      }
    }

    // Transactions
    final transactionData = boxes[transactionBoxName];
    if (transactionData is Map) {
      for (final entry in transactionData.entries) {
        final m = entry.value as Map<String, dynamic>;
        await transactionBox.put(entry.key, Transaction.fromJson(m['json'] ?? m));
      }
    }

    // Categories
    final categoryData = boxes[categoryBoxName];
    if (categoryData is Map) {
      for (final entry in categoryData.entries) {
        final m = entry.value as Map<String, dynamic>;
        await categoryBox.put(entry.key, Category.fromJson(m['json'] ?? m));
      }
    }

    // Accounts
    final accountData = boxes[accountBoxName];
    if (accountData is Map) {
      for (final entry in accountData.entries) {
        final m = entry.value as Map<String, dynamic>;
        await accountBox.put(entry.key, Account.fromJson(m['json'] ?? m));
      }
    }

    // Budgets
    final budgetData = boxes[budgetBoxName];
    if (budgetData is Map) {
      for (final entry in budgetData.entries) {
        final m = entry.value as Map<String, dynamic>;
        await budgetBox.put(entry.key, Budget.fromJson(m['json'] ?? m));
      }
    }

    // Recurring transactions
    final recurringData = boxes[recurringTransactionBoxName];
    if (recurringData is Map) {
      for (final entry in recurringData.entries) {
        final m = entry.value as Map<String, dynamic>;
        await recurringTransactionBox.put(entry.key, RecurringTransaction.fromJson(m['json'] ?? m));
      }
    }

    // Sales transactions
    final salesData = boxes[salesTransactionBoxName];
    if (salesData is Map) {
      for (final entry in salesData.entries) {
        final m = entry.value as Map<String, dynamic>;
        await salesTransactionBox.put(entry.key, SalesTransaction.fromJson(m['json'] ?? m));
      }
    }

    // Stock movements
    final stockData = boxes[stockMovementBoxName];
    if (stockData is Map) {
      for (final entry in stockData.entries) {
        final m = entry.value as Map<String, dynamic>;
        await stockMovementBox.put(entry.key, StockMovement.fromJson(m['json'] ?? m));
      }
    }

    // Customers
    final customerData = boxes[customerBoxName];
    if (customerData is Map) {
      for (final entry in customerData.entries) {
        final m = entry.value as Map<String, dynamic>;
        await customerBox.put(entry.key, Customer.fromJson(m['json'] ?? m));
      }
    }

    // Customer transactions
    final customerTxData = boxes[customerTransactionBoxName];
    if (customerTxData is Map) {
      for (final entry in customerTxData.entries) {
        final m = entry.value as Map<String, dynamic>;
        await customerTransactionBox.put(entry.key, CustomerTransaction.fromJson(m['json'] ?? m));
      }
    }

    // Planner events
    final plannerEventsData = boxes[plannerEventsBoxName];
    if (plannerEventsData is Map) {
      for (final entry in plannerEventsData.entries) {
        final val = entry.value;
        if (val is Map && val.containsKey('value')) {
          await plannerEventsBox.put(entry.key, val['value']);
        } else {
          await plannerEventsBox.put(entry.key, val);
        }
      }
    }

    // Planner notes
    final plannerNotesData = boxes[plannerNotesBoxName];
    if (plannerNotesData is Map) {
      for (final entry in plannerNotesData.entries) {
        final val = entry.value;
        if (val is Map && val.containsKey('value')) {
          await plannerNotesBox.put(entry.key, val['value']);
        } else {
          await plannerNotesBox.put(entry.key, val);
        }
      }
    }
  }

  static Future<void> clearAllBoxes() async {
    await Future.wait([
      productBox.clear(),
      shopBox.clear(),
      settingsBox.clear(),
      transactionBox.clear(),
      customerBox.clear(),
      categoryBox.clear(),
      accountBox.clear(),
      budgetBox.clear(),
      recurringTransactionBox.clear(),
      salesTransactionBox.clear(),
      stockMovementBox.clear(),
      customerTransactionBox.clear(),
      plannerEventsBox.clear(),
      plannerNotesBox.clear(),
    ]);
  }

  static Future<Map<String, List<Map<String, dynamic>>>> archive() async {
    return <String, List<Map<String, dynamic>>>{
      'products': productBox.values.map((e) => e.toJson()).toList(),
      'transactions': transactionBox.values.map((e) => e.toJson()).toList(),
      'customers': customerBox.values.map((e) => e.toJson()).toList(),
      'salesTransactions': salesTransactionBox.values.map((e) => e.toJson()).toList(),
      'categories': categoryBox.values.map((e) => e.toJson()).toList(),
      'accounts': accountBox.values.map((e) => e.toJson()).toList(),
      'budgets': budgetBox.values.map((e) => e.toJson()).toList(),
      'recurringTransactions': recurringTransactionBox.values.map((e) => e.toJson()).toList(),
      'stockMovements': stockMovementBox.values.map((e) => e.toJson()).toList(),
      'customerTransactions': customerTransactionBox.values.map((e) => e.toJson()).toList(),
    };
  }
}
