import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../models/user_profile.dart';

/// Example page showing how to use SupabaseService
/// This is for reference - integrate these patterns into your existing screens
class SupabaseExamplePage extends StatefulWidget {
  const SupabaseExamplePage({super.key});

  @override
  State<SupabaseExamplePage> createState() => _SupabaseExamplePageState();
}

class _SupabaseExamplePageState extends State<SupabaseExamplePage> {
  final _supabaseService = SupabaseService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLoading = false;
  String _message = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Example: Sign up a new user
  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final response = await _supabaseService.signUp(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
      );

      if (response.user != null) {
        setState(() => _message = '✅ Sign up successful!');
      }
    } catch (e) {
      setState(() => _message = '❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Example: Sign in existing user
  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final response = await _supabaseService.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (response.user != null) {
        setState(() => _message = '✅ Sign in successful!');
      }
    } catch (e) {
      setState(() => _message = '❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Example: Save user profile
  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final profile = UserProfile(
        name: _nameController.text,
        email: _emailController.text,
        gender: 'male',
        age: 25,
        weight: 70,
        height: 170,
        activityLevel: 'moderate',
        goal: 'maintenance',
      );

      profile.calculateTargets();

      await _supabaseService.saveUserProfile(profile);
      setState(() => _message = '✅ Profile saved!');
    } catch (e) {
      setState(() => _message = '❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Example: Get user profile
  Future<void> _getProfile() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final profile = await _supabaseService.getUserProfile();

      if (profile != null) {
        setState(
          () => _message = '✅ Profile: ${profile.name}, ${profile.email}',
        );
      } else {
        setState(() => _message = 'No profile found');
      }
    } catch (e) {
      setState(() => _message = '❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Example: Log weight
  Future<void> _logWeight() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      await _supabaseService.logWeight(weight: 72.5, date: DateTime.now());
      setState(() => _message = '✅ Weight logged!');
    } catch (e) {
      setState(() => _message = '❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Example: Get weight history
  Future<void> _getWeightHistory() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final history = await _supabaseService.getWeightHistory(limit: 10);
      setState(() => _message = '✅ Found ${history.length} weight entries');
    } catch (e) {
      setState(() => _message = '❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Example: Log a meal
  Future<void> _logMeal() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      await _supabaseService.logMeal(
        mealType: 'breakfast',
        foodName: 'Oatmeal with fruits',
        calories: 350,
        protein: 12,
        carbs: 60,
        fat: 8,
        date: DateTime.now(),
      );
      setState(() => _message = '✅ Meal logged!');
    } catch (e) {
      setState(() => _message = '❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Example: Sign out
  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      await _supabaseService.signOut();
      setState(() => _message = '✅ Signed out successfully');
    } catch (e) {
      setState(() => _message = '❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Supabase Examples')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status message
                  if (_message.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: _message.startsWith('✅')
                            ? Colors.green.withValues()
                            : Colors.red.withValues(),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_message),
                    ),

                  // Input fields
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'John Doe',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'user@example.com',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter password',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),

                  // Auth buttons
                  const Text(
                    'Authentication:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _signUp,
                    child: const Text('Sign Up'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _signIn,
                    child: const Text('Sign In'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _signOut,
                    child: const Text('Sign Out'),
                  ),
                  const SizedBox(height: 24),

                  // Profile buttons
                  const Text(
                    'Profile:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Save Profile'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _getProfile,
                    child: const Text('Get Profile'),
                  ),
                  const SizedBox(height: 24),

                  // Tracking buttons
                  const Text(
                    'Data Tracking:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _logWeight,
                    child: const Text('Log Weight (72.5 kg)'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _getWeightHistory,
                    child: const Text('Get Weight History'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _logMeal,
                    child: const Text('Log Meal (Oatmeal)'),
                  ),
                  const SizedBox(height: 24),

                  // Current status
                  Text(
                    'Logged in: ${_supabaseService.isLoggedIn()}',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
    );
  }
}
