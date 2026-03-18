# 🚀 LilyFit Supabase Setup Guide

Complete guide to set up Supabase backend for your LilyFit app.

---

## 📋 Prerequisites

- A Supabase account (sign up at [supabase.com](https://supabase.com))
- Flutter SDK installed
- LilyFit project ready

---

## 🛠️ Setup Steps

### Step 1: Create Supabase Project

1. Go to [app.supabase.com](https://app.supabase.com)
2. Click **"New Project"**
3. Fill in:
   - **Project Name**: `lilyfit` (or your choice)
   - **Database Password**: Choose a strong password
   - **Region**: Select closest to your users
4. Click **"Create new project"**
5. Wait 1-2 minutes for setup to complete

---

### Step 2: Get Your API Credentials

1. In your Supabase project, go to **Settings** (gear icon in sidebar)
2. Click **API** in the left menu
3. You'll see two important values:
   - **Project URL** (looks like: `https://abcdefghijklmnop.supabase.co`)
   - **Project API keys** → **anon** **public** key (long string starting with `eyJ...`)

---

### Step 3: Configure Your Flutter App

1. Copy the template file:
   ```bash
   cp lib/config/supabase_config.dart.example lib/config/supabase_config.dart
   ```
   *(Or manually copy and rename the file)*

2. Open `lib/config/supabase_config.dart`
3. Replace the placeholder values:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGci...YOUR_ANON_KEY';
}
```

**🔒 SECURITY NOTICE**: 
- ✅ `supabase_config.dart` is in `.gitignore` - your credentials are protected
- ✅ Only the template file (`.example`) is committed to Git
- ❌ **NEVER** remove `supabase_config.dart` from `.gitignore`
- ❌ **NEVER** commit real credentials to GitHub/public repositories
- 💡 For production, consider using environment variables or `flutter_dotenv`

---

### Step 4: Create Database Tables

1. In Supabase Dashboard, click **SQL Editor** (in sidebar)
2. Click **"New query"**
3. Open the file `supabase_schema.sql` from your project root
4. Copy **ALL** the SQL code
5. Paste it into the Supabase SQL Editor
6. Click **"Run"** (or press Ctrl/Cmd + Enter)
7. Wait for success message: ✅ Done

**What this creates:**
- ✅ `user_profiles` - User data and health goals
- ✅ `weight_logs` - Weight tracking history
- ✅ `meal_logs` - Food and meal tracking
- ✅ `workout_logs` - Exercise sessions
- ✅ `water_logs` - Water intake tracking
- ✅ `payment_transactions` - Payment receipts
- ✅ Row Level Security (RLS) policies
- ✅ Indexes for performance
- ✅ Automatic timestamp triggers

---

### Step 5: Install Dependencies

Run in your terminal:

```bash
cd /Users/cypher/Desktop/Mobile\ App\ projects/lilyfit
flutter pub get
```

---

### Step 6: Test the Connection

1. Run your app:
   ```bash
   flutter run
   ```

2. The app should start without errors

3. Try creating a new account in the onboarding flow

4. Check Supabase Dashboard → **Authentication** → **Users**
   - Your new user should appear!

5. Check **Table Editor** → **user_profiles**
   - Your profile data should be there!

---

## 🔐 Security Features

Your database is secured with:

✅ **Row Level Security (RLS)** - Users can only access their own data
✅ **Authentication** - Email/password login built-in
✅ **Data validation** - CHECK constraints on all tables
✅ **Unique constraints** - Prevent duplicate entries

---

## 📊 Available Services

The `SupabaseService` class provides these methods:

### Authentication
- `signUp()` - Create new user account
- `signIn()` - Login existing user
- `signOut()` - Logout user
- `resetPassword()` - Send password reset email
- `getCurrentUserId()` - Get logged-in user ID
- `isLoggedIn()` - Check auth status

### User Profile
- `saveUserProfile()` - Save/update profile
- `getUserProfile()` - Get current profile
- `hasProfile()` - Check if profile exists

### Weight Tracking
- `logWeight()` - Add weight entry
- `getWeightHistory()` - Get weight history
- `deleteWeightEntry()` - Remove entry

### Meal Tracking
- `logMeal()` - Add meal entry
- `getMealLogs()` - Get meals for a date
- `getMealLogsInRange()` - Get meals in date range
- `deleteMealLog()` - Remove meal

### Workout Tracking
- `logWorkout()` - Add workout entry
- `getWorkoutLogs()` - Get workout history
- `deleteWorkoutLog()` - Remove workout

### Water Tracking
- `logWaterIntake()` - Add water intake
- `getWaterIntake()` - Get water for a date

### Payments
- `createPaymentTransaction()` - Record payment
- `updatePaymentStatus()` - Update payment status
- `getPaymentTransactions()` - Get payment history

---

## 🧪 Testing Your Setup

Test with this code snippet:

```dart
import 'package:lilyfit/services/supabase_service.dart';

Future<void> testSupabase() async {
  final service = SupabaseService();
  
  // Test 1: Check if Supabase is initialized
  print('Is logged in: ${service.isLoggedIn()}');
  
  // Test 2: Try to get profile (will be null if not logged in)
  final profile = await service.getUserProfile();
  print('Profile: $profile');
  
  print('✅ Supabase is working!');
}
```

---

## 🔧 Troubleshooting

### Error: "Invalid API key"
- Double-check your `supabaseAnonKey` in `supabase_config.dart`
- Make sure you copied the **anon** **public** key, not the service_role key

### Error: "Failed to create user"
- Check that SQL schema was run successfully
- Verify email confirmation is disabled (Settings → Authentication → Email Auth → Confirm email = OFF for development)

### Error: "Permission denied"
- RLS policies may not be set up correctly
- Re-run the `supabase_schema.sql` file

### Can't see data in Supabase Dashboard
- Make sure you're looking at the correct table
- Check that user is authenticated (`service.isLoggedIn()`)
- Verify RLS policies are active

---

## 📱 Next Steps

Now that Supabase is configured:

1. ✅ Update onboarding screen to use authentication
2. ✅ Migrate existing SharedPreferences data to Supabase
3. ✅ Add email verification
4. ✅ Implement password reset flow
5. ✅ Add payment integration
6. ✅ Set up email notifications for receipts

---

## 🆘 Need Help?

- 📚 [Supabase Documentation](https://supabase.com/docs)
- 💬 [Supabase Discord Community](https://discord.supabase.com)
- 📧 Email support: support@supabase.io

---

**🎉 Congratulations! Your LilyFit app is now connected to Supabase!**
