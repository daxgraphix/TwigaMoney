import 'package:go_router/go_router.dart';

import '../../features/billing/presentation/pages/dashboard_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/onboarding/presentation/pages/splash_screen.dart';
import '../../features/billing/presentation/pages/reports_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/billing/presentation/pages/new_sale_page.dart';
import '../../features/billing/presentation/pages/checkout_page.dart';
import '../../features/billing/presentation/pages/operations_page.dart';
import '../../features/planner/presentation/pages/planner_page.dart';
import '../../features/billing/presentation/pages/about_app_page.dart';
import '../../features/billing/presentation/pages/terms_conditions_page.dart';
import '../../features/billing/presentation/pages/privacy_policy_page.dart';
import '../../features/billing/presentation/pages/help_support_page.dart';
import '../../features/billing/presentation/pages/invoice_detail_page.dart';
import '../../features/billing/presentation/pages/shift_report_page.dart';
import '../../features/shop/presentation/pages/shop_details_page.dart';
import '../../features/finance/presentation/pages/add_transaction_page.dart';
import '../../features/finance/presentation/pages/budget_list_page.dart';
import '../../features/finance/presentation/pages/edit_budget_page.dart';
import '../../features/finance/presentation/pages/transaction_list_page.dart';
import '../../features/finance/presentation/pages/account_list_page.dart';
import '../../features/finance/presentation/pages/category_list_page.dart';
import '../../features/finance/presentation/pages/analysis_page.dart';
import '../../features/finance/presentation/pages/financial_calculators_page.dart';
import '../../features/finance/presentation/pages/more_page.dart';
import '../../features/product/presentation/pages/product_list_page.dart';
import '../../features/product/presentation/pages/add_product_page.dart';
import '../../features/product/presentation/pages/edit_product_page.dart';
import '../../features/billing/presentation/pages/customer_list_page.dart';
import '../../features/billing/presentation/pages/add_customer_page.dart';
import '../../features/billing/presentation/pages/edit_customer_page.dart';
import '../../features/billing/presentation/pages/customer_transactions_page.dart';
import '../../core/widgets/page_transitions.dart';
import '../../features/finance/domain/entities/budget.dart';
import '../../features/product/domain/entities/product.dart';
import '../../features/billing/domain/entities/customer.dart';
import '../../core/widgets/main_navigation_shell.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainNavigationShell(child: child),
        routes: [
          GoRoute(
              path: '/', builder: (context, state) => const DashboardPage()),
          GoRoute(
              path: '/products',
              builder: (context, state) => const ProductListPage()),
          GoRoute(
              path: '/products/add',
              builder: (context, state) => const AddProductPage()),
          GoRoute(
            path: '/products/edit',
            builder: (context, state) {
              final product = state.extra as Product;
              return EditProductPage(product: product);
            },
          ),
          GoRoute(
              path: '/customers',
              builder: (context, state) => const CustomerListPage()),
          GoRoute(
              path: '/customers/add',
              builder: (context, state) => const AddCustomerPage()),
          GoRoute(
            path: '/customers/edit',
            builder: (context, state) {
              final customer = state.extra as Customer;
              return EditCustomerPage(customer: customer);
            },
          ),
          GoRoute(
            path: '/customers/transactions/:id',
            builder: (context, state) => CustomerTransactionsPage(
                customerId: state.pathParameters['id']!),
          ),
          GoRoute(
              path: '/new-sale',
              builder: (context, state) => const NewSalePage()),
          GoRoute(
              path: '/transactions',
              builder: (context, state) => const TransactionListPage()),
          GoRoute(
              path: '/budgets',
              builder: (context, state) => const BudgetListPage()),
          GoRoute(
            path: '/budgets/add',
            builder: (context, state) => const EditBudgetPage(),
          ),
          GoRoute(
            path: '/budgets/edit',
            builder: (context, state) {
              final budget = state.extra as Budget;
              return EditBudgetPage(budget: budget);
            },
          ),
          GoRoute(
              path: '/accounts',
              builder: (context, state) => const AccountListPage()),
          GoRoute(
              path: '/categories',
              builder: (context, state) => const CategoryListPage()),
          GoRoute(path: '/more', builder: (context, state) => const MorePage()),
        ],
      ),
      GoRoute(
        path: '/reports',
        pageBuilder: (context, state) =>
            SwipeToPopPage.create(state, const ReportsPage()),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) =>
            SwipeToPopPage.create(state, const SettingsPage()),
      ),
      GoRoute(
        path: '/analysis',
        pageBuilder: (context, state) =>
            SwipeToPopPage.create(state, const AnalysisPage()),
      ),
      GoRoute(
        path: '/shop',
        pageBuilder: (context, state) =>
            SwipeToPopPage.create(state, const ShopDetailsPage()),
      ),
      GoRoute(
        path: '/add-transaction',
        pageBuilder: (context, state) =>
            SwipeToPopPage.create(state, const AddTransactionPage()),
      ),
      GoRoute(
        path: '/invoice/:id',
        pageBuilder: (context, state) => SwipeToPopPage.create(
          state,
          InvoiceDetailPage(invoiceId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/shift-report',
        pageBuilder: (context, state) => SwipeToPopPage.create(
          state,
          ShiftReportPage(
              shiftId: state.uri.queryParameters['id'] ?? 'default'),
        ),
      ),
      GoRoute(
        path: '/checkout',
        pageBuilder: (context, state) =>
            SwipeToPopPage.create(state, const CheckoutPage()),
      ),
      GoRoute(
        path: '/operations',
        pageBuilder: (context, state) =>
            SwipeToPopPage.create(state, const OperationsPage()),
      ),
      GoRoute(
        path: '/planner',
        pageBuilder: (context, state) =>
            SwipeToPopPage.create(state, const PlannerPage()),
      ),
      GoRoute(
        path: '/financial-tools',
        pageBuilder: (context, state) =>
            SwipeToPopPage.create(state, const FinancialCalculatorsPage()),
      ),
      GoRoute(
        path: '/about',
        pageBuilder: (context, state) =>
            SwipeToPopPage.create(state, const AboutAppPage()),
      ),
      GoRoute(
        path: '/terms',
        pageBuilder: (context, state) =>
            SwipeToPopPage.create(state, const TermsConditionsPage()),
      ),
      GoRoute(
        path: '/privacy',
        pageBuilder: (context, state) =>
            SwipeToPopPage.create(state, const PrivacyPolicyPage()),
      ),
      GoRoute(
        path: '/help-support',
        pageBuilder: (context, state) =>
            SwipeToPopPage.create(state, const HelpSupportPage()),
      ),
    ],
  );
}
