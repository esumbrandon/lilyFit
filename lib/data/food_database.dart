import '../models/food_item.dart';

class FoodDatabase {
  static const List<FoodItem> foods = [
    // ─── African Foods ───────────────────────────────────────────────
    FoodItem(id: 'af01', name: 'Jollof Rice', calories: 450, protein: 12, carbs: 65, fat: 14, servingSize: '1 plate', region: 'african', emoji: '🍚'),
    FoodItem(id: 'af02', name: 'Egusi Soup', calories: 320, protein: 18, carbs: 12, fat: 22, servingSize: '1 bowl', region: 'african', emoji: '🥣'),
    FoodItem(id: 'af03', name: 'Ndole', calories: 280, protein: 20, carbs: 10, fat: 18, servingSize: '1 bowl', region: 'african', emoji: '🥬'),
    FoodItem(id: 'af04', name: 'Eru', calories: 250, protein: 22, carbs: 8, fat: 15, servingSize: '1 bowl', region: 'african', emoji: '🥗'),
    FoodItem(id: 'af05', name: 'Fufu (Cassava)', calories: 180, protein: 3, carbs: 40, fat: 1, servingSize: '1 ball', region: 'african', emoji: '🫓'),
    FoodItem(id: 'af06', name: 'Fried Plantain (Dodo)', calories: 220, protein: 2, carbs: 36, fat: 9, servingSize: '1 serving', region: 'african', emoji: '🍌'),
    FoodItem(id: 'af07', name: 'Suya', calories: 300, protein: 28, carbs: 6, fat: 18, servingSize: '100g', region: 'african', emoji: '🥩'),
    FoodItem(id: 'af08', name: 'Pounded Yam', calories: 200, protein: 4, carbs: 47, fat: 0.5, servingSize: '1 ball', region: 'african', emoji: '🫓'),
    FoodItem(id: 'af09', name: 'Akara (Bean Cake)', calories: 170, protein: 9, carbs: 14, fat: 9, servingSize: '3 pieces', region: 'african', emoji: '🧆'),
    FoodItem(id: 'af10', name: 'Moi Moi', calories: 190, protein: 12, carbs: 18, fat: 8, servingSize: '1 wrap', region: 'african', emoji: '🫔'),
    FoodItem(id: 'af11', name: 'Chin Chin', calories: 450, protein: 6, carbs: 55, fat: 22, servingSize: '100g', region: 'african', emoji: '🍪'),
    FoodItem(id: 'af12', name: 'Puff Puff', calories: 280, protein: 4, carbs: 38, fat: 12, servingSize: '5 pieces', region: 'african', emoji: '🍩'),
    FoodItem(id: 'af13', name: 'Ogbono Soup', calories: 300, protein: 15, carbs: 10, fat: 23, servingSize: '1 bowl', region: 'african', emoji: '🥣'),
    FoodItem(id: 'af14', name: 'Pepper Soup', calories: 220, protein: 25, carbs: 5, fat: 12, servingSize: '1 bowl', region: 'african', emoji: '🍲'),
    FoodItem(id: 'af15', name: 'Waakye', calories: 380, protein: 14, carbs: 60, fat: 10, servingSize: '1 plate', region: 'african', emoji: '🍛'),
    FoodItem(id: 'af16', name: 'Banku', calories: 210, protein: 3, carbs: 48, fat: 1, servingSize: '1 ball', region: 'african', emoji: '🫓'),
    FoodItem(id: 'af17', name: 'Kenkey', calories: 200, protein: 4, carbs: 44, fat: 1.5, servingSize: '1 piece', region: 'african', emoji: '🫔'),
    FoodItem(id: 'af18', name: 'Injera', calories: 130, protein: 5, carbs: 26, fat: 1, servingSize: '1 piece', region: 'african', emoji: '🫓'),
    FoodItem(id: 'af19', name: 'Ugali', calories: 195, protein: 4, carbs: 42, fat: 1, servingSize: '1 serving', region: 'african', emoji: '🫓'),
    FoodItem(id: 'af20', name: 'Nyama Choma', calories: 350, protein: 32, carbs: 2, fat: 24, servingSize: '150g', region: 'african', emoji: '🥩'),
    FoodItem(id: 'af21', name: 'Bobotie', calories: 380, protein: 22, carbs: 18, fat: 24, servingSize: '1 serving', region: 'african', emoji: '🥘'),
    FoodItem(id: 'af22', name: 'Thieboudienne', calories: 420, protein: 25, carbs: 50, fat: 14, servingSize: '1 plate', region: 'african', emoji: '🐟'),
    FoodItem(id: 'af23', name: 'Garri (Eba)', calories: 160, protein: 2, carbs: 38, fat: 0.5, servingSize: '1 serving', region: 'african', emoji: '🫓'),
    FoodItem(id: 'af24', name: 'Palm Nut Soup', calories: 340, protein: 12, carbs: 8, fat: 30, servingSize: '1 bowl', region: 'african', emoji: '🥣'),

    // ─── Western Foods ───────────────────────────────────────────────
    FoodItem(id: 'we01', name: 'Grilled Chicken Breast', calories: 165, protein: 31, carbs: 0, fat: 3.6, servingSize: '100g', region: 'western', emoji: '🍗'),
    FoodItem(id: 'we02', name: 'Scrambled Eggs', calories: 210, protein: 14, carbs: 2, fat: 16, servingSize: '2 eggs', region: 'western', emoji: '🥚'),
    FoodItem(id: 'we03', name: 'Oatmeal', calories: 150, protein: 5, carbs: 27, fat: 3, servingSize: '1 bowl', region: 'western', emoji: '🥣'),
    FoodItem(id: 'we04', name: 'Caesar Salad', calories: 220, protein: 8, carbs: 12, fat: 16, servingSize: '1 bowl', region: 'western', emoji: '🥗'),
    FoodItem(id: 'we05', name: 'Cheeseburger', calories: 550, protein: 28, carbs: 40, fat: 32, servingSize: '1 burger', region: 'western', emoji: '🍔'),
    FoodItem(id: 'we06', name: 'Pepperoni Pizza', calories: 300, protein: 13, carbs: 33, fat: 14, servingSize: '1 slice', region: 'western', emoji: '🍕'),
    FoodItem(id: 'we07', name: 'Pasta Carbonara', calories: 480, protein: 18, carbs: 55, fat: 20, servingSize: '1 plate', region: 'western', emoji: '🍝'),
    FoodItem(id: 'we08', name: 'Ribeye Steak', calories: 450, protein: 38, carbs: 0, fat: 33, servingSize: '200g', region: 'western', emoji: '🥩'),
    FoodItem(id: 'we09', name: 'Salmon Fillet', calories: 280, protein: 34, carbs: 0, fat: 16, servingSize: '150g', region: 'western', emoji: '🐟'),
    FoodItem(id: 'we10', name: 'Avocado Toast', calories: 250, protein: 6, carbs: 24, fat: 15, servingSize: '1 slice', region: 'western', emoji: '🥑'),
    FoodItem(id: 'we11', name: 'Greek Yogurt', calories: 130, protein: 15, carbs: 8, fat: 4, servingSize: '1 cup', region: 'western', emoji: '🫙'),
    FoodItem(id: 'we12', name: 'Protein Shake', calories: 200, protein: 30, carbs: 10, fat: 4, servingSize: '1 scoop', region: 'western', emoji: '🥤'),
    FoodItem(id: 'we13', name: 'Turkey Sandwich', calories: 350, protein: 24, carbs: 32, fat: 14, servingSize: '1 sandwich', region: 'western', emoji: '🥪'),
    FoodItem(id: 'we14', name: 'French Fries', calories: 365, protein: 4, carbs: 48, fat: 17, servingSize: '1 serving', region: 'western', emoji: '🍟'),
    FoodItem(id: 'we15', name: 'Pancakes', calories: 350, protein: 8, carbs: 45, fat: 15, servingSize: '3 pancakes', region: 'western', emoji: '🥞'),
    FoodItem(id: 'we16', name: 'Grilled Salmon Bowl', calories: 420, protein: 36, carbs: 35, fat: 16, servingSize: '1 bowl', region: 'western', emoji: '🍱'),
    FoodItem(id: 'we17', name: 'Banana', calories: 105, protein: 1.3, carbs: 27, fat: 0.4, servingSize: '1 medium', region: 'western', emoji: '🍌'),
    FoodItem(id: 'we18', name: 'Apple', calories: 95, protein: 0.5, carbs: 25, fat: 0.3, servingSize: '1 medium', region: 'western', emoji: '🍎'),
    FoodItem(id: 'we19', name: 'Almonds', calories: 160, protein: 6, carbs: 6, fat: 14, servingSize: '28g', region: 'western', emoji: '🥜'),
    FoodItem(id: 'we20', name: 'Brown Rice', calories: 215, protein: 5, carbs: 45, fat: 1.8, servingSize: '1 cup', region: 'western', emoji: '🍚'),

    // ─── Asian Foods ─────────────────────────────────────────────────
    FoodItem(id: 'as01', name: 'Salmon Sushi Roll', calories: 250, protein: 12, carbs: 35, fat: 6, servingSize: '6 pieces', region: 'asian', emoji: '🍣'),
    FoodItem(id: 'as02', name: 'Ramen', calories: 450, protein: 18, carbs: 55, fat: 18, servingSize: '1 bowl', region: 'asian', emoji: '🍜'),
    FoodItem(id: 'as03', name: 'Fried Rice', calories: 380, protein: 10, carbs: 52, fat: 14, servingSize: '1 plate', region: 'asian', emoji: '🍚'),
    FoodItem(id: 'as04', name: 'Pad Thai', calories: 400, protein: 16, carbs: 48, fat: 16, servingSize: '1 plate', region: 'asian', emoji: '🍜'),
    FoodItem(id: 'as05', name: 'Chicken Tikka Masala', calories: 350, protein: 24, carbs: 15, fat: 22, servingSize: '1 serving', region: 'asian', emoji: '🍛'),
    FoodItem(id: 'as06', name: 'Naan Bread', calories: 260, protein: 8, carbs: 45, fat: 5, servingSize: '1 piece', region: 'asian', emoji: '🫓'),
    FoodItem(id: 'as07', name: 'Dim Sum (Har Gow)', calories: 180, protein: 10, carbs: 20, fat: 6, servingSize: '4 pieces', region: 'asian', emoji: '🥟'),
    FoodItem(id: 'as08', name: 'Pho', calories: 380, protein: 22, carbs: 42, fat: 12, servingSize: '1 bowl', region: 'asian', emoji: '🍲'),
    FoodItem(id: 'as09', name: 'Bibimbap', calories: 490, protein: 22, carbs: 60, fat: 18, servingSize: '1 bowl', region: 'asian', emoji: '🍛'),
    FoodItem(id: 'as10', name: 'Kung Pao Chicken', calories: 320, protein: 20, carbs: 18, fat: 20, servingSize: '1 serving', region: 'asian', emoji: '🐔'),
    FoodItem(id: 'as11', name: 'Miso Soup', calories: 60, protein: 4, carbs: 5, fat: 2, servingSize: '1 bowl', region: 'asian', emoji: '🥣'),
    FoodItem(id: 'as12', name: 'Spring Rolls', calories: 200, protein: 6, carbs: 28, fat: 7, servingSize: '3 pieces', region: 'asian', emoji: '🌯'),
    FoodItem(id: 'as13', name: 'Tandoori Chicken', calories: 260, protein: 30, carbs: 4, fat: 14, servingSize: '1 serving', region: 'asian', emoji: '🍗'),

    // ─── European Foods ──────────────────────────────────────────────
    FoodItem(id: 'eu01', name: 'Croissant', calories: 230, protein: 5, carbs: 26, fat: 12, servingSize: '1 piece', region: 'european', emoji: '🥐'),
    FoodItem(id: 'eu02', name: 'Paella', calories: 400, protein: 20, carbs: 50, fat: 14, servingSize: '1 plate', region: 'european', emoji: '🥘'),
    FoodItem(id: 'eu03', name: 'Greek Salad', calories: 180, protein: 6, carbs: 10, fat: 14, servingSize: '1 bowl', region: 'european', emoji: '🥗'),
    FoodItem(id: 'eu04', name: 'Fish and Chips', calories: 600, protein: 24, carbs: 55, fat: 32, servingSize: '1 serving', region: 'european', emoji: '🐟'),
    FoodItem(id: 'eu05', name: 'Moussaka', calories: 350, protein: 18, carbs: 22, fat: 22, servingSize: '1 serving', region: 'european', emoji: '🍆'),
    FoodItem(id: 'eu06', name: 'Schnitzel', calories: 380, protein: 26, carbs: 20, fat: 22, servingSize: '1 piece', region: 'european', emoji: '🥩'),
    FoodItem(id: 'eu07', name: 'Borscht', calories: 140, protein: 5, carbs: 18, fat: 5, servingSize: '1 bowl', region: 'european', emoji: '🍲'),
    FoodItem(id: 'eu08', name: 'Risotto', calories: 350, protein: 10, carbs: 45, fat: 14, servingSize: '1 plate', region: 'european', emoji: '🍚'),
    FoodItem(id: 'eu09', name: 'Bruschetta', calories: 170, protein: 4, carbs: 22, fat: 7, servingSize: '2 pieces', region: 'european', emoji: '🥖'),
    FoodItem(id: 'eu10', name: 'Crepe', calories: 200, protein: 6, carbs: 28, fat: 7, servingSize: '1 piece', region: 'european', emoji: '🫓'),
    FoodItem(id: 'eu11', name: 'Gazpacho', calories: 90, protein: 2, carbs: 10, fat: 4, servingSize: '1 bowl', region: 'european', emoji: '🍅'),
    FoodItem(id: 'eu12', name: 'Pretzels', calories: 380, protein: 10, carbs: 72, fat: 4, servingSize: '100g', region: 'european', emoji: '🥨'),
  ];

  static List<FoodItem> search(String query) {
    if (query.isEmpty) return foods;
    final lower = query.toLowerCase();
    return foods.where((f) =>
      f.name.toLowerCase().contains(lower) ||
      f.region.toLowerCase().contains(lower)
    ).toList();
  }

  static List<FoodItem> byRegion(String region) {
    if (region == 'all') return foods;
    return foods.where((f) => f.region == region).toList();
  }

  static List<String> get regions => ['all', 'african', 'western', 'asian', 'european'];

  static String regionEmoji(String region) => switch (region) {
    'all' => '🌍',
    'african' => '🌾',
    'western' => '🍕',
    'asian' => '🍜',
    'european' => '🥐',
    _ => '🍽️',
  };

  static String regionLabel(String region) => switch (region) {
    'all' => 'All',
    'african' => 'African',
    'western' => 'Western',
    'asian' => 'Asian',
    'european' => 'European',
    _ => 'Other',
  };
}
