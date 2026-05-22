import 'package:flutter/material.dart';
import 'package:lilyfit/l10n/app_localizations.dart';

class BeforeLoginButton extends StatelessWidget {
  const BeforeLoginButton({super.key});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () {}, child: const Text('Login'));
  }
}

// ✅ AFTER (Localized):
class AfterLoginButton extends StatelessWidget {
  const AfterLoginButton({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ElevatedButton(onPressed: () {}, child: Text(l10n.login));
  }
}

class BeforeLoginForm extends StatelessWidget {
  const BeforeLoginForm({super.key});
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

class AfterLoginForm extends StatelessWidget {
  const AfterLoginForm({super.key});
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

class BeforeBottomNav extends StatelessWidget {
  const BeforeBottomNav({super.key});
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

class AfterBottomNav extends StatelessWidget {
  const AfterBottomNav({super.key});
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

class BeforeMealList extends StatelessWidget {
  const BeforeMealList({super.key});
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

class AfterMealList extends StatelessWidget {
  const AfterMealList({super.key});
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
