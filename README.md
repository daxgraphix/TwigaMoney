# 🛒 TwigaMoney — Personal Finance & Budgeting App

**TwigaMoney** is an offline-first personal finance management & budgeting application designed to help you track expenses, income, savings, investments, and net worth — all from your device with zero cloud dependency.

---

## 📖 Overview

TwigaMoney empowers you to take full control of your finances. Organize your expenses, set budgets, schedule recurring transactions, generate reports across multiple time periods, and plan for the future with powerful financial tools — all while keeping your data 100% private and local.

---

## ✨ Key Features

### 💰 Track Everything
Track your expenses, income, savings, investments, and net worth in one place. Visualize your cash flow with clean, easy charts.

- **Expense Manager** — Classify transactions by category. Create unlimited categories.
- **Wallet & Cards** — Multiple accounts for managing wallet, cards, savings, and investment accounts.
- **Modify / Delete Records** — Edit or remove any transaction you've created.
- **Graphical Reports** — See your financial data with `fl_chart` pie charts and trend analysis.
- **Monthly Summary Widget** — Home dashboard widget showing your month-at-a-glance overview.

### 📊 Budget With Confidence
Set monthly budgets, control your spending, and stay on top of your financial goals. No more end-of-month surprises.

- **Budget Planner** — Allocate budget per category and track spending against targets.
- **Budget Alerts** — Automatic warnings when spending approaches 80% of a budget.
- **Daily / Weekly / Biweekly / Monthly / Yearly Reports** — Reports grouped by period with balance summaries.

### 🔮 Plan Your Future
Smart financial planning tools to help you prepare for tomorrow.

- **Emergency Fund Calculator** — Calculates how long your emergency fund will last based on monthly expenses.
- **Goal Tracker** — See exactly when you'll reach your savings targets given a fixed monthly contribution.
- **Retirement Planner** — Projects retirement savings using compound interest and calculates the monthly investment needed to meet your goal.
- **Recurring Transactions** — Schedule repetitive transactions (daily, weekly, monthly, yearly) that auto-generate on the scheduled date.

### 📈 Grow Your Wealth
Track stocks, crypto, and investments effortlessly. Your complete portfolio, in your pocket.

- **Investment Accounts** — Dedicated account type for tracking stocks, crypto, and other investments.
- **Portfolio Tracking** — View and manage all investment accounts alongside other financial accounts.

### 🔒 100% Private
- **No logins** — Full access without registration.
- **No cloud** — All data stored locally using Hive.
- **No tracking** — Zero analytics or data collection.

### ⚙️ Built For You
- **Custom Categories & Icons** — Personalize categories with custom names, colors, and icons.
- **Multi-Currency Support** — Supports TZS (Tanzanian Shilling) and USD, with exchange rates.
- **Currency & Date Format Selection** — Choose your preferred currency symbol and date format (MM/dd/yyyy, dd MMM yyyy, yyyy-MM-dd, dd/MM/yyyy).
- **Simple Import & Export** — Export transactions and budgets to CSV. Restore from database backups.
- **Fully Offline** — Works without internet.
- **Tablet Support** — Responsive layouts optimized for tablets and horizontal screens.

---

## 🏗️ Architecture

TwigaMoney follows a feature-first Clean Architecture pattern:

```
lib/
├── core/                      # Core utilities, theme, database, error handling
│   ├── data/hive_database.dart    # Hive box registration & initialization
│   ├── error/failure.dart         # Failure types for error handling
│   ├── service_locator.dart       # Dependency injection (get_it)
│   ├── theme/app_theme.dart       # Theme, currency, and date format utilities
│   └── utils/responsive.dart      # Responsive layout helpers
├── features/
│   ├── billing/               # Billing / POS / finance dashboard
│   ├── finance/               # Financial tracking (transactions, budgets, reports)
│   │   ├── data/              # Repositories & Hive data sources
│   │   ├── domain/            # Entities (Transaction, Account, Budget, etc.)
│   │   └── presentation/      # BLoC, Pages, Widgets
│   ├── planner/               # Calendar & planner
│   ├── product/               # Product management
│   ├── settings/              # Settings & preferences
│   └── shop/                  # Shop details
├── config/
│   └── routes/app_routes.dart     # GoRouter route configuration
└── l10n/                        # Localization (English-only)
```

---

## 🧱 State Management

- **Flutter BLoC** — Used for all feature state management:
  - `FinanceBloc` — Categories, accounts, transactions
  - `TransactionBloc` — CRUD operations for transactions
  - `AccountCubit` — Account management
  - `BudgetCubit` — Budget CRUD with alert state
  - `ReportCubit` — Report generation (daily, weekly, biweekly, monthly, yearly)
  - `ShopBloc` — Shop/profile details

---

## 🗺️ Navigation

Built with **GoRouter** — type-safe routing with:

| Route | Screen |
|-------|--------|
| `/` | Finance Dashboard |
| `/transactions` | Transaction List |
| `/budgets` | Budget List |
| `/accounts` | Account List |
| `/categories` | Category Management |
| `/analysis` | Financial Analysis |
| `/more` | More Tools (grid of tiles) |
| `/financial-tools` | Financial calculators (Emergency Fund, Goal Tracker, Retirement Planner) |
| `/planner` | Calendar & notes planner |
| `/reports` | Financial reports |
| `/settings` | App settings |
| `/add-transaction` | Add/Edit transaction |
| `/about` | About the app |

---

## 🗄️ Data Layer

All data is stored **locally** using **Hive** — no external servers or cloud sync.

| Hive Box | Purpose |
|----------|---------|
| `settings` | User preferences (currency, date format, dark mode, language) |
| `transactions` | Income/expense records |
| `accounts` | Wallet, card, bank, investment accounts |
| `categories` | Expense/income categories |
| `budgets` | Monthly budget allocations |
| `recurring_transactions` | Recurring transaction templates |
| `planner_events` | Calendar events |
| `planner_notes` | Notes |

**Database features:**
- **Backup** — Export full Hive database to a file.
- **Restore** — Import database from a backup file.
- **CSV Export** — Export transactions and budgets to CSV format.

---

## 🌐 Localization

- **Languages:** English (Swahili support removed; app is English-focused)
- **Date Formats:** Configurable via settings — `MM/dd/yyyy`, `dd MMM yyyy`, `yyyy-MM-dd`, `dd/MM/yyyy`
- **Currency:** Configurable via settings — TZS (TSh), USD ($)

---

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_bloc` | State management (BLoC/Cubit) |
| `get_it` | Service locator / dependency injection |
| `equatable` | Value equality for BLoC state |
| `fpdart` | Functional programming (Either/Maybe types) |
| `go_router` | Navigation & routing |
| `hive` / `hive_flutter` | Local NoSQL database |
| `intl` | Internationalization utilities |
| `fl_chart` | Data visualization (charts) |
| `table_calendar` | Calendar UI |
| `csv` | CSV import/export |
| `file_picker` | File selection for backup/restore/import |
| `pdf` | PDF report generation |
| `google_fonts` | Custom typography |
| `mobile_scanner` | Barcode/QR scanning |
| `pretty_qr_code` | QR code generation |
| `uuid` | Unique ID generation |
| `permission_handler` | Runtime permissions |
| `share_plus` | File sharing |
| `url_launcher` | External links |
| `path_provider` | File system access |

---

## 📱 Platforms

- Android (primary)
- Web
- Windows

---

## 🚀 Getting Started

```bash
# Install dependencies
flutter pub get

# Generate Hive type adapters
flutter pub run build_runner build --delete-conflicting-outputs

# Generate localization files
flutter gen-l10n

# Run the app
flutter run
```

---

## 📄 License

© 2026 TwigaMoney. All rights reserved.
