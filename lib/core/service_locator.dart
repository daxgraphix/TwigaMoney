import 'package:get_it/get_it.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/product/domain/usecases/product_usecases.dart';
import '../../features/product/presentation/bloc/product_bloc.dart';
import '../../features/shop/data/repositories/shop_repository_impl.dart';
import '../../features/shop/domain/repositories/shop_repository.dart';
import '../../features/shop/domain/usecases/shop_usecases.dart';
import '../../features/shop/presentation/bloc/shop_bloc.dart';
import '../../features/billing/presentation/bloc/dashboard_bloc.dart';
import '../../features/billing/presentation/bloc/billing_bloc.dart';
import '../../features/billing/data/repositories/sales_repository_impl.dart';
import '../../features/billing/domain/repositories/sales_repository.dart';
import '../../features/billing/domain/usecases/analytics_usecases.dart';
import '../../features/product/data/repositories/stock_repository_impl.dart';
import '../../features/product/domain/repositories/stock_repository.dart';
import '../../features/billing/data/repositories/customer_repository_impl.dart';
import '../../features/billing/domain/repositories/customer_repository.dart';
import '../../features/finance/data/repositories/transaction_repository_impl.dart';
import '../../features/finance/data/repositories/category_repository_impl.dart';
import '../../features/finance/data/repositories/account_repository_impl.dart';
import '../../features/finance/data/repositories/budget_repository_impl.dart';
import '../../features/finance/data/repositories/recurring_transaction_repository_impl.dart';
import '../../features/finance/domain/repositories/transaction_repository.dart';
import '../../features/finance/domain/repositories/category_repository.dart';
import '../../features/finance/domain/repositories/account_repository.dart';
import '../../features/finance/domain/repositories/budget_repository.dart';
import '../../features/finance/domain/repositories/recurring_transaction_repository.dart';
import '../../features/finance/domain/usecases/finance_usecases.dart';
import '../../features/finance/domain/usecases/monthly_report_usecase.dart';
import '../../features/finance/domain/usecases/comprehensive_report_usecase.dart';
import '../../features/finance/presentation/bloc/finance_bloc.dart';
import '../../features/finance/presentation/bloc/transaction_bloc.dart';
import '../../features/finance/presentation/bloc/account_cubit.dart';
import '../../features/finance/presentation/bloc/budget_cubit.dart';
import '../../features/finance/presentation/bloc/report_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  if (sl.isRegistered<ProductRepository>()) {
    return;
  }

  // ============================================
   // REPOSITORIES (Lazy Singletons)
   // ============================================
   sl.registerLazySingleton<ProductRepository>(
     () => const ProductRepositoryImpl(),
   );

   sl.registerLazySingleton<ShopRepository>(
     () => ShopRepositoryImpl(),
   );

   sl.registerLazySingleton<TransactionRepository>(
     () => const TransactionRepositoryImpl(),
   );

   sl.registerLazySingleton<CategoryRepository>(
     () => const CategoryRepositoryImpl(),
   );

   sl.registerLazySingleton<AccountRepository>(
     () => const AccountRepositoryImpl(),
   );

   sl.registerLazySingleton<BudgetRepository>(
     () => const BudgetRepositoryImpl(),
   );

   sl.registerLazySingleton<RecurringTransactionRepository>(
     () => const RecurringTransactionRepositoryImpl(),
   );

   sl.registerLazySingleton<SalesRepository>(
     () => const SalesRepositoryImpl(),
   );

   sl.registerLazySingleton<StockRepository>(
     () => const StockRepositoryImpl(),
   );

   sl.registerLazySingleton<CustomerRepository>(
     () => const CustomerRepositoryImpl(),
   );

  // ============================================
  // USE CASES (Lazy Singletons - depend on repositories)
  // ============================================
  // Product Use Cases
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => AddProductUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProductUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProductUseCase(sl()));
  sl.registerLazySingleton(() => GetProductByBarcodeUseCase(sl()));
  sl.registerLazySingleton(() => DecrementStockUseCase(sl()));
  sl.registerLazySingleton(() => UpdateStockUseCase(sl()));

  // Shop Use Cases
  sl.registerLazySingleton(() => GetShopUseCase(sl()));
  sl.registerLazySingleton(() => UpdateShopUseCase(sl()));

  // Finance Use Cases
  sl.registerLazySingleton(() => GetTransactionsUseCase(sl()));
  sl.registerLazySingleton(() => AddTransactionUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTransactionUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTransactionUseCase(sl()));
  sl.registerLazySingleton(() => GetTransactionsByDateRangeUseCase(sl()));
  sl.registerLazySingleton(() => GetTransactionsByCategoryUseCase(sl()));
  sl.registerLazySingleton(() => GetTransactionsByAccountUseCase(sl()));

  // Transaction Bloc (new focused BLoC)
  sl.registerFactory(() => TransactionBloc(repository: sl()));

  // Budget Cubit (new focused Cubit)
  sl.registerFactory(() => BudgetCubit(repository: sl()));

  // Account Cubit
  sl.registerFactory(() => AccountCubit(repository: sl()));

  // Report Cubit (new focused Cubit)
  sl.registerFactory(() => ReportCubit(
    transactionRepository: sl(),
    monthlyReportUseCase: sl(),
    comprehensiveReportUseCase: sl(),
  ));

  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => AddCategoryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCategoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCategoryUseCase(sl()));

  sl.registerLazySingleton(() => GetAccountsUseCase(sl()));
  sl.registerLazySingleton(() => AddAccountUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAccountUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAccountBalanceUseCase(sl()));

  sl.registerLazySingleton(() => GetBudgetsUseCase(sl()));
  sl.registerLazySingleton(() => AddBudgetUseCase(sl()));
  sl.registerLazySingleton(() => UpdateBudgetUseCase(sl()));
  sl.registerLazySingleton(() => DeleteBudgetUseCase(sl()));
  sl.registerLazySingleton(() => UpdateBudgetSpentUseCase(sl()));

  sl.registerLazySingleton(() => GetRecurringTransactionsUseCase(sl()));
  sl.registerLazySingleton(() => AddRecurringTransactionUseCase(sl()));
  sl.registerLazySingleton(() => UpdateRecurringTransactionUseCase(sl()));
  sl.registerLazySingleton(() => DeleteRecurringTransactionUseCase(sl()));
  sl.registerLazySingleton(() => GetMonthlyReportUseCase(sl()));
  sl.registerLazySingleton(() => GetComprehensiveBusinessReportUseCase(
        sl(), sl(), sl(), sl(),
      ));

  // Sales Analytics Use Cases
  sl.registerLazySingleton(() => GetTopPerformingProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetLowTurnoverProductsUseCase(sl()));

  // ============================================
  // BLOCs (Factories - depend on use cases)
  // ============================================
  sl.registerFactory(
    () => DashboardBloc(
      salesRepository: sl(),
      customerRepository: sl(),
      stockRepository: sl(),
      getTransactionsByDateRangeUseCase: sl(),
      getAccountsUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => ProductBloc(
      getProductsUseCase: sl(),
      addProductUseCase: sl(),
      updateProductUseCase: sl(),
      deleteProductUseCase: sl(),
      updateStockUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => ShopBloc(
      getShopUseCase: sl(),
      updateShopUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => BillingBloc(
      getProductByBarcodeUseCase: sl(),
      decrementStockUseCase: sl(),
      salesRepository: sl(),
      stockRepository: sl(),
      customerRepository: sl(),
    ),
  );

  sl.registerFactory(
    () => FinanceBloc(
      getCategoriesUseCase: sl(),
      addCategoryUseCase: sl(),
      updateCategoryUseCase: sl(),
      deleteCategoryUseCase: sl(),
      getAccountsUseCase: sl(),
      addAccountUseCase: sl(),
      updateAccountUseCase: sl(),
      deleteAccountUseCase: sl(),
      getBudgetsUseCase: sl(),
      addBudgetUseCase: sl(),
      updateBudgetUseCase: sl(),
      deleteBudgetUseCase: sl(),
      getRecurringTransactionsUseCase: sl(),
      addRecurringTransactionUseCase: sl(),
      updateRecurringTransactionUseCase: sl(),
        deleteRecurringTransactionUseCase: sl(),
        getMonthlyReportUseCase: sl(),
      ),
    );
  }
