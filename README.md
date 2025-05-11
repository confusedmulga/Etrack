# Etrack

**Etrack** is a minimalist and intuitive expense tracking app designed to help you manage your finances on the go. The app is built with Flutter and follows iOS-style animations, smooth navigation, and modern UI principles.

---

## ✨ Features

### 🏠 Home - Add Expense
- **Quick Entry**: Add daily expenses or income with a single tap.
- **Defaults to Today’s Date**: No need to select the date every time.
- **Flexible Input**: Enter a note, amount, and select whether it’s a credit or debit.
- **One-Click Add**: Add transactions using a minimal floating “+” button.

### 🕓 History View
- **Monthly Grouped History**: Transactions are automatically grouped under each month.
- **Expandable List**: Easy to browse past expenses and credits.
- **Export to PDF**: Export any month's data in a cleanly formatted PDF file, perfect for sharing or record-keeping.

### 📊 Monthly Insights
- **Pie Chart Breakdown**: Visual comparison of expenses and credits.
- **Summary View**: Get a quick glance at your monthly financial habits.

---

## 🎨 UI/UX
- Inspired by iOS navigation and animation styles.
- Smooth transitions and modern design language.
- Clean layout using rounded cards and soft shadows.

---

## 🔧 Tech Stack
- **Flutter** with Dart
- **Provider** for state management
- **Syncfusion Flutter Charts** for visualization
- **PDF** generation using the `syncfusion_flutter_pdf` package

---

## 🚀 Getting Started

### Requirements
- Flutter SDK
- Android SDK
- Physical Android device or emulator

### Setup
```bash
git clone https://github.com/your-username/Etrack.git
cd Etrack
flutter pub get
flutter run
```

## Build APK
```bash
flutter build apk --release
```

## 📱 Demo
Coming soon...

## 📂 Folder Structure

```bash
lib/
│
├── main.dart
├── models/
│   └── expense.dart
├── providers/
│   └── expense_provider.dart
├── screens/
│   ├── home_screen.dart
│   ├── history_screen.dart
│   └── monthly_view_screen.dart
└── widgets/
    ├── expense_input.dart
    └── expense_list_item.dart
```
