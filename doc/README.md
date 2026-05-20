# LilyFit - Documentation

Welcome to the LilyFit documentation. This directory contains comprehensive documentation about the application's architecture, flows, and features.

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Application Flows](#application-flows)
- [Core Features](#core-features)
- [Technical Stack](#technical-stack)
- [Database Schema](#database-schema)

## Architecture Overview

LilyFit is a Flutter-based fitness and nutrition tracking application that follows a clean architecture pattern with:

- **Provider Pattern**: State management using the Provider package
- **Service Layer**: Separated business logic from UI
- **Model-View-ViewModel**: Clear separation of concerns
- **Supabase Backend**: Real-time database, authentication, and storage

### Architecture Diagram

![LilyFit Architecture](images/architecture.png)

For the interactive version, see [architecture.puml](diagrams/architecture.puml)

### Directory Structure

```
lib/
├── config/          # Configuration files (Supabase, etc.)
├── data/            # Local data sources and databases
├── l10n/            # Internationalization/Localization
├── models/          # Data models (UserProfile, MealLog, FoodItem, etc.)
├── providers/       # State management (AppProvider)
├── screens/         # UI screens
│   ├── auth/        # Authentication screens
│   ├── dashboard/   # Dashboard/Statistics
│   ├── food_search/ # Food search and logging
│   ├── home/        # Home screen with bottom navigation
│   ├── onboarding/  # User onboarding wizard
│   ├── profile/     # User profile and settings
│   └── progress/    # Progress tracking and charts
├── services/        # Business logic services
│   ├── supabase_service.dart    # Backend API integration
│   ├── notification_service.dart # Push notifications/reminders
│   ├── language_service.dart     # Language management
│   ├── location_service.dart     # Geolocation
│   └── food_cache_service.dart   # Local food database caching
├── theme/           # App theming and styling
├── utils/           # Utility functions and helpers
└── widgets/         # Reusable UI components
```

## Application Flows

All application flows are documented with PlantUML sequence diagrams in the `diagrams/` directory:

1. **[App Initialization Flow](diagrams/sequence_diagrams/01_app_initialization.puml)** - App startup, authentication check, and routing logic
2. **[Authentication Flow](diagrams/sequence_diagrams/02_authentication.puml)** - User signup, login, and password reset
3. **[Onboarding Flow](diagrams/sequence_diagrams/03_onboarding.puml)** - First-time user setup and profile creation
4. **[Food Logging Flow](diagrams/sequence_diagrams/04_food_logging.puml)** - Searching and logging meals
5. **[Water Tracking Flow](diagrams/sequence_diagrams/05_water_tracking.puml)** - Water intake tracking and reminders
6. **[Weight Tracking Flow](diagrams/sequence_diagrams/06_weight_tracking.puml)** - Weight entry and progress monitoring
7. **[Profile Management Flow](diagrams/sequence_diagrams/07_profile_management.puml)** - Editing user profile and goals
8. **[Settings Flow](diagrams/sequence_diagrams/08_settings.puml)** - App settings and preferences
9. **[Progress Viewing Flow](diagrams/sequence_diagrams/09_progress_viewing.puml)** - Statistics, charts, and progress tracking
10. **[Supabase Sync Flow](diagrams/sequence_diagrams/10_supabase_sync.puml)** - Cloud synchronization logic

### Viewing Diagrams

All diagrams are **automatically generated as PNG and SVG images** by GitHub Actions whenever PlantUML files are updated. The generated images are stored in the `doc/images/` directory.

**View options:**

1. **In this repository**: See the `doc/images/` folder for all rendered diagrams
2. **Online**: Use [PlantUML Web Server](http://www.plantuml.com/plantuml/uml/)
3. **VS Code**: Install the "PlantUML" extension by jebbs
4. **IntelliJ/Android Studio**: Built-in PlantUML support
5. **Command Line**: Install PlantUML locally with `brew install plantuml` (macOS)

For detailed instructions, see [VIEWING_DIAGRAMS.md](VIEWING_DIAGRAMS.md).

## Core Features

### 1. User Management
- Email/password authentication via Supabase
- User profile with personalized goals
- Multi-language support (EN, ES, FR, DE, PT)

### 2. Nutrition Tracking
- **Calorie Tracking**: Daily calorie intake monitoring
- **Macro Tracking**: Protein, carbs, and fats
- **Meal Logging**: Breakfast, lunch, dinner, and snacks
- **Food Database**: Comprehensive regional food database
- **Food Search**: Fast search and filtering

### 3. Hydration Tracking
- Water intake monitoring (glasses/mL)
- Customizable water goals
- Smart reminders with configurable schedules

### 4. Progress Monitoring
- Weight tracking over time
- Visual charts and graphs
- Streak tracking for consistency
- BMI calculation and categorization

### 5. Personalization
- **Goals**: Fat loss, muscle gain, or maintenance
- **Activity Levels**: Sedentary to very active
- **Units**: Metric (kg/cm) or Imperial (lbs/ft)
- **Themes**: Dark mode optimized UI

## ️ Technical Stack

### Frontend
- **Flutter**: Cross-platform mobile framework (3.41.9+)
- **Dart**: Programming language (3.11.5+)
- **Provider**: State management
- **FL Chart**: Data visualization
- **Google Fonts**: Typography
- **Shared Preferences**: Local storage

### Backend
- **Supabase**: Backend-as-a-Service
  - PostgreSQL database
  - Real-time subscriptions
  - Row Level Security (RLS)
  - Authentication & Authorization

### Services
- **Notifications**: Local push notifications
- **Geolocation**: Location-based features
- **Image Picker**: Profile photo selection

## ️ Database Schema

### Tables

#### user_profiles
Stores user profile information and goals.

```sql
- id (uuid, FK to auth.users)
- name (text)
- email (text, auto-synced)
- gender (text)
- age (integer)
- weight (numeric)
- height (numeric)
- activity_level (text)
- goal (text)
- target_calories (numeric)
- target_protein (numeric)
- target_carbs (numeric)
- target_fat (numeric)
- weight_unit (text)
- height_unit (text)
- created_at (timestamptz)
- updated_at (timestamptz)
```

#### meal_logs
Tracks user meals and food intake.

```sql
- id (uuid)
- user_id (uuid, FK to auth.users)
- meal_type (text: breakfast/lunch/dinner/snack)
- food_name (text)
- calories (numeric)
- protein (numeric)
- carbs (numeric)
- fat (numeric)
- servings (numeric)
- date (date)
- created_at (timestamptz)
```

#### weight_logs
Records weight entries over time.

```sql
- id (uuid)
- user_id (uuid, FK to auth.users)
- weight (numeric)
- date (date)
- created_at (timestamptz)
```

#### water_logs
Tracks daily water intake.

```sql
- id (uuid)
- user_id (uuid, FK to auth.users)
- amount (numeric, in mL)
- date (date)
- created_at (timestamptz)
```

#### foods
Central food database with nutritional information.

```sql
- id (uuid)
- name (text)
- calories (numeric)
- protein (numeric)
- carbs (numeric)
- fat (numeric)
- serving_size (text)
- region (text)
- emoji (text)
- is_active (boolean)
- created_at (timestamptz)
- updated_at (timestamptz)
```

#### workout_logs (Future feature)
```sql
- id (uuid)
- user_id (uuid)
- workout_name (text)
- duration (integer, minutes)
- calories_burned (numeric)
- notes (text)
- date (date)
- created_at (timestamptz)
```

#### payment_transactions (Future feature)
```sql
- id (uuid)
- user_id (uuid)
- amount (numeric)
- currency (text)
- status (text)
- payment_method (text)
- receipt_url (text)
- metadata (jsonb)
- created_at (timestamptz)
- updated_at (timestamptz)
```

## Security

### Row Level Security (RLS)

All tables implement Row Level Security policies to ensure users can only access their own data:

- Users can only read/write their own profile
- Users can only see their own meal logs, weight logs, and water logs
- Foods table is publicly readable
- Admin operations require elevated permissions

### Authentication

- Email/password authentication via Supabase Auth
- Secure password hashing and storage
- Email verification for new accounts
- Password reset via email

## Internationalization

LilyFit supports multiple languages:
- 🇺🇸 English (en)
- 🇪🇸 Spanish (es)
- 🇫🇷 French (fr)
- 🇩🇪 German (de)
- 🇧🇷 Portuguese (pt)

Language files are located in `lib/l10n/`.

## App Initialization Flow

The app follows a specific initialization sequence:

1. **Flutter Initialization**: `WidgetsFlutterBinding.ensureInitialized()`
2. **Supabase Initialization**: Connect to backend
3. **Notification Service**: Initialize local notifications
4. **AppProvider Initialization**: Load cached user data
5. **Route Determination**:
   - First launch → Language Selection
   - Not authenticated → Auth Screen
   - Authenticated without profile → Onboarding
   - Authenticated with profile → Home Screen

##  Testing

Refer to the test files for unit and integration tests:
- Unit tests: `test/`
- Integration tests: `integration_test/`
- Widget tests: `test/widgets/`

## Performance Optimizations

- **Food Database Caching**: Local caching of frequently accessed foods
- **Lazy Loading**: Load data only when needed
- **Image Optimization**: Compressed and cached profile images
- **State Management**: Efficient provider-based state updates
- **Database Indexing**: Optimized queries with proper indexes

## Future Enhancements

- [ ] Workout tracking and exercise library
- [ ] Social features (friends, challenges)
- [ ] Barcode scanning for food items
- [ ] Recipe builder and meal planning
- [ ] Integration with fitness wearables
- [ ] AI-powered meal recommendations
- [ ] Premium subscription features
- [ ] Offline mode improvements

## Contributing

For development guidelines and contribution instructions, see the main project README.

## License

See the LICENSE file in the project root.

---

**Last Updated**: May 20, 2026
**Version**: 1.0

