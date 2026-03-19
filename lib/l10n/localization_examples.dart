// EXAMPLE: How to Use Localization in Your Widgets
// This file demonstrates converting hardcoded strings to localized versions

import 'package:flutter/material.dart';
import 'package:lilyfit/l10n/app_localizations.dart';

// ============================================
// EXAMPLE 1: Simple Button
// ============================================

// ❌ BEFORE (Hardcoded):
class BeforeLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () {}, child: const Text('Login'));
  }
}

// ✅ AFTER (Localized):
class AfterLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ElevatedButton(onPressed: () {}, child: Text(l10n.login));
  }
}

// ============================================
// EXAMPLE 2: Form with Multiple Strings
// ============================================

// ❌ BEFORE (Hardcoded):
class BeforeLoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Enter your email',
          ),
        ),
        TextField(
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter your password',
          ),
        ),
        ElevatedButton(onPressed: () {}, child: const Text('Login')),
      ],
    );
  }
}

// ✅ AFTER (Localized):
class AfterLoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: l10n.email,
            hintText: l10n.enterEmail,
          ),
        ),
        TextField(
          decoration: InputDecoration(
            labelText: l10n.password,
            hintText: l10n.enterPassword,
          ),
        ),
        ElevatedButton(onPressed: () {}, child: Text(l10n.login)),
      ],
    );
  }
}

// ============================================
// EXAMPLE 3: Bottom Navigation Bar
// ============================================

// ❌ BEFORE (Hardcoded):
class BeforeBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Food'),
        BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Progress'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}

// ✅ AFTER (Localized):
class AfterBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(icon: const Icon(Icons.home), label: l10n.home),
        BottomNavigationBarItem(
          icon: const Icon(Icons.search),
          label: l10n.food,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.insights),
          label: l10n.progress,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: l10n.profile,
        ),
      ],
    );
  }
}

// ============================================
// EXAMPLE 4: Dialog with Multiple Strings
// ============================================

// ❌ BEFORE (Hardcoded):
void showBeforeLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () {
            // Logout logic
            Navigator.pop(context);
          },
          child: const Text('Yes'),
        ),
      ],
    ),
  );
}

// ✅ AFTER (Localized):
void showAfterLogoutDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.logout),
      content: Text(l10n.logoutConfirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.no),
        ),
        TextButton(
          onPressed: () {
            // Logout logic
            Navigator.pop(context);
          },
          child: Text(l10n.yes),
        ),
      ],
    ),
  );
}

// ============================================
// EXAMPLE 5: List of Meals with Localization
// ============================================

// ❌ BEFORE (Hardcoded):
class BeforeMealList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ListTile(title: Text('Breakfast')),
        ListTile(title: Text('Lunch')),
        ListTile(title: Text('Dinner')),
        ListTile(title: Text('Snacks')),
      ],
    );
  }
}

// ✅ AFTER (Localized):
class AfterMealList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      children: [
        ListTile(title: Text(l10n.breakfast)),
        ListTile(title: Text(l10n.lunch)),
        ListTile(title: Text(l10n.dinner)),
        ListTile(title: Text(l10n.snacks)),
      ],
    );
  }
}

// ============================================
// TIPS:
// ============================================
// 1. Always get l10n at the start of build() method
// 2. Remove 'const' from Text widgets when using l10n
// 3. Use l10n for ALL user-facing strings (buttons, labels, messages, etc.)
// 4. Don't use l10n for:
//    - Code identifiers
//    - API endpoints
//    - Database keys
//    - Log messages (unless shown to users)
