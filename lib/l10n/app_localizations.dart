import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'TwigaMoney'**
  String get appName;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @joinCommunity.
  ///
  /// In en, this message translates to:
  /// **'Join Our Community'**
  String get joinCommunity;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordsNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsNotMatch;

  /// No description provided for @acceptTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms & Conditions and Privacy Policy'**
  String get acceptTerms;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @secureFastReliable.
  ///
  /// In en, this message translates to:
  /// **'Secure • Fast • Reliable'**
  String get secureFastReliable;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password. Please try again.'**
  String get invalidCredentials;

  /// No description provided for @emailNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Please check your email and click the verification link.'**
  String get emailNotConfirmed;

  /// No description provided for @userAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists. Try logging in instead.'**
  String get userAlreadyRegistered;

  /// No description provided for @pleaseAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'Please accept the Terms and Conditions'**
  String get pleaseAcceptTerms;

  /// No description provided for @checkEmailVerification.
  ///
  /// In en, this message translates to:
  /// **'Please check your email to verify your account'**
  String get checkEmailVerification;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @management.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get management;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @enableDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Enable dark theme'**
  String get enableDarkTheme;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @manageStockBarcodes.
  ///
  /// In en, this message translates to:
  /// **'Manage stock and barcodes'**
  String get manageStockBarcodes;

  /// No description provided for @shopDetails.
  ///
  /// In en, this message translates to:
  /// **'Shop Details'**
  String get shopDetails;

  /// No description provided for @configureShopInfo.
  ///
  /// In en, this message translates to:
  /// **'Configure shop information'**
  String get configureShopInfo;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App Lock'**
  String get appLock;

  /// No description provided for @enablePinProtection.
  ///
  /// In en, this message translates to:
  /// **'Enable PIN protection'**
  String get enablePinProtection;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @selectDisplayCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select display currency'**
  String get selectDisplayCurrency;

  /// No description provided for @shiftManagement.
  ///
  /// In en, this message translates to:
  /// **'Shift Management'**
  String get shiftManagement;

  /// No description provided for @startShift.
  ///
  /// In en, this message translates to:
  /// **'Start Shift'**
  String get startShift;

  /// No description provided for @shiftActive.
  ///
  /// In en, this message translates to:
  /// **'Shift Active'**
  String get shiftActive;

  /// No description provided for @hardware.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get hardware;

  /// No description provided for @printDevice.
  ///
  /// In en, this message translates to:
  /// **'Exports'**
  String get printDevice;

  /// No description provided for @noPrinterConnected.
  ///
  /// In en, this message translates to:
  /// **'No export device configured'**
  String get noPrinterConnected;

  /// No description provided for @printerConnected.
  ///
  /// In en, this message translates to:
  /// **'Export ready'**
  String get printerConnected;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'CONNECTED'**
  String get connected;

  /// No description provided for @connectNewDevice.
  ///
  /// In en, this message translates to:
  /// **'Export reports and invoices from the settings screen.'**
  String get connectNewDevice;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @backupData.
  ///
  /// In en, this message translates to:
  /// **'Backup Data'**
  String get backupData;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @restoreData.
  ///
  /// In en, this message translates to:
  /// **'Restore Data'**
  String get restoreData;

  /// No description provided for @restoreFromBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get restoreFromBackup;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutTwigaMoney.
  ///
  /// In en, this message translates to:
  /// **'About TwigaMoney'**
  String get aboutTwigaMoney;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'TwigaMoney is a personal finance management & budgeting app that helps you track your money use. This powerful spending tracker saves your money as you can see where your Money goes. It has daily expense tracker, free budget planner, intuitive analysis and many powerful features everything is offline, no internet needed.'**
  String get appDescription;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features:'**
  String get features;

  /// No description provided for @barcodeScanning.
  ///
  /// In en, this message translates to:
  /// **'• Barcode scanning'**
  String get barcodeScanning;

  /// No description provided for @inventoryManagement.
  ///
  /// In en, this message translates to:
  /// **'• Inventory management'**
  String get inventoryManagement;

  /// No description provided for @bluetoothPrinting.
  ///
  /// In en, this message translates to:
  /// **'• Sales, reports, and backups'**
  String get bluetoothPrinting;

  /// No description provided for @darkModeSupport.
  ///
  /// In en, this message translates to:
  /// **'• Dark mode support'**
  String get darkModeSupport;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @planner.
  ///
  /// In en, this message translates to:
  /// **'Planner'**
  String get planner;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNote;

  /// No description provided for @addEvent.
  ///
  /// In en, this message translates to:
  /// **'Add Event'**
  String get addEvent;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @noEvents.
  ///
  /// In en, this message translates to:
  /// **'No events scheduled'**
  String get noEvents;

  /// No description provided for @noNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get noNotes;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @sales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get sales;

  /// No description provided for @finance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get finance;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @newSale.
  ///
  /// In en, this message translates to:
  /// **'New Sale'**
  String get newSale;

  /// No description provided for @scanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get scanBarcode;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @cartSummary.
  ///
  /// In en, this message translates to:
  /// **'Cart Summary'**
  String get cartSummary;

  /// No description provided for @proceedToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get proceedToCheckout;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @budgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @addBudget.
  ///
  /// In en, this message translates to:
  /// **'Add Budget'**
  String get addBudget;

  /// No description provided for @addAccount.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get addAccount;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @profit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get profit;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @todaySales.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Sales'**
  String get todaySales;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @todayPerformance.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Performance'**
  String get todayPerformance;

  /// No description provided for @transactionsCount.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactionsCount;

  /// No description provided for @averageSale.
  ///
  /// In en, this message translates to:
  /// **'Avg Sale'**
  String get averageSale;

  /// No description provided for @lowStockAlert.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alert'**
  String get lowStockAlert;

  /// No description provided for @topProducts.
  ///
  /// In en, this message translates to:
  /// **'Top Products'**
  String get topProducts;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// No description provided for @topSelling.
  ///
  /// In en, this message translates to:
  /// **'Top Selling'**
  String get topSelling;

  /// No description provided for @monthlyReport.
  ///
  /// In en, this message translates to:
  /// **'Monthly Report'**
  String get monthlyReport;

  /// No description provided for @dailyReport.
  ///
  /// In en, this message translates to:
  /// **'Daily Report'**
  String get dailyReport;

  /// No description provided for @weeklyReport.
  ///
  /// In en, this message translates to:
  /// **'Weekly Report'**
  String get weeklyReport;

  /// No description provided for @biweeklyReport.
  ///
  /// In en, this message translates to:
  /// **'Biweekly Report'**
  String get biweeklyReport;

  /// No description provided for @yearlyReport.
  ///
  /// In en, this message translates to:
  /// **'Yearly Report'**
  String get yearlyReport;

  /// No description provided for @shiftReport.
  ///
  /// In en, this message translates to:
  /// **'Shift Report'**
  String get shiftReport;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// No description provided for @syncData.
  ///
  /// In en, this message translates to:
  /// **'Sync Data'**
  String get syncData;

  /// No description provided for @printerSettings.
  ///
  /// In en, this message translates to:
  /// **'Export Settings'**
  String get printerSettings;

  /// No description provided for @connectPrinter.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get connectPrinter;

  /// No description provided for @printReceipt.
  ///
  /// In en, this message translates to:
  /// **'Print Receipt'**
  String get printReceipt;

  /// No description provided for @completeSale.
  ///
  /// In en, this message translates to:
  /// **'Complete Sale'**
  String get completeSale;

  /// No description provided for @noPrinter.
  ///
  /// In en, this message translates to:
  /// **'No export selected'**
  String get noPrinter;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @cartIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartIsEmpty;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @userManagement.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagement;

  /// No description provided for @addUser.
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get addUser;

  /// No description provided for @editUser.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get editUser;

  /// No description provided for @customerManagement.
  ///
  /// In en, this message translates to:
  /// **'Customer Management'**
  String get customerManagement;

  /// No description provided for @addCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add Customer'**
  String get addCustomer;

  /// No description provided for @editCustomer.
  ///
  /// In en, this message translates to:
  /// **'Edit Customer'**
  String get editCustomer;

  /// No description provided for @updateCustomer.
  ///
  /// In en, this message translates to:
  /// **'Update Customer'**
  String get updateCustomer;

  /// No description provided for @deleteCustomer.
  ///
  /// In en, this message translates to:
  /// **'Delete Customer'**
  String get deleteCustomer;

  /// No description provided for @customerTransactions.
  ///
  /// In en, this message translates to:
  /// **'Customer Transactions'**
  String get customerTransactions;

  /// No description provided for @transactionWithId.
  ///
  /// In en, this message translates to:
  /// **'Transaction #{id}'**
  String transactionWithId(Object id);

  /// No description provided for @productManagement.
  ///
  /// In en, this message translates to:
  /// **'Product Management'**
  String get productManagement;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// No description provided for @deleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get deleteProduct;

  /// No description provided for @restock.
  ///
  /// In en, this message translates to:
  /// **'Restock'**
  String get restock;

  /// No description provided for @stockQuantity.
  ///
  /// In en, this message translates to:
  /// **'Stock Quantity'**
  String get stockQuantity;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchProducts;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @addFirstProduct.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add your first product'**
  String get addFirstProduct;

  /// No description provided for @noProductsMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No products match your search'**
  String get noProductsMatchSearch;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @importCsv.
  ///
  /// In en, this message translates to:
  /// **'Import CSV'**
  String get importCsv;

  /// No description provided for @downloadTemplate.
  ///
  /// In en, this message translates to:
  /// **'Download Template'**
  String get downloadTemplate;

  /// No description provided for @productsExportedTo.
  ///
  /// In en, this message translates to:
  /// **'Products exported to: {path}'**
  String productsExportedTo(Object path);

  /// No description provided for @productsImportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'{count} products imported successfully'**
  String productsImportedSuccessfully(Object count);

  /// No description provided for @csvTemplate.
  ///
  /// In en, this message translates to:
  /// **'CSV Template'**
  String get csvTemplate;

  /// No description provided for @csvTemplateNote.
  ///
  /// In en, this message translates to:
  /// **'Use this format for your CSV file:\n\nID,Name,Description,Price,Cost Price,Barcode,Category,Stock Quantity,Min Stock Level,Image URL\nsample-1,Sample Product,Description,10.0,7.0,123456789,Category,100,10,\n\nNote: ID should be unique. Leave empty for auto-generation.'**
  String get csvTemplateNote;

  /// No description provided for @confirmDeleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String confirmDeleteProduct(Object name);

  /// No description provided for @returnProduct.
  ///
  /// In en, this message translates to:
  /// **'Return {name}'**
  String returnProduct(Object name);

  /// No description provided for @quantityToReturn.
  ///
  /// In en, this message translates to:
  /// **'Quantity to Return'**
  String get quantityToReturn;

  /// No description provided for @stockAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Stock Adjustment'**
  String get stockAdjustment;

  /// No description provided for @budgetManagement.
  ///
  /// In en, this message translates to:
  /// **'Budget Management'**
  String get budgetManagement;

  /// No description provided for @editBudget.
  ///
  /// In en, this message translates to:
  /// **'Edit Budget'**
  String get editBudget;

  /// No description provided for @accountManagement.
  ///
  /// In en, this message translates to:
  /// **'Account Management'**
  String get accountManagement;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// No description provided for @filterByDate.
  ///
  /// In en, this message translates to:
  /// **'Filter by Date'**
  String get filterByDate;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get selectDateRange;

  /// No description provided for @pleaseEnterValidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quantity'**
  String get pleaseEnterValidQuantity;

  /// No description provided for @onlyInStock.
  ///
  /// In en, this message translates to:
  /// **'Only {stock} in stock'**
  String onlyInStock(Object stock);

  /// No description provided for @productAddedToCart.
  ///
  /// In en, this message translates to:
  /// **'Product added to cart'**
  String get productAddedToCart;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @searchProduct.
  ///
  /// In en, this message translates to:
  /// **'Search Product'**
  String get searchProduct;

  /// No description provided for @qty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qty;

  /// No description provided for @discountPercent.
  ///
  /// In en, this message translates to:
  /// **'Discount (%)'**
  String get discountPercent;

  /// No description provided for @currentCart.
  ///
  /// In en, this message translates to:
  /// **'Current Cart'**
  String get currentCart;

  /// No description provided for @quickSave.
  ///
  /// In en, this message translates to:
  /// **'Quick Save'**
  String get quickSave;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @scanToPay.
  ///
  /// In en, this message translates to:
  /// **'Scan to Pay'**
  String get scanToPay;

  /// No description provided for @itemsInCart.
  ///
  /// In en, this message translates to:
  /// **'{count} items in cart'**
  String itemsInCart(Object count);

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @ownerProfile.
  ///
  /// In en, this message translates to:
  /// **'Owner Profile'**
  String get ownerProfile;

  /// No description provided for @ownerProfileDesc.
  ///
  /// In en, this message translates to:
  /// **'Your personal information'**
  String get ownerProfileDesc;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @clearCacheDesc.
  ///
  /// In en, this message translates to:
  /// **'Free up space by clearing temp files'**
  String get clearCacheDesc;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @helpCenterDesc.
  ///
  /// In en, this message translates to:
  /// **'FAQs and guides'**
  String get helpCenterDesc;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String hello(Object name);

  /// No description provided for @businessSummary.
  ///
  /// In en, this message translates to:
  /// **'Here is your business summary'**
  String get businessSummary;

  /// No description provided for @netPosition.
  ///
  /// In en, this message translates to:
  /// **'Net Position'**
  String get netPosition;

  /// No description provided for @cashBalance.
  ///
  /// In en, this message translates to:
  /// **'Cash Balance'**
  String get cashBalance;

  /// No description provided for @customerDebt.
  ///
  /// In en, this message translates to:
  /// **'Customer Debt'**
  String get customerDebt;

  /// No description provided for @keyMetrics.
  ///
  /// In en, this message translates to:
  /// **'Key Metrics'**
  String get keyMetrics;

  /// No description provided for @sellItems.
  ///
  /// In en, this message translates to:
  /// **'Sell items'**
  String get sellItems;

  /// No description provided for @operations.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get operations;

  /// No description provided for @dailyTasks.
  ///
  /// In en, this message translates to:
  /// **'Daily tasks'**
  String get dailyTasks;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @manageStock.
  ///
  /// In en, this message translates to:
  /// **'Manage stock'**
  String get manageStock;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @fullReports.
  ///
  /// In en, this message translates to:
  /// **'Full reports'**
  String get fullReports;

  /// No description provided for @manageDebt.
  ///
  /// In en, this message translates to:
  /// **'Manage debt'**
  String get manageDebt;

  /// No description provided for @tasksAndNotes.
  ///
  /// In en, this message translates to:
  /// **'Tasks & Notes'**
  String get tasksAndNotes;

  /// No description provided for @overdueCollections.
  ///
  /// In en, this message translates to:
  /// **'Overdue Collections'**
  String get overdueCollections;

  /// No description provided for @overdueDebtMessage.
  ///
  /// In en, this message translates to:
  /// **'You have {symbol}{amount} in overdue debt.'**
  String overdueDebtMessage(Object amount, Object symbol);

  /// No description provided for @lowStockWarning.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Warning'**
  String get lowStockWarning;

  /// No description provided for @lowStockMessage.
  ///
  /// In en, this message translates to:
  /// **'{count} items are running low on stock.'**
  String lowStockMessage(Object count);

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @myShop.
  ///
  /// In en, this message translates to:
  /// **'My Shop'**
  String get myShop;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get totalIncome;

  /// No description provided for @totalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpenses;

  /// No description provided for @netSavings.
  ///
  /// In en, this message translates to:
  /// **'Net Savings'**
  String get netSavings;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @budgetAlerts.
  ///
  /// In en, this message translates to:
  /// **'Budget Alerts'**
  String get budgetAlerts;

  /// No description provided for @percentSpent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% spent'**
  String percentSpent(Object percent);

  /// No description provided for @monthlyOutlook.
  ///
  /// In en, this message translates to:
  /// **'Monthly Outlook'**
  String get monthlyOutlook;

  /// No description provided for @predictive.
  ///
  /// In en, this message translates to:
  /// **'Predictive'**
  String get predictive;

  /// No description provided for @estMonthEndBalance.
  ///
  /// In en, this message translates to:
  /// **'Est. Month-End Balance'**
  String get estMonthEndBalance;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @tanzanianShilling.
  ///
  /// In en, this message translates to:
  /// **'Tanzanian Shilling (TZS)'**
  String get tanzanianShilling;

  /// No description provided for @usDollar.
  ///
  /// In en, this message translates to:
  /// **'US Dollar (USD)'**
  String get usDollar;

  /// No description provided for @shopProfile.
  ///
  /// In en, this message translates to:
  /// **'Shop Profile'**
  String get shopProfile;

  /// No description provided for @shopName.
  ///
  /// In en, this message translates to:
  /// **'Shop Name'**
  String get shopName;

  /// No description provided for @addressLine1.
  ///
  /// In en, this message translates to:
  /// **'Address Line 1'**
  String get addressLine1;

  /// No description provided for @addressLine2.
  ///
  /// In en, this message translates to:
  /// **'Address Line 2'**
  String get addressLine2;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @upiPaymentId.
  ///
  /// In en, this message translates to:
  /// **'UPI / Payment ID'**
  String get upiPaymentId;

  /// No description provided for @shopLogoText.
  ///
  /// In en, this message translates to:
  /// **'Shop Logo Text'**
  String get shopLogoText;

  /// No description provided for @receiptFooter.
  ///
  /// In en, this message translates to:
  /// **'Receipt Footer'**
  String get receiptFooter;

  /// No description provided for @thankYouMessage.
  ///
  /// In en, this message translates to:
  /// **'Thank you message'**
  String get thankYouMessage;

  /// No description provided for @textShownOnReceipts.
  ///
  /// In en, this message translates to:
  /// **'Text shown on receipts'**
  String get textShownOnReceipts;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @shopProfileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Shop profile updated successfully'**
  String get shopProfileUpdatedSuccessfully;

  /// No description provided for @cacheClearedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get cacheClearedSuccessfully;

  /// No description provided for @errorClearingCache.
  ///
  /// In en, this message translates to:
  /// **'Error clearing cache: {error}'**
  String errorClearingCache(Object error);

  /// No description provided for @backupCreatedAndShared.
  ///
  /// In en, this message translates to:
  /// **'Backup created and shared'**
  String get backupCreatedAndShared;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {error}'**
  String backupFailed(Object error);

  /// No description provided for @restoreDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will replace ALL current data with the selected backup file.\n\nThis action cannot be undone.'**
  String get restoreDataConfirm;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @restoreSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Data restored successfully. Please restart the app.'**
  String get restoreSuccessful;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String restoreFailed(Object error);

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(Object error);

  /// No description provided for @dataExportedAndShared.
  ///
  /// In en, this message translates to:
  /// **'Data exported and shared successfully'**
  String get dataExportedAndShared;

  /// No description provided for @nameAddressContact.
  ///
  /// In en, this message translates to:
  /// **'Name, address, and contact info'**
  String get nameAddressContact;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'required'**
  String get required;

  /// No description provided for @shopNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Shop Name is required'**
  String get shopNameRequired;

  /// No description provided for @addressRequired.
  ///
  /// In en, this message translates to:
  /// **'Address Line 1 is required'**
  String get addressRequired;

  /// No description provided for @refreshList.
  ///
  /// In en, this message translates to:
  /// **'Refresh List'**
  String get refreshList;

  /// No description provided for @searchCustomerHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, phone or email...'**
  String get searchCustomerHint;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @debt.
  ///
  /// In en, this message translates to:
  /// **'Debt'**
  String get debt;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @viewTransactions.
  ///
  /// In en, this message translates to:
  /// **'View Transactions'**
  String get viewTransactions;

  /// No description provided for @deactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivate;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @creditLimit.
  ///
  /// In en, this message translates to:
  /// **'Credit Limit'**
  String get creditLimit;

  /// No description provided for @availableCredit.
  ///
  /// In en, this message translates to:
  /// **'Available Credit'**
  String get availableCredit;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @lastTransaction.
  ///
  /// In en, this message translates to:
  /// **'Last Transaction'**
  String get lastTransaction;

  /// No description provided for @confirmDeleteCustomer.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}? This action cannot be undone.'**
  String confirmDeleteCustomer(Object name);

  /// No description provided for @customerDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Customer deleted successfully'**
  String get customerDeletedSuccessfully;

  /// No description provided for @failedToLoadCustomers.
  ///
  /// In en, this message translates to:
  /// **'Failed to load customers: {error}'**
  String failedToLoadCustomers(Object error);

  /// No description provided for @errorLoadingCustomers.
  ///
  /// In en, this message translates to:
  /// **'Error loading customers: {error}'**
  String errorLoadingCustomers(Object error);

  /// No description provided for @customerActivated.
  ///
  /// In en, this message translates to:
  /// **'Customer activated'**
  String get customerActivated;

  /// No description provided for @customerDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Customer deactivated'**
  String get customerDeactivated;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @nameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameIsRequired;

  /// No description provided for @phoneNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneNumberRequired;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @enterValidCreditLimit.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid credit limit'**
  String get enterValidCreditLimit;

  /// No description provided for @customerAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Customer added successfully'**
  String get customerAddedSuccessfully;

  /// No description provided for @customerUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Customer updated successfully'**
  String get customerUpdatedSuccessfully;

  /// No description provided for @failedToLoadCustomer.
  ///
  /// In en, this message translates to:
  /// **'Failed to load customer: {error}'**
  String failedToLoadCustomer(Object error);

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactionsFound;

  /// No description provided for @totalTransactions.
  ///
  /// In en, this message translates to:
  /// **'Total Transactions'**
  String get totalTransactions;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @numberOfTransactions.
  ///
  /// In en, this message translates to:
  /// **'Number of Transactions'**
  String get numberOfTransactions;

  /// No description provided for @transactionDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetails;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @customerNotFound.
  ///
  /// In en, this message translates to:
  /// **'Customer not found'**
  String get customerNotFound;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFound;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faq;

  /// No description provided for @faqAddProductTitle.
  ///
  /// In en, this message translates to:
  /// **'How do I add a new product?'**
  String get faqAddProductTitle;

  /// No description provided for @faqAddProductContent.
  ///
  /// In en, this message translates to:
  /// **'Go to Products > Add Product and fill in the details.'**
  String get faqAddProductContent;

  /// No description provided for @faqProcessSaleTitle.
  ///
  /// In en, this message translates to:
  /// **'How do I process a sale?'**
  String get faqProcessSaleTitle;

  /// No description provided for @faqProcessSaleContent.
  ///
  /// In en, this message translates to:
  /// **'Use the New Sale screen to add items manually or search, then checkout.'**
  String get faqProcessSaleContent;

  /// No description provided for @faqBackupDataTitle.
  ///
  /// In en, this message translates to:
  /// **'How do I backup my data?'**
  String get faqBackupDataTitle;

  /// No description provided for @faqBackupDataContent.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings > Data Management > Backup Data.'**
  String get faqBackupDataContent;

  /// No description provided for @faqDarkModeTitle.
  ///
  /// In en, this message translates to:
  /// **'How do I switch to dark mode?'**
  String get faqDarkModeTitle;

  /// No description provided for @faqDarkModeContent.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings > Appearance and select Dark Mode.'**
  String get faqDarkModeContent;

  /// No description provided for @faqShopProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'How do I customize my shop profile?'**
  String get faqShopProfileTitle;

  /// No description provided for @faqShopProfileContent.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings > Shop Details to edit name, address, and contact info.'**
  String get faqShopProfileContent;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @updateProfileInfo.
  ///
  /// In en, this message translates to:
  /// **'Update your name, email, and photo'**
  String get updateProfileInfo;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @updateYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Update your password'**
  String get updateYourPassword;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @exports.
  ///
  /// In en, this message translates to:
  /// **'Exports'**
  String get exports;

  /// No description provided for @exportInvoices.
  ///
  /// In en, this message translates to:
  /// **'Export Invoices'**
  String get exportInvoices;

  /// No description provided for @exportAsPdf.
  ///
  /// In en, this message translates to:
  /// **'Export as PDF'**
  String get exportAsPdf;

  /// No description provided for @shareData.
  ///
  /// In en, this message translates to:
  /// **'Share Data'**
  String get shareData;

  /// No description provided for @exportAllData.
  ///
  /// In en, this message translates to:
  /// **'Export all data'**
  String get exportAllData;

  /// No description provided for @backupToCloud.
  ///
  /// In en, this message translates to:
  /// **'Backup to cloud'**
  String get backupToCloud;

  /// No description provided for @freeUpSpace.
  ///
  /// In en, this message translates to:
  /// **'Free up space'**
  String get freeUpSpace;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @clearAllData.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data'**
  String get clearAllData;

  /// No description provided for @confirmClearAllData.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all data? This action cannot be undone.'**
  String get confirmClearAllData;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter new password:'**
  String get enterNewPassword;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdated;

  /// No description provided for @noInvoicesToExport.
  ///
  /// In en, this message translates to:
  /// **'No invoices to export'**
  String get noInvoicesToExport;

  /// No description provided for @invoiceExportTitle.
  ///
  /// In en, this message translates to:
  /// **'TwigaMoney Invoice Export'**
  String get invoiceExportTitle;

  /// No description provided for @invoicesExportedAndShared.
  ///
  /// In en, this message translates to:
  /// **'{count} invoices exported and shared'**
  String invoicesExportedAndShared(Object count);

  /// No description provided for @recordsExportedAsCsv.
  ///
  /// In en, this message translates to:
  /// **'{count} records exported as CSV'**
  String recordsExportedAsCsv(Object count);

  /// No description provided for @backingUpData.
  ///
  /// In en, this message translates to:
  /// **'Backing up data...'**
  String get backingUpData;

  /// No description provided for @backupCompleted.
  ///
  /// In en, this message translates to:
  /// **'Backup completed and shared'**
  String get backupCompleted;

  /// No description provided for @noBackupFound.
  ///
  /// In en, this message translates to:
  /// **'No backup file found in storage'**
  String get noBackupFound;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore Backup?'**
  String get restoreBackup;

  /// No description provided for @restoreConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will replace all current data with the data from this backup.\n\nBackup file:\n{file}\n\nThis action cannot be undone.'**
  String restoreConfirmMessage(Object file);

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared'**
  String get cacheCleared;

  /// No description provided for @clearCacheConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will free up storage used by temporary files and cached data. Your settings and data will not be affected.'**
  String get clearCacheConfirm;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @allDataCleared.
  ///
  /// In en, this message translates to:
  /// **'All data cleared'**
  String get allDataCleared;

  /// No description provided for @failedToClearData.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear data: {error}'**
  String failedToClearData(Object error);

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 TwigaMoney. All rights reserved.'**
  String get copyright;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @videoTutorial.
  ///
  /// In en, this message translates to:
  /// **'Video Tutorial'**
  String get videoTutorial;

  /// No description provided for @watchHowToUse.
  ///
  /// In en, this message translates to:
  /// **'Watch how to use TwigaMoney'**
  String get watchHowToUse;

  /// No description provided for @documentation.
  ///
  /// In en, this message translates to:
  /// **'Documentation'**
  String get documentation;

  /// No description provided for @readUserGuide.
  ///
  /// In en, this message translates to:
  /// **'Read the user guide'**
  String get readUserGuide;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @generateCustomReport.
  ///
  /// In en, this message translates to:
  /// **'Generate Custom Report'**
  String get generateCustomReport;

  /// No description provided for @reportType.
  ///
  /// In en, this message translates to:
  /// **'Report Type'**
  String get reportType;

  /// No description provided for @salesReport.
  ///
  /// In en, this message translates to:
  /// **'Sales Report'**
  String get salesReport;

  /// No description provided for @productsReport.
  ///
  /// In en, this message translates to:
  /// **'Products Report'**
  String get productsReport;

  /// No description provided for @financeReport.
  ///
  /// In en, this message translates to:
  /// **'Finance Report'**
  String get financeReport;

  /// No description provided for @customersReport.
  ///
  /// In en, this message translates to:
  /// **'Customers Report'**
  String get customersReport;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @customReportPeriod.
  ///
  /// In en, this message translates to:
  /// **'{reportType} report generated for custom period'**
  String customReportPeriod(Object reportType);

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @shareReport.
  ///
  /// In en, this message translates to:
  /// **'Share Report'**
  String get shareReport;

  /// No description provided for @refreshData.
  ///
  /// In en, this message translates to:
  /// **'Refresh Data'**
  String get refreshData;

  /// No description provided for @newReport.
  ///
  /// In en, this message translates to:
  /// **'New Report'**
  String get newReport;

  /// No description provided for @todaySalesLabel.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Sales'**
  String get todaySalesLabel;

  /// No description provided for @yesterdaySalesLabel.
  ///
  /// In en, this message translates to:
  /// **'Yesterday\'s Sales'**
  String get yesterdaySalesLabel;

  /// No description provided for @totalRevenueLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenueLabel;

  /// No description provided for @totalProfitLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Profit'**
  String get totalProfitLabel;

  /// No description provided for @revenueTrend.
  ///
  /// In en, this message translates to:
  /// **'Revenue Trend'**
  String get revenueTrend;

  /// No description provided for @profitTrend.
  ///
  /// In en, this message translates to:
  /// **'Profit Trend'**
  String get profitTrend;

  /// No description provided for @recentSales.
  ///
  /// In en, this message translates to:
  /// **'Recent Sales'**
  String get recentSales;

  /// No description provided for @bestSellers.
  ///
  /// In en, this message translates to:
  /// **'Best Sellers'**
  String get bestSellers;

  /// No description provided for @lowTurnoverProducts.
  ///
  /// In en, this message translates to:
  /// **'Low Turnover Products'**
  String get lowTurnoverProducts;

  /// No description provided for @financialSummary.
  ///
  /// In en, this message translates to:
  /// **'Financial Summary'**
  String get financialSummary;

  /// No description provided for @totalCustomers.
  ///
  /// In en, this message translates to:
  /// **'Total Customers'**
  String get totalCustomers;

  /// No description provided for @customerList.
  ///
  /// In en, this message translates to:
  /// **'Customer List'**
  String get customerList;

  /// No description provided for @noPhone.
  ///
  /// In en, this message translates to:
  /// **'No phone'**
  String get noPhone;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'balance'**
  String get balance;

  /// No description provided for @reportExportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Report exported and shared successfully'**
  String get reportExportedSuccessfully;

  /// No description provided for @csvReportExported.
  ///
  /// In en, this message translates to:
  /// **'CSV report exported and shared'**
  String get csvReportExported;

  /// No description provided for @failedToLoadSalesData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load sales data'**
  String get failedToLoadSalesData;

  /// No description provided for @failedToLoadRevenueData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load revenue data'**
  String get failedToLoadRevenueData;

  /// No description provided for @failedToLoadProfitData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profit data'**
  String get failedToLoadProfitData;

  /// No description provided for @failedToLoadProductAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Failed to load product analytics'**
  String get failedToLoadProductAnalytics;

  /// No description provided for @failedToLoadLowTurnoverData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load low turnover data'**
  String get failedToLoadLowTurnoverData;

  /// No description provided for @failedToLoadFinancialData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load financial data'**
  String get failedToLoadFinancialData;

  /// No description provided for @failedToLoadCustomerData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load customer data'**
  String get failedToLoadCustomerData;

  /// No description provided for @errorLoadingReportData.
  ///
  /// In en, this message translates to:
  /// **'Error loading report data: {error}'**
  String errorLoadingReportData(Object error);

  /// No description provided for @twigaMoneyReport.
  ///
  /// In en, this message translates to:
  /// **'TwigaMoney Report'**
  String get twigaMoneyReport;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period: {start} to {end}'**
  String period(Object end, Object start);

  /// No description provided for @reportGeneratedOn.
  ///
  /// In en, this message translates to:
  /// **'Report generated on {date}'**
  String reportGeneratedOn(Object date);

  /// No description provided for @transactionsWithCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No transactions} =1{1 transaction} other{{count} transactions}}'**
  String transactionsWithCount(num count);

  /// No description provided for @shiftStarted.
  ///
  /// In en, this message translates to:
  /// **'Shift started'**
  String get shiftStarted;

  /// No description provided for @shiftEnded.
  ///
  /// In en, this message translates to:
  /// **'Shift ended'**
  String get shiftEnded;

  /// No description provided for @cashDrop.
  ///
  /// In en, this message translates to:
  /// **'Cash Drop'**
  String get cashDrop;

  /// No description provided for @cashDropRecorded.
  ///
  /// In en, this message translates to:
  /// **'Cash drop of {currency} {amount} recorded'**
  String cashDropRecorded(Object amount, Object currency);

  /// No description provided for @record.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get record;

  /// No description provided for @shiftActiveStatus.
  ///
  /// In en, this message translates to:
  /// **'Shift is Active'**
  String get shiftActiveStatus;

  /// No description provided for @shiftClosedStatus.
  ///
  /// In en, this message translates to:
  /// **'Shift is Closed'**
  String get shiftClosedStatus;

  /// No description provided for @recordingSales.
  ///
  /// In en, this message translates to:
  /// **'Currently recording sales'**
  String get recordingSales;

  /// No description provided for @startShiftToBegin.
  ///
  /// In en, this message translates to:
  /// **'Start a shift to begin selling'**
  String get startShiftToBegin;

  /// No description provided for @endCurrentShift.
  ///
  /// In en, this message translates to:
  /// **'End Current Shift'**
  String get endCurrentShift;

  /// No description provided for @startNewShift.
  ///
  /// In en, this message translates to:
  /// **'Start New Shift'**
  String get startNewShift;

  /// No description provided for @endOfDay.
  ///
  /// In en, this message translates to:
  /// **'End of Day'**
  String get endOfDay;

  /// No description provided for @viewReports.
  ///
  /// In en, this message translates to:
  /// **'View Reports'**
  String get viewReports;

  /// No description provided for @action.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get action;

  /// No description provided for @appDescriptionLong.
  ///
  /// In en, this message translates to:
  /// **'TwigaMoney is a personal finance management & budgeting app that helps you track your money use. This powerful spending tracker saves your money as you can see where your Money goes. It has daily expense tracker, free budget planner, intuitive analysis and many powerful features everything is offline, no internet needed.\n\nUse it for some days and you will see the differences.\n\nHow to manage Money and track expenses? Just add an expense record when you are spending some. TwigaMoney will take care of it. TwigaMoney is your ultimate budget planner that helps you achieve your budget goals. Too much spending on coffee? Set a budget on coffee and surely, you would not cross the budget target. This limits your expenses and helps you control your spending behaviour. If you really want to save Money and understand your expenses, TwigaMoney is the perfect app that can help you.'**
  String get appDescriptionLong;

  /// No description provided for @keyFeatures.
  ///
  /// In en, this message translates to:
  /// **'Key Features'**
  String get keyFeatures;

  /// No description provided for @featuresDetail.
  ///
  /// In en, this message translates to:
  /// **'Organizing your expenses allows you to have better control over your money.\n\n• Expense Manager\nTrack your income and expenses, classify them by category. Create categories as many as you need. You can modify or delete the records that you have created.\n\n• Budget Planner\nPlan monthly budget to boost savings. Try not to cross your budget target.\n\n• Effective Analysis & Graphical Reports\nSee your monthly income and expense analysis with clean charts. Create graphical reports.\n\n• Recurring Transactions\nSchedule recurring records, so the application automatically adds repetitive movements in fixed periods.\n\n• Quick Homescreen Widget\nTwigaMoney\'s smart homescreen widget helps you keep an eye on your balance and add records on the go, with a monthly summary widget.\n\n• Periodic Reports\nThe application shows reports grouped by periods along with your balance period. Available reports: daily, weekly, biweekly, monthly and yearly.\n\n• Simple & Easy\nIts simple and easy to use interface will surely make you love it.\n\n• Offline\nFully offline, no internet required to use TwigaMoney.\n\n• Wallet, Cards Separately\nMultiple accounts for managing wallet, cards, savings etc. No limitation on account creation.\n\n• Personal\nChoose the currency format and the date format used in your country. Select preferred category & account icons, titles.\n\n• Tablet Support\nHorizontal screen layout optimized for tablets.\n\n• Safe & Secured\nThe application lets you create a backup of your database to restore your information if necessary. Keep your record data safe with backups. Restore them if necessary. Export worksheets to print the records.\n\n💰 TRACK EVERYTHING\nTrack your expenses, income, savings, investments, and net worth in one place.\nVisualize your cash flow with clean, easy charts.\n\n📊 BUDGET WITH CONFIDENCE\nSet monthly budgets, control your spending, and stay on top of your financial goals.\nNo more end-of-month surprises.\n\n🔮 PLAN YOUR FUTURE\nUse smart tools to plan ahead:\nEmergency Fund Calculator – Know how long your money will last\nGoal Tracker – See exactly when you\'ll reach savings targets\nRetirement Planner – Find your financial freedom date\n\n📈 GROW YOUR WEALTH\nTrack stocks, crypto, and investments effortlessly.\nYour complete portfolio, in your pocket.\n\n🔒 100% PRIVATE\nNo logins\nNo cloud\nNo tracking\nEverything stays on your device.\n\n⚙️ BUILT FOR YOU\nCustom categories, icons & themes.\nMulti-currency support.\nSimple import & export.\nWorks fully offline.'**
  String get featuresDetail;

  /// No description provided for @personalFinanceTracker.
  ///
  /// In en, this message translates to:
  /// **'Personal Finance Tracker'**
  String get personalFinanceTracker;

  /// No description provided for @addFirstExpenseIncome.
  ///
  /// In en, this message translates to:
  /// **'Add your first expense or income'**
  String get addFirstExpenseIncome;

  /// No description provided for @quickAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get quickAccess;

  /// No description provided for @plannerCalendar.
  ///
  /// In en, this message translates to:
  /// **'Planner & Calendar'**
  String get plannerCalendar;

  /// No description provided for @errorLoadingTransactions.
  ///
  /// In en, this message translates to:
  /// **'Error loading transactions'**
  String get errorLoadingTransactions;

  /// No description provided for @selectMonth.
  ///
  /// In en, this message translates to:
  /// **'Select Month'**
  String get selectMonth;

  /// No description provided for @expensesByCategory.
  ///
  /// In en, this message translates to:
  /// **'Expenses by Category'**
  String get expensesByCategory;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @errorLoadingReport.
  ///
  /// In en, this message translates to:
  /// **'Error loading report'**
  String get errorLoadingReport;

  /// No description provided for @noExpensesMonth.
  ///
  /// In en, this message translates to:
  /// **'No expenses this month'**
  String get noExpensesMonth;

  /// No description provided for @reportExportedCount.
  ///
  /// In en, this message translates to:
  /// **'Report exported: {count} transactions'**
  String reportExportedCount(Object count);

  /// No description provided for @reportReadyShare.
  ///
  /// In en, this message translates to:
  /// **'Report ready to share:'**
  String get reportReadyShare;

  /// No description provided for @noAccountsYet.
  ///
  /// In en, this message translates to:
  /// **'No accounts yet'**
  String get noAccountsYet;

  /// No description provided for @addFirstAccount.
  ///
  /// In en, this message translates to:
  /// **'Add your first account'**
  String get addFirstAccount;

  /// No description provided for @manageAccounts.
  ///
  /// In en, this message translates to:
  /// **'Manage Accounts'**
  String get manageAccounts;

  /// No description provided for @errorLoadingAccounts.
  ///
  /// In en, this message translates to:
  /// **'Error loading accounts'**
  String get errorLoadingAccounts;

  /// No description provided for @noBudgetsYet.
  ///
  /// In en, this message translates to:
  /// **'No budgets yet'**
  String get noBudgetsYet;

  /// No description provided for @addFirstBudget.
  ///
  /// In en, this message translates to:
  /// **'Create your first budget'**
  String get addFirstBudget;

  /// No description provided for @createBudget.
  ///
  /// In en, this message translates to:
  /// **'Create Budget'**
  String get createBudget;

  /// No description provided for @errorLoadingBudgets.
  ///
  /// In en, this message translates to:
  /// **'Error loading budgets'**
  String get errorLoadingBudgets;

  /// No description provided for @spentOf.
  ///
  /// In en, this message translates to:
  /// **'Spent: {spent} / {total}'**
  String spentOf(Object spent, Object total);

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @icon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @noCategoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get noCategoriesYet;

  /// No description provided for @addFirstCategory.
  ///
  /// In en, this message translates to:
  /// **'Add your first category'**
  String get addFirstCategory;

  /// No description provided for @errorLoadingCategories.
  ///
  /// In en, this message translates to:
  /// **'Error loading categories'**
  String get errorLoadingCategories;

  /// No description provided for @todaysEvents.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Events'**
  String get todaysEvents;

  /// No description provided for @noEventsDay.
  ///
  /// In en, this message translates to:
  /// **'No events for this day'**
  String get noEventsDay;

  /// No description provided for @quickNotes.
  ///
  /// In en, this message translates to:
  /// **'Quick Notes'**
  String get quickNotes;

  /// No description provided for @dateFormat.
  ///
  /// In en, this message translates to:
  /// **'Date Format'**
  String get dateFormat;

  /// No description provided for @selectDateFormat.
  ///
  /// In en, this message translates to:
  /// **'Select Date Format'**
  String get selectDateFormat;

  /// No description provided for @dateFormatShort.
  ///
  /// In en, this message translates to:
  /// **'MM/dd/yyyy'**
  String get dateFormatShort;

  /// No description provided for @dateFormatMedium.
  ///
  /// In en, this message translates to:
  /// **'dd MMM yyyy'**
  String get dateFormatMedium;

  /// No description provided for @dateFormatIso.
  ///
  /// In en, this message translates to:
  /// **'yyyy-MM-dd'**
  String get dateFormatIso;

  /// No description provided for @dateFormatEuropean.
  ///
  /// In en, this message translates to:
  /// **'dd/MM/yyyy'**
  String get dateFormatEuropean;

  /// No description provided for @financialTools.
  ///
  /// In en, this message translates to:
  /// **'Financial Tools'**
  String get financialTools;

  /// No description provided for @emergencyFundCalculator.
  ///
  /// In en, this message translates to:
  /// **'Emergency Fund Calculator'**
  String get emergencyFundCalculator;

  /// No description provided for @goalTracker.
  ///
  /// In en, this message translates to:
  /// **'Goal Tracker'**
  String get goalTracker;

  /// No description provided for @retirementPlanner.
  ///
  /// In en, this message translates to:
  /// **'Retirement Planner'**
  String get retirementPlanner;

  /// No description provided for @monthlyExpenses.
  ///
  /// In en, this message translates to:
  /// **'Monthly Expenses'**
  String get monthlyExpenses;

  /// No description provided for @emergencyFund.
  ///
  /// In en, this message translates to:
  /// **'Emergency Fund'**
  String get emergencyFund;

  /// No description provided for @monthsOfCoverage.
  ///
  /// In en, this message translates to:
  /// **'Months of Coverage'**
  String get monthsOfCoverage;

  /// No description provided for @targetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target Amount'**
  String get targetAmount;

  /// No description provided for @currentAmount.
  ///
  /// In en, this message translates to:
  /// **'Current Amount'**
  String get currentAmount;

  /// No description provided for @monthlyContribution.
  ///
  /// In en, this message translates to:
  /// **'Monthly Contribution'**
  String get monthlyContribution;

  /// No description provided for @monthsToGoal.
  ///
  /// In en, this message translates to:
  /// **'Months to Reach Goal'**
  String get monthsToGoal;

  /// No description provided for @yearsToGoal.
  ///
  /// In en, this message translates to:
  /// **'Years to Reach Goal'**
  String get yearsToGoal;

  /// No description provided for @currentAge.
  ///
  /// In en, this message translates to:
  /// **'Current Age'**
  String get currentAge;

  /// No description provided for @retirementAge.
  ///
  /// In en, this message translates to:
  /// **'Retirement Age'**
  String get retirementAge;

  /// No description provided for @expectedReturn.
  ///
  /// In en, this message translates to:
  /// **'Expected Annual Return (%)'**
  String get expectedReturn;

  /// No description provided for @projectedSavings.
  ///
  /// In en, this message translates to:
  /// **'Projected Savings at Retirement'**
  String get projectedSavings;

  /// No description provided for @investmentNeeded.
  ///
  /// In en, this message translates to:
  /// **'Monthly Investment Needed'**
  String get investmentNeeded;

  /// No description provided for @calculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get calculate;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @analysis.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get analysis;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @invalidInput.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid numbers in all fields'**
  String get invalidInput;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @cashFlowTrend.
  ///
  /// In en, this message translates to:
  /// **'Cash Flow Trend'**
  String get cashFlowTrend;

  /// No description provided for @expenseByCategory.
  ///
  /// In en, this message translates to:
  /// **'Expense by Category'**
  String get expenseByCategory;

  /// No description provided for @debtAging.
  ///
  /// In en, this message translates to:
  /// **'Debt Aging'**
  String get debtAging;

  /// No description provided for @outstandingBalances.
  ///
  /// In en, this message translates to:
  /// **'Outstanding Balances'**
  String get outstandingBalances;

  /// No description provided for @peakHours.
  ///
  /// In en, this message translates to:
  /// **'Peak Hours Analysis'**
  String get peakHours;

  /// No description provided for @savingsGoal.
  ///
  /// In en, this message translates to:
  /// **'Savings Goal'**
  String get savingsGoal;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
