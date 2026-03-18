-- ============================================================
-- LILYFIT DATABASE SCHEMA FOR SUPABASE
-- ============================================================
-- 
-- INSTRUCTIONS:
-- 1. Go to your Supabase Dashboard
-- 2. Navigate to SQL Editor
-- 3. Create a new query
-- 4. Copy and paste this entire file
-- 5. Click "Run" to execute
-- 
-- This will create all necessary tables, indexes, and security policies
-- 
-- IMPORTANT NOTES:
-- • Email addresses are automatically synced from auth.users to user_profiles
-- • Never manually set the email field - it updates automatically via trigger
-- • This ensures email consistency for payment receipts and notifications
-- ============================================================

-- ============ USER PROFILES TABLE ============
-- Extends Supabase auth.users with fitness-specific data
-- NOTE: email is auto-synced from auth.users - do not manually set it
CREATE TABLE IF NOT EXISTS public.user_profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  gender TEXT NOT NULL CHECK (gender IN ('male', 'female', 'other')),
  age INTEGER NOT NULL CHECK (age >= 13 AND age <= 120),
  weight DECIMAL NOT NULL CHECK (weight > 0), -- Always stored in kg
  height DECIMAL NOT NULL CHECK (height > 0), -- Always stored in cm
  activity_level TEXT NOT NULL CHECK (activity_level IN ('sedentary', 'light', 'moderate', 'active', 'veryActive')),
  goal TEXT NOT NULL CHECK (goal IN ('fatLoss', 'maintenance', 'muscleGain')),
  target_calories DECIMAL NOT NULL,
  target_protein DECIMAL NOT NULL,
  target_carbs DECIMAL NOT NULL,
  target_fat DECIMAL NOT NULL,
  weight_unit TEXT DEFAULT 'kg' CHECK (weight_unit IN ('kg', 'lbs')),
  height_unit TEXT DEFAULT 'cm' CHECK (height_unit IN ('cm', 'ft')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============ WEIGHT LOGS TABLE ============
-- Track user's weight over time
CREATE TABLE IF NOT EXISTS public.weight_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  weight DECIMAL NOT NULL CHECK (weight > 0), -- Always stored in kg
  date DATE NOT NULL,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, date) -- One weight entry per day per user
);

-- ============ MEAL LOGS TABLE ============
-- Track meals and food intake
CREATE TABLE IF NOT EXISTS public.meal_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  meal_type TEXT NOT NULL CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
  food_name TEXT NOT NULL,
  calories DECIMAL NOT NULL CHECK (calories >= 0),
  protein DECIMAL NOT NULL CHECK (protein >= 0),
  carbs DECIMAL NOT NULL CHECK (carbs >= 0),
  fat DECIMAL NOT NULL CHECK (fat >= 0),
  servings DECIMAL DEFAULT 1.0 CHECK (servings > 0),
  date DATE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============ WORKOUT LOGS TABLE ============
-- Track workouts and exercise sessions
CREATE TABLE IF NOT EXISTS public.workout_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  workout_name TEXT NOT NULL,
  duration INTEGER NOT NULL CHECK (duration > 0), -- in minutes
  calories_burned DECIMAL NOT NULL CHECK (calories_burned >= 0),
  notes TEXT,
  date DATE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============ WATER LOGS TABLE ============
-- Track daily water intake
CREATE TABLE IF NOT EXISTS public.water_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  amount DECIMAL NOT NULL CHECK (amount > 0), -- in ml
  date DATE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============ PAYMENT TRANSACTIONS TABLE ============
-- Track payment history and receipts
CREATE TABLE IF NOT EXISTS public.payment_transactions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  amount DECIMAL NOT NULL CHECK (amount > 0),
  currency TEXT DEFAULT 'USD' NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
  payment_method TEXT,
  receipt_url TEXT,
  metadata JSONB, -- Store additional payment details
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============ INDEXES FOR BETTER PERFORMANCE ============
CREATE INDEX IF NOT EXISTS idx_weight_logs_user_date ON public.weight_logs(user_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_meal_logs_user_date ON public.meal_logs(user_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_workout_logs_user_date ON public.workout_logs(user_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_water_logs_user_date ON public.water_logs(user_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_payment_transactions_user ON public.payment_transactions(user_id, created_at DESC);

-- ============ ROW LEVEL SECURITY (RLS) ============
-- Enable RLS on all tables
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weight_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meal_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.water_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_transactions ENABLE ROW LEVEL SECURITY;

-- ============ RLS POLICIES FOR USER_PROFILES ============
-- Users can view their own profile
CREATE POLICY "Users can view own profile" 
ON public.user_profiles FOR SELECT 
USING (auth.uid() = id);

-- Users can insert their own profile
CREATE POLICY "Users can insert own profile" 
ON public.user_profiles FOR INSERT 
WITH CHECK (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" 
ON public.user_profiles FOR UPDATE 
USING (auth.uid() = id);

-- ============ RLS POLICIES FOR WEIGHT_LOGS ============
CREATE POLICY "Users can view own weight logs" 
ON public.weight_logs FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own weight logs" 
ON public.weight_logs FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own weight logs" 
ON public.weight_logs FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own weight logs" 
ON public.weight_logs FOR DELETE 
USING (auth.uid() = user_id);

-- ============ RLS POLICIES FOR MEAL_LOGS ============
CREATE POLICY "Users can view own meal logs" 
ON public.meal_logs FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own meal logs" 
ON public.meal_logs FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own meal logs" 
ON public.meal_logs FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own meal logs" 
ON public.meal_logs FOR DELETE 
USING (auth.uid() = user_id);

-- ============ RLS POLICIES FOR WORKOUT_LOGS ============
CREATE POLICY "Users can view own workout logs" 
ON public.workout_logs FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own workout logs" 
ON public.workout_logs FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own workout logs" 
ON public.workout_logs FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own workout logs" 
ON public.workout_logs FOR DELETE 
USING (auth.uid() = user_id);

-- ============ RLS POLICIES FOR WATER_LOGS ============
CREATE POLICY "Users can view own water logs" 
ON public.water_logs FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own water logs" 
ON public.water_logs FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own water logs" 
ON public.water_logs FOR DELETE 
USING (auth.uid() = user_id);

-- ============ RLS POLICIES FOR PAYMENT_TRANSACTIONS ============
CREATE POLICY "Users can view own transactions" 
ON public.payment_transactions FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own transactions" 
ON public.payment_transactions FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own transactions" 
ON public.payment_transactions FOR UPDATE 
USING (auth.uid() = user_id);

-- ============ FUNCTIONS & TRIGGERS ============

-- Function to automatically sync email from auth.users
-- Ensures email in user_profiles always matches auth.users
CREATE OR REPLACE FUNCTION sync_user_email()
RETURNS TRIGGER AS $$
BEGIN
  NEW.email = (SELECT email FROM auth.users WHERE id = NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to sync email from auth.users on insert/update
CREATE TRIGGER sync_email_on_profile_change
BEFORE INSERT OR UPDATE ON public.user_profiles
FOR EACH ROW
EXECUTE FUNCTION sync_user_email();

-- Trigger for user_profiles table
CREATE TRIGGER update_user_profiles_updated_at 
BEFORE UPDATE ON public.user_profiles
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Trigger for payment_transactions table
CREATE TRIGGER update_payment_transactions_updated_at 
BEFORE UPDATE ON public.payment_transactions
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- ============ COMPLETION MESSAGE ============
DO $$
BEGIN
  RAISE NOTICE '✅ LilyFit database schema created successfully!';
  RAISE NOTICE '📊 Tables created: user_profiles, weight_logs, meal_logs, workout_logs, water_logs, payment_transactions';
  RAISE NOTICE '🔒 Row Level Security (RLS) enabled on all tables';
  RAISE NOTICE '🚀 Your database is ready to use!';
END $$;
