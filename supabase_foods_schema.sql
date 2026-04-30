-- ============================================================
-- LILYFIT FOODS DATABASE SCHEMA
-- ============================================================
-- 
-- INSTRUCTIONS:
-- 1. Go to your Supabase Dashboard
-- 2. Navigate to SQL Editor
-- 3. Create a new query
-- 4. Copy and paste this entire file
-- 5. Click "Run" to execute
-- 
-- This creates the foods table and seeds it with initial data
-- ============================================================

-- ============ FOODS TABLE ============
-- Centralized food database for nutrition tracking
CREATE TABLE IF NOT EXISTS public.foods (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  calories DECIMAL NOT NULL CHECK (calories >= 0),
  protein DECIMAL NOT NULL CHECK (protein >= 0),
  carbs DECIMAL NOT NULL CHECK (carbs >= 0),
  fat DECIMAL NOT NULL CHECK (fat >= 0),
  serving_size TEXT NOT NULL,
  region TEXT NOT NULL CHECK (region IN ('african', 'western', 'asian', 'european', 'other')),
  emoji TEXT NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for faster searches
CREATE INDEX IF NOT EXISTS idx_foods_name ON public.foods(name);
CREATE INDEX IF NOT EXISTS idx_foods_region ON public.foods(region);
CREATE INDEX IF NOT EXISTS idx_foods_active ON public.foods(is_active);

-- ============ ROW LEVEL SECURITY ============
-- Foods are publicly readable, only admins can modify
ALTER TABLE public.foods ENABLE ROW LEVEL SECURITY;

-- Allow everyone (including anonymous users) to read foods
CREATE POLICY "Foods are publicly readable"
ON public.foods FOR SELECT
TO public
USING (is_active = true);

-- ============ TRIGGERS ============
-- Auto-update updated_at timestamp
CREATE TRIGGER update_foods_updated_at
BEFORE UPDATE ON public.foods
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- SEED DATA: Initial Food Database
-- ============================================================

-- Clear existing data (if any)
DELETE FROM public.foods;

-- ─── African Foods ───────────────────────────────────────────────
INSERT INTO public.foods (id, name, calories, protein, carbs, fat, serving_size, region, emoji) VALUES
('af01', 'Jollof Rice', 450, 12, 65, 14, '1 plate', 'african', '🍚'),
('af02', 'Egusi Soup', 320, 18, 12, 22, '1 bowl', 'african', '🥣'),
('af03', 'Ndole', 280, 20, 10, 18, '1 bowl', 'african', '🥬'),
('af04', 'Eru', 250, 22, 8, 15, '1 bowl', 'african', '🥗'),
('af05', 'Fufu (Cassava)', 180, 3, 40, 1, '1 ball', 'african', '🫓'),
('af06', 'Fried Plantain (Dodo)', 220, 2, 36, 9, '1 serving', 'african', '🍌'),
('af07', 'Suya', 300, 28, 6, 18, '100g', 'african', '🥩'),
('af08', 'Pounded Yam', 200, 4, 47, 0.5, '1 ball', 'african', '🫓'),
('af09', 'Akara (Bean Cake)', 170, 9, 14, 9, '3 pieces', 'african', '🧆'),
('af10', 'Moi Moi', 190, 12, 18, 8, '1 wrap', 'african', '🫔'),
('af11', 'Chin Chin', 450, 6, 55, 22, '100g', 'african', '🍪'),
('af12', 'Puff Puff', 280, 4, 38, 12, '5 pieces', 'african', '🍩'),
('af13', 'Ogbono Soup', 300, 15, 10, 23, '1 bowl', 'african', '🥣'),
('af14', 'Pepper Soup', 220, 25, 5, 12, '1 bowl', 'african', '🍲'),
('af15', 'Waakye', 380, 14, 60, 10, '1 plate', 'african', '🍛'),
('af16', 'Banku', 210, 3, 48, 1, '1 ball', 'african', '🫓'),
('af17', 'Kenkey', 200, 4, 44, 1.5, '1 piece', 'african', '🫔'),
('af18', 'Injera', 130, 5, 26, 1, '1 piece', 'african', '🫓'),
('af19', 'Ugali', 195, 4, 42, 1, '1 serving', 'african', '🫓'),
('af20', 'Nyama Choma', 350, 32, 2, 24, '150g', 'african', '🥩'),
('af21', 'Bobotie', 380, 22, 18, 24, '1 serving', 'african', '🥘'),
('af22', 'Thieboudienne', 420, 25, 50, 14, '1 plate', 'african', '🐟'),
('af23', 'Garri (Eba)', 160, 2, 38, 0.5, '1 serving', 'african', '🫓'),
('af24', 'Palm Nut Soup', 340, 12, 8, 30, '1 bowl', 'african', '🥣'),

-- ─── Western Foods ───────────────────────────────────────────────
('we01', 'Grilled Chicken Breast', 165, 31, 0, 3.6, '100g', 'western', '🍗'),
('we02', 'Scrambled Eggs', 210, 14, 2, 16, '2 eggs', 'western', '🥚'),
('we03', 'Oatmeal', 150, 5, 27, 3, '1 bowl', 'western', '🥣'),
('we04', 'Caesar Salad', 220, 8, 12, 16, '1 bowl', 'western', '🥗'),
('we05', 'Cheeseburger', 550, 28, 40, 32, '1 burger', 'western', '🍔'),
('we06', 'Pepperoni Pizza', 300, 13, 33, 14, '1 slice', 'western', '🍕'),
('we07', 'Pasta Carbonara', 480, 18, 55, 20, '1 plate', 'western', '🍝'),
('we08', 'Ribeye Steak', 450, 38, 0, 33, '200g', 'western', '🥩'),
('we09', 'Salmon Fillet', 280, 34, 0, 16, '150g', 'western', '🐟'),
('we10', 'Avocado Toast', 250, 6, 24, 15, '1 slice', 'western', '🥑'),
('we11', 'Greek Yogurt', 130, 15, 8, 4, '1 cup', 'western', '🫙'),
('we12', 'Protein Shake', 200, 30, 10, 4, '1 scoop', 'western', '🥤'),
('we13', 'Turkey Sandwich', 350, 24, 32, 14, '1 sandwich', 'western', '🥪'),
('we14', 'French Fries', 365, 4, 48, 17, '1 serving', 'western', '🍟'),
('we15', 'Pancakes', 350, 8, 45, 15, '3 pancakes', 'western', '🥞'),
('we16', 'Grilled Salmon Bowl', 420, 36, 35, 16, '1 bowl', 'western', '🍱'),
('we17', 'Banana', 105, 1.3, 27, 0.4, '1 medium', 'western', '🍌'),
('we18', 'Apple', 95, 0.5, 25, 0.3, '1 medium', 'western', '🍎'),
('we19', 'Almonds', 160, 6, 6, 14, '28g', 'western', '🥜'),
('we20', 'Brown Rice', 215, 5, 45, 1.8, '1 cup', 'western', '🍚'),

-- ─── Asian Foods ─────────────────────────────────────────────────
('as01', 'Salmon Sushi Roll', 250, 12, 35, 6, '6 pieces', 'asian', '🍣'),
('as02', 'Ramen', 450, 18, 55, 18, '1 bowl', 'asian', '🍜'),
('as03', 'Fried Rice', 380, 10, 52, 14, '1 plate', 'asian', '🍚'),
('as04', 'Pad Thai', 400, 16, 48, 16, '1 plate', 'asian', '🍜'),
('as05', 'Chicken Tikka Masala', 350, 24, 15, 22, '1 serving', 'asian', '🍛'),
('as06', 'Naan Bread', 260, 8, 45, 5, '1 piece', 'asian', '🫓'),
('as07', 'Dim Sum (Har Gow)', 180, 10, 20, 6, '4 pieces', 'asian', '🥟'),
('as08', 'Pho', 380, 22, 42, 12, '1 bowl', 'asian', '🍲'),
('as09', 'Bibimbap', 490, 22, 60, 18, '1 bowl', 'asian', '🍛'),
('as10', 'Kung Pao Chicken', 320, 20, 18, 20, '1 serving', 'asian', '🐔'),
('as11', 'Miso Soup', 60, 4, 5, 2, '1 bowl', 'asian', '🥣'),
('as12', 'Spring Rolls', 200, 6, 28, 7, '3 pieces', 'asian', '🌯'),
('as13', 'Tandoori Chicken', 260, 30, 4, 14, '1 serving', 'asian', '🍗'),

-- ─── European Foods ──────────────────────────────────────────────
('eu01', 'Croissant', 230, 5, 26, 12, '1 piece', 'european', '🥐'),
('eu02', 'Paella', 400, 20, 50, 14, '1 plate', 'european', '🥘'),
('eu03', 'Greek Salad', 180, 6, 10, 14, '1 bowl', 'european', '🥗'),
('eu04', 'Fish and Chips', 600, 24, 55, 32, '1 serving', 'european', '🐟'),
('eu05', 'Moussaka', 350, 18, 22, 22, '1 serving', 'european', '🍆'),
('eu06', 'Schnitzel', 380, 26, 20, 22, '1 piece', 'european', '🥩'),
('eu07', 'Borscht', 140, 5, 18, 5, '1 bowl', 'european', '🍲'),
('eu08', 'Risotto', 350, 10, 45, 14, '1 plate', 'european', '🍚'),
('eu09', 'Bruschetta', 170, 4, 22, 7, '2 pieces', 'european', '🥖'),
('eu10', 'Crepe', 200, 6, 28, 7, '1 piece', 'european', '🫓'),
('eu11', 'Gazpacho', 90, 2, 10, 4, '1 bowl', 'european', '🍅'),
('eu12', 'Pretzels', 380, 10, 72, 4, '100g', 'european', '🥨');

-- ============================================================
-- VERIFICATION
-- ============================================================
-- Query to verify food counts by region
SELECT 
  region, 
  COUNT(*) as food_count 
FROM public.foods 
GROUP BY region 
ORDER BY region;

-- Total food count
SELECT COUNT(*) as total_foods FROM public.foods;
