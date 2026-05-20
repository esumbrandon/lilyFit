# LilyFit Technical Documentation

## Quick Reference

### Directory Structure
```
doc/
├── README.md                    # Main documentation index
├── VIEWING_DIAGRAMS.md         # How to view PlantUML diagrams
├── TECHNICAL_GUIDE.md          # This file
└── diagrams/                   # PlantUML sequence diagrams
    ├── 01_app_initialization.puml
    ├── 02_authentication.puml
    ├── 03_onboarding.puml
    ├── 04_food_logging.puml
    ├── 05_water_tracking.puml
    ├── 06_weight_tracking.puml
    ├── 07_profile_management.puml
    ├── 08_settings.puml
    ├── 09_progress_viewing.puml
    ├── 10_supabase_sync.puml
    └── architecture.puml
```

## Application Flows Summary

### 1. App Initialization Flow
**Purpose**: Determine initial screen based on user state  
**Key Decision Points**:
- First launch? → Language Selection
- Authenticated? → Check profile
- Has profile? → Home Screen
- No profile? → Onboarding

**Files Involved**:
- `lib/main.dart` - AppInitializer
- `lib/services/language_service.dart`
- `lib/providers/app_provider.dart`

---

### 2. Authentication Flow
**Purpose**: User login, signup, and password recovery  
**Supported Methods**:
- Email/Password (Supabase Auth)
- Password reset via email

**Security Features**:
- JWT tokens
- Secure password hashing (bcrypt)
- Email verification
- Session management

**Files Involved**:
- `lib/screens/auth/auth_screen.dart`
- `lib/services/supabase_service.dart`
- `lib/utils/validators.dart`

---

### 3. Onboarding Flow
**Purpose**: Collect user information and calculate goals  
**Steps**: (6 pages)
1. Name
2. Gender (Male/Female/Other)
3. Age (10-100)
4. Physical Stats (Weight, Height, Units)
5. Activity Level (Sedentary → Very Active)
6. Goal (Fat Loss/Maintenance/Muscle Gain)

**Calculations**:
- BMR: Mifflin-St Jeor Equation
- TDEE: BMR × Activity Multiplier
- Target Calories: TDEE ± Goal Adjustment
- Macros: Protein (4 cal/g), Carbs (4 cal/g), Fat (9 cal/g)

**Files Involved**:
- `lib/screens/onboarding/onboarding_screen.dart`
- `lib/models/user_profile.dart`

---

### 4. Food Logging Flow
**Purpose**: Log meals and track nutrition  
**Features**:
- Search from 1000+ foods
- Regional food database
- Custom servings (0.5x - 10x)
- Meal types (Breakfast, Lunch, Dinner, Snack)
- Real-time macro updates

**Data Flow**:
1. User searches food
2. Select from results
3. Adjust servings
4. Choose meal type
5. Save locally (instant)
6. Sync to cloud (background)

**Files Involved**:
- `lib/screens/food_search/food_search_screen.dart`
- `lib/services/food_cache_service.dart`
- `lib/data/food_database.dart`

---

### 5. Water Tracking Flow
**Purpose**: Monitor daily hydration  
**Features**:
- Track in glasses or mL
- Customizable daily goal
- Smart reminders with schedule
- Visual progress indicator

**Reminder System**:
- Configurable interval (15-240 min)
- Start/end time (e.g., 7 AM - 10 PM)
- Localized notifications
- Respects Do Not Disturb

**Files Involved**:
- `lib/widgets/water_tracker_card.dart`
- `lib/services/notification_service.dart`
- `lib/screens/profile/water_reminder_screen.dart`

---

### 6. Weight Tracking Flow
**Purpose**: Monitor weight changes over time  
**Features**:
- Weight entry (one per day)
- Historical chart with trend line
- BMI calculation
- Progress towards goal
- Weight change statistics

**Insights Provided**:
- Current vs starting weight
- Weekly rate of change
- Time to goal (ETA)
- Healthy range indicators

**Files Involved**:
- `lib/screens/progress/progress_screen.dart`
- `lib/models/meal_log.dart` (WeightEntry)

---

### 7. Profile Management Flow
**Purpose**: Update user information and goals  
**Editable Fields**:
- Personal info (name, age, gender)
- Physical stats (weight, height)
- Activity level
- Goal selection
- Unit preferences

**Auto-Recalculation**:
When profile changes, targets automatically update:
- New TDEE calculated
- Calorie target adjusted
- Macro ratios recalculated

**Files Involved**:
- `lib/screens/profile/profile_screen.dart`
- `lib/models/user_profile.dart`

---

### 8. Settings Flow
**Purpose**: Configure app behavior  
**Settings Categories**:
- **Language**: 5 supported languages
- **Notifications**: Water reminders, daily summaries
- **Units**: Metric vs Imperial
- **Account**: Password reset, logout
- **Data**: Export, clear cache, reset

**Localization**:
- Language changes apply instantly
- All text updated including notifications
- Formats (dates, numbers) adjusted

**Files Involved**:
- `lib/screens/profile/settings_screen.dart`
- `lib/l10n/` - Translation files

---

### 9. Progress Viewing Flow
**Purpose**: Visualize trends and analytics  
**Visualizations**:
- Weight line chart with trend
- Weekly calorie bar chart
- Macro distribution pie chart
- Day-of-week patterns
- Goal progress tracker

**Statistics Calculated**:
- Daily/weekly/monthly averages
- Consistency percentage
- Streak tracking (current & longest)
- Pattern detection

**Files Involved**:
- `lib/screens/dashboard/dashboard_screen.dart`
- `lib/screens/progress/progress_screen.dart`

---

### 10. Supabase Sync Flow
**Purpose**: Cloud data synchronization  
**Strategy**: Local-First
1. Write to local storage (instant)
2. Update UI immediately
3. Sync to cloud (background)
4. Handle conflicts gracefully

**Security**:
- Row Level Security (RLS)
- Users only see their own data
- JWT authentication
- Encrypted connections

**Offline Support**:
- App fully functional offline
- Changes queued for sync
- Automatic sync when online
- Conflict resolution

**Files Involved**:
- `lib/services/supabase_service.dart`
- `lib/providers/app_provider.dart`

---

## Key Technologies

### Flutter & Dart
- **Flutter**: 3.41.9+ (3.11.9+ minimum)
- **Dart**: 3.11.5+ (3.11.0+ required)
- **Provider**: State management
- **Shared Preferences**: Local storage

### Backend (Supabase)
- **Database**: PostgreSQL with RLS
- **Authentication**: JWT-based
- **Real-time**: WebSocket subscriptions
- **Storage**: File uploads (future)

### Third-Party Packages
```yaml
dependencies:
  provider: ^6.0.0               # State management
  supabase_flutter: ^2.5.6       # Backend client
  fl_chart: ^0.68.0              # Charts & graphs
  google_fonts: ^6.0.0           # Typography
  image_picker: ^1.0.0           # Profile photos
  geolocator: ^13.0.2            # Location services
  geocoding: ^3.0.0              # Address lookup
  flutter_local_notifications: ^18.0.0  # Push notifications
  timezone: ^0.9.4               # Time zone support
  intl: ^0.20.2                  # Internationalization
```

## Development Guidelines

### State Management Pattern
```dart
// Listen to changes
Consumer<AppProvider>(
  builder: (context, provider, child) {
    return Text('Calories: ${provider.consumedCalories}');
  },
)

// One-time read
final provider = context.read<AppProvider>();
provider.addMeal(food, MealType.breakfast);

// Watch for reactive updates
final calories = context.watch<AppProvider>().consumedCalories;
```

### Adding a New Feature

1. **Create Model** (if needed)
   ```dart
   // lib/models/new_feature.dart
   class NewFeature {
     final String id;
     final DateTime date;
     // ... fields
   }
   ```

2. **Update AppProvider**
   ```dart
   // lib/providers/app_provider.dart
   List<NewFeature> _features = [];
   
   Future<void> addFeature(NewFeature feature) async {
     _features.add(feature);
     await _saveFeatures();
     notifyListeners();
   }
   ```

3. **Add Service Method**
   ```dart
   // lib/services/supabase_service.dart
   Future<void> saveFeature(NewFeature feature) async {
     await _supabase.from('features').insert(feature.toJson());
   }
   ```

4. **Create UI Screen**
   ```dart
   // lib/screens/new_feature/feature_screen.dart
   class FeatureScreen extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return Consumer<AppProvider>(...);
     }
   }
   ```

5. **Update Navigation**
   ```dart
   // Add route in main.dart or navigation handler
   ```

### Database Migration

When adding new Supabase tables:

```sql
-- Create table
CREATE TABLE new_table (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  data TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE new_table ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own data"
  ON new_table FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own data"
  ON new_table FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own data"
  ON new_table FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own data"
  ON new_table FOR DELETE
  USING (auth.uid() = user_id);

-- Create indexes
CREATE INDEX idx_new_table_user_id ON new_table(user_id);
CREATE INDEX idx_new_table_created_at ON new_table(created_at);
```

## Testing

### Unit Tests
```bash
flutter test test/unit/
```

### Widget Tests
```bash
flutter test test/widgets/
```

### Integration Tests
```bash
flutter test integration_test/
```

## Building

### Development Build
```bash
flutter run
```

### Release Build

**Android:**
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

## Debugging Tips

### Enable Debug Logging
```dart
// In lib/config/supabase_config.dart
static const bool enableLogging = true;
```

### Check Supabase Connection
```dart
final user = Supabase.instance.client.auth.currentUser;
print('User: ${user?.id}');
```

### Inspect Local Storage
```dart
final prefs = await SharedPreferences.getInstance();
print(prefs.getKeys());
```

### Monitor State Changes
```dart
provider.addListener(() {
  print('State updated: ${provider.consumedCalories}');
});
```

## Performance Optimization

### Image Optimization
- Compress profile photos before upload
- Use cached network images
- Lazy load images in lists

### Database Queries
- Use indexes on frequently queried columns
- Limit results with pagination
- Cache frequently accessed data

### UI Performance
- Use `const` constructors where possible
- Avoid rebuilding entire widget tree
- Use `ListView.builder` for long lists
- Implement pagination for large datasets

## Common Issues & Solutions

### "No user logged in"
**Cause**: Session expired or user logged out  
**Solution**: Check auth state, redirect to login

### "Failed to save profile"
**Cause**: Network error or invalid data  
**Solution**: Validate data, check network, retry

### "Meals not syncing"
**Cause**: Offline or sync queue full  
**Solution**: Check connectivity, manually trigger sync

### Charts not rendering
**Cause**: Missing data or invalid date range  
**Solution**: Validate data exists, check date calculations

---

## Additional Resources

- See [README.md](README.md) for architecture overview
- See [VIEWING_DIAGRAMS.md](VIEWING_DIAGRAMS.md) for diagram rendering
- See sequence diagrams in `diagrams/` for detailed flows
- Consult Flutter docs: https://flutter.dev
- Consult Supabase docs: https://supabase.com/docs

---

**Last Updated**: May 20, 2026  
**Version**: 1.0.0

