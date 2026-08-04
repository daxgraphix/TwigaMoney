# TwigaMoney 🦒💰

TwigaMoney is a robust, **fully offline** Point of Sale (POS) and Personal Finance Management application designed for retail shops and individual budgeting. Built with Flutter, it prioritizes privacy, speed, and reliability by keeping all data locally on the device.

## 🌟 Key Features

### 🏪 Business Management (POS)
- **Shift Management**: Track cashier sessions with detailed start/end reports and cash drop tracking.
- **Inventory Control**: Real-time stock monitoring, low-stock alerts, and barcode scanning support.
- **Sales Tracking**: Process transactions quickly, manage discounts, and generate digital/PDF receipts.
- **Customer Relations**: Track customer debt, transaction history, and credit limits.
- **Analytics**: Deep dive into revenue trends, profit margins, and best-selling products.

### 💸 Personal Finance & Budgeting
- **Transaction Manager**: Categorize income and expenses with support for recurring movements.
- **Budget Planner**: Set monthly limits per category and track spending with visual progress bars.
- **Accounts Management**: Handle multiple wallets, bank accounts, and savings goals separately.
- **Financial Tools**: Emergency fund calculator, goal tracker, and retirement planner.
- **Visual Insights**: Intuitive charts and graphs for cash flow and expense distribution.

### 🛡️ Data & Privacy
- **100% Offline**: No internet required. Your data never leaves your device.
- **Robust Backup/Restore**: Export all data to a secure JSON snapshot. Compliant with Android 13+ storage constraints using a sharing-based workflow.
- **Manual Restoration**: Easily restore data from any accessible storage provider using `FilePicker`.
- **Cache Management**: Clean up temporary export files to save device space.

## 🌍 Localization
Fully localized in:
- **English** 🇺🇸
- **Kiswahili** 🇹🇿

## 🛠️ Technical Stack

- **Framework**: Flutter (Stable Channel)
- **State Management**: `flutter_bloc` (BLoC Pattern)
- **Persistence**: `Hive` (NoSQL Database) for high-performance local storage.
- **Navigation**: `go_router`
- **Dependency Injection**: `get_it`
- **Reporting**: `pdf` for invoice generation, `fl_chart` for analytics.
- **UI Components**: Material 3 design system with responsive layouts.

## 📂 Project Structure

```text
lib/
├── config/             # Routes and App Config
├── core/               # Shared widgets, themes, data providers (HiveDatabase)
│   └── utils/          # Responsive helpers, CSV/PDF services
├── features/           # Feature-first architecture
│   ├── auth/           # Login and Account protection
│   ├── billing/        # Sales, Shifts, Customers, Invoices
│   ├── finance/        # Transactions, Budgets, Categories, Tools
│   ├── product/        # Inventory and Stock management
│   ├── shop/           # Business profile and Receipt settings
│   └── splash/         # Onboarding and Initializing
└── l10n/               # ARB files for Internationalization
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK: `^3.44.0`
- Dart SDK: `^3.12.0`

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/youruser/twigamoney.git
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Generate Hive Adapters:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## 📋 Operation Workflow

1. **Setup**: Complete the "Shop Profile" in Settings to customize receipts.
2. **Inventory**: Add products or import them via CSV.
3. **Daily Cycle**:
   - Navigate to **Operations** and **Start Shift**.
   - Use **New Sale** to scan or select items.
   - Record **Cash Drops** if necessary.
   - **End Shift** to view a summary of the day's performance.
4. **Data Safety**: Regularly go to **Settings > Data Management** to create a backup and share it to your preferred cloud storage or external drive.

## ⚖️ License
© 2026 TwigaMoney. All rights reserved. Designed for privacy and local business empowerment.
