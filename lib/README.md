# Project Structure

## Folder Organization

```
lib/
├── main.dart                 # App entry point
├── screens/                  # Full-page screens
│   └── sign_in_page.dart
├── widgets/                  # Reusable custom widgets
├── models/                   # Data models & classes
├── services/                 # API calls, database, external services
├── controllers/              # State management (GetX, Provider, Bloc)
└── utils/                    # Helper functions, constants, validators
```

## Guidelines

### 📱 screens/
- Place all full-page screens here
- Name: `*_page.dart` or `*_screen.dart`
- Examples: `home_page.dart`, `profile_page.dart`

### 🧩 widgets/
- Reusable UI components used across multiple screens
- Name: `custom_*.dart` or descriptive names
- Examples: `custom_button.dart`, `product_card.dart`

### 📦 models/
- Data classes/models
- Name: `*_model.dart`
- Examples: `user_model.dart`, `product_model.dart`

### 🔌 services/
- API integrations, database services
- Name: `*_service.dart`
- Examples: `api_service.dart`, `auth_service.dart`

### 🎮 controllers/
- State management logic
- Name: `*_controller.dart` or `*_provider.dart`
- Examples: `auth_controller.dart`

### 🛠️ utils/
- Helper functions, constants, validators
- Name: descriptive like `constants.dart`, `validators.dart`
- Examples: `colors.dart`, `strings.dart`, `formatters.dart`

## Import Examples

```dart
// Importing a screen
import 'screens/sign_in_page.dart';

// Importing a widget
import 'widgets/custom_button.dart';

// Importing a model
import 'models/user_model.dart';

// Importing a service
import 'services/api_service.dart';

// Importing utilities
import 'utils/constants.dart';
```
