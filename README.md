# Expense Charts

[![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/HeatherShein/expense-charts)

A modern Flutter app for tracking personal expenses and income with beautiful visualizations and Google Drive synchronization.

## Table of Contents

1. [Features](#features)
2. [Architecture](#architecture)
3. [Installation](#installation)
4. [Usage](#usage)
5. [Google Drive Sync](#google-drive-sync)
6. [Development](#development)

## Features

### Core Functionality
- **Manual Entry**: Add expenses and income with categories, labels, and amounts
- **Period Tracking**: Track expenses over multiple days (e.g., hotel stays)
- **Budget Management**: Set and track remaining budget with automatic updates
- **Data Visualization**: Interactive charts and graphs for expense analysis

### Pages
- **Bar Chart**: Daily, Weekly, Monthly, and Yearly expense aggregations
- **Pie Chart**: Category breakdown with budget tracking
- **Details**: List view with filtering and search capabilities

### Data Management
- **Local Storage**: SQLite database for offline access
- **Import/Export**: CSV and database file support with proper formatting
- **Data Backup**: Export functionality for data preservation
- **CSV Format**: Exports data in the same format as your Python processing script

### Categories
- Alcohol, Exceptional, Grocery, Health, Leisure, Regular, Restaurant, Trip

## Architecture

### State Management
- **Provider Pattern**: Centralized state management with `SettingsProvider` and `BudgetProvider`
- **Repository Pattern**: `ExpenseRepository` for data access abstraction
- **Reactive UI**: Automatic updates when data changes

### Code Organization
```
lib/
├── components/          # Reusable UI components
├── constants/           # App constants and enums
├── models/             # Data models
├── pages/              # Screen implementations
├── providers/          # State management
├── repositories/       # Data access layer
├── services/           # External services (Google Drive)
└── utils/              # Utility functions
```

### Key Components
- **DateRangePicker**: Reusable date selection widget
- **EntryTypeDropdown**: Expense/Income selection
- **CategoryDropdown**: Category selection with display names
- **SyncDialog**: Google Drive synchronization interface

## Installation

### Prerequisites
- Flutter SDK (>=3.1.5)
- Android Studio or VS Code
- Android device or emulator

### Setup
1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

### Building APK
```bash
flutter build apk --release
```

## Usage

### Adding Expenses
1. Tap the "+" button on the main screen
2. Fill in the expense details:
   - Type (Expense/Income)
   - Category
   - Label (description)
   - Amount
   - Date range (for multi-day expenses)
3. Tap "Insert expense"

### Viewing Data
- **Bar Chart**: Switch between daily/weekly/monthly/yearly views
- **Pie Chart**: See category breakdowns and remaining budget
- **Details**: Browse all entries with filtering options

### Budget Management
- Set initial budget in the Pie Chart page
- Budget automatically updates when adding/editing/deleting expenses
- Visual indicator when budget is not set

## CSV Export

### Exporting Data
1. Tap the settings menu (three dots)
2. Select "Export CSV"
3. Choose your date range
4. Select a destination folder
5. The file will be saved as "expenses.csv"

### Data Format
The exported CSV matches your Python processing script format:
- **Categories**: Translated to French (Alcool, Course, etc.)
- **Dates**: MM/DD/YYYY format
- **Types**: Expense = -1, Income = 1
- **Columns**: Date, Intitulé, Montant, Type, Revenu/Dépense

## Development

### Dependencies
- **Flutter**: UI framework
- **SQFlite**: Local database
- **Provider**: State management
- **FL Chart**: Data visualization
- **File Picker**: File selection for import/export
- **Velocity X**: UI utilities

### Code Quality
- Comprehensive documentation
- Consistent naming conventions
- Reusable component architecture
- Error handling and validation
- Linting and formatting

### Testing
```bash
flutter test
```

### Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.