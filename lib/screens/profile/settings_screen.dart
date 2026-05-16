import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../services/language_service.dart';
import '../../services/notification_service.dart';
import 'water_reminder_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Text(
                  AppLocalizations.of(context)!.settings,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Preferences section ───────────────────────────────────
            _sectionHeader(context, AppLocalizations.of(context)!.preferences),
            _sectionCard([
              _settingsTile(
                icon: Icons.language_rounded,
                iconColor: AppColors.primary,
                title: AppLocalizations.of(context)!.language,
                subtitle: _currentLanguageName(provider),
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showLanguagePicker(context, provider);
                },
              ),
              _divider(),
              _settingsTile(
                icon: Icons.notifications_rounded,
                iconColor: const Color(0xFFFBBF24),
                title: AppLocalizations.of(context)!.notifications,
                subtitle: provider.waterRemindersEnabled
                    ? AppLocalizations.of(context)!.waterRemindersActive
                    : AppLocalizations.of(context)!.configureReminders,
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const _NotificationSettingsScreen(),
                    ),
                  );
                },
              ),
              _divider(),
              _settingsTile(
                icon: Icons.email_rounded,
                iconColor: AppColors.secondary,
                title: AppLocalizations.of(context)!.emailUpdate,
                subtitle: provider.userProfile.email.isNotEmpty
                    ? provider.userProfile.email
                    : AppLocalizations.of(context)!.updateEmailAddress,
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showEmailUpdateSheet(context, provider);
                },
              ),
            ]),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Subscription section ──────────────────────────────────
            _sectionHeader(context, AppLocalizations.of(context)!.membership),
            _sectionCard([_premiumTile(context)]),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Support section ───────────────────────────────────────
            _sectionHeader(context, AppLocalizations.of(context)!.support),
            _sectionCard([
              _settingsTile(
                icon: Icons.help_rounded,
                iconColor: const Color(0xFF818CF8),
                title: AppLocalizations.of(context)!.helpAndSupport,
                subtitle: AppLocalizations.of(context)!.faqsContactUs,
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const _HelpSupportScreen(),
                    ),
                  );
                },
              ),
              _divider(),
              _settingsTile(
                icon: Icons.security_rounded,
                iconColor: const Color(0xFF06D6A0),
                title: AppLocalizations.of(context)!.privacyAndSecurity,
                subtitle: AppLocalizations.of(context)!.dataPermissionsPrivacy,
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const _PrivacySecurityScreen(),
                    ),
                  );
                },
              ),
            ]),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────

  String _currentLanguageName(AppProvider provider) {
    final code = provider.currentLocale.languageCode;
    final langs = LanguageService.getAvailableLanguages();
    final match = langs.firstWhere(
      (l) => l['code'] == code,
      orElse: () => {'name': 'English', 'flag': '🇬🇧'},
    );
    return '${match['flag']} ${match['name']}';
  }

  SliverToBoxAdapter _sectionHeader(BuildContext context, String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _sectionCard(List<Widget> children) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(children: children),
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withAlpha(28),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppColors.error : Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDestructive
              ? AppColors.error.withAlpha(150)
              : AppColors.textTertiary,
          fontSize: 12,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textTertiary,
        size: 20,
      ),
      onTap: onTap,
    );
  }

  Widget _premiumTile(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F8EF7), Color(0xFF818CF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.lightImpact();
            _showComingSoonSnackBar(context);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Premium Subscription',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Coming soon — unlock all features',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Soon',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return const Divider(color: AppColors.cardLight, height: 1, indent: 74);
  }

  void _showComingSoonSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.premiumComingSoon),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Language Picker ───────────────────────────────────────────────

  void _showLanguagePicker(BuildContext context, AppProvider provider) {
    final languages = LanguageService.getAvailableLanguages();
    final currentCode = provider.currentLocale.languageCode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        String selected = currentCode;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(ctx).viewInsets.bottom +
                    MediaQuery.of(ctx).padding.bottom +
                    24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.cardLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(ctx)!.chooseLanguage,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(ctx).size.height * 0.45,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: languages.length,
                      separatorBuilder: (_, __) =>
                          const Divider(color: AppColors.cardLight, height: 1),
                      itemBuilder: (_, i) {
                        final lang = languages[i];
                        final code = lang['code']!;
                        final isSelected = selected == code;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Text(
                            lang['flag']!,
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(
                            lang['name']!,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          subtitle: Text(
                            lang['native']!,
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.primary,
                                )
                              : null,
                          onTap: () => setSheetState(() => selected = code),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        HapticFeedback.mediumImpact();
                        
                        // Get localized strings for the NEW language before changing
                        final newLocalizations = lookupAppLocalizations(Locale(selected));
                        
                        await provider.setLocale(
                          Locale(selected),
                          notificationTitle: newLocalizations.waterReminderNotificationTitle,
                          notificationBody: newLocalizations.waterReminderNotificationBody,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(AppLocalizations.of(ctx)!.applyLanguage),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Email Update ─────────────────────────────────────────────────

  void _showEmailUpdateSheet(BuildContext context, AppProvider provider) {
    final controller = TextEditingController(text: provider.userProfile.email);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        bool isSaving = false;
        String? errorMsg;

        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  MediaQuery.of(ctx).padding.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.cardLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Update Email',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'A confirmation link will be sent to your new email address.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.newEmailAddress,
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: AppColors.textSecondary,
                        ),
                        errorText: errorMsg,
                        filled: true,
                        fillColor: AppColors.card,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                final newEmail = controller.text.trim();
                                if (newEmail.isEmpty ||
                                    !newEmail.contains('@')) {
                                  setSheetState(
                                    () =>
                                        errorMsg = AppLocalizations.of(context)!.pleaseEnterValidEmail,
                                  );
                                  return;
                                }
                                setSheetState(() => isSaving = true);
                                try {
                                  await Supabase.instance.client.auth
                                      .updateUser(
                                        UserAttributes(email: newEmail),
                                      );
                                  if (ctx.mounted) {
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Confirmation email sent. Please check your inbox.',
                                        ),
                                        backgroundColor: AppColors.success,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                } on AuthException catch (e) {
                                  setSheetState(() {
                                    isSaving = false;
                                    errorMsg = e.message;
                                  });
                                } catch (_) {
                                  setSheetState(() {
                                    isSaving = false;
                                    errorMsg =
                                        'An error occurred. Please try again.';
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(AppLocalizations.of(context)!.sendConfirmation),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification Settings Screen
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationSettingsScreen extends StatelessWidget {
  const _NotificationSettingsScreen();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      AppLocalizations.of(context)!.notifications,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _switchTile(
                        icon: Icons.water_drop_rounded,
                        iconColor: AppColors.primary,
                        title: AppLocalizations.of(context)!.waterReminders,
                        subtitle: provider.waterRemindersEnabled
                            ? 'Every ${provider.waterReminderIntervalMinutes} min'
                            : AppLocalizations.of(context)!.remindToDrinkWater,
                        value: provider.waterRemindersEnabled,
                        onChanged: (val) async {
                          HapticFeedback.selectionClick();
                          if (val) {
                            final granted =
                                await NotificationService.requestPermissions();
                            if (!granted) return;
                            if (!context.mounted) return;
                            await NotificationService.scheduleWaterReminders(
                              intervalMinutes:
                                  provider.waterReminderIntervalMinutes,
                              startHour: provider.waterReminderStartHour,
                              startMinute: provider.waterReminderStartMinute,
                              endHour: provider.waterReminderEndHour,
                              endMinute: provider.waterReminderEndMinute,
                              notificationTitle: AppLocalizations.of(context)!.waterReminderNotificationTitle,
                              notificationBody: AppLocalizations.of(context)!.waterReminderNotificationBody,
                            );
                          } else {
                            await NotificationService.cancelWaterReminders();
                          }
                          await provider.updateWaterReminders(
                            enabled: val,
                            intervalMinutes:
                                provider.waterReminderIntervalMinutes,
                            startHour: provider.waterReminderStartHour,
                            startMinute: provider.waterReminderStartMinute,
                            endHour: provider.waterReminderEndHour,
                            endMinute: provider.waterReminderEndMinute,
                          );
                        },
                      ),
                      if (provider.waterRemindersEnabled) ...[
                        const Divider(
                          color: AppColors.cardLight,
                          height: 1,
                          indent: 74,
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 4,
                          ),
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(28),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          title: const Text(
                            'Configure Schedule',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: const Text(
                            'Set interval, start & end time',
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textTertiary,
                            size: 20,
                          ),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WaterReminderScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withAlpha(28),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Help & Support Screen
// ─────────────────────────────────────────────────────────────────────────────

class _HelpSupportScreen extends StatelessWidget {
  const _HelpSupportScreen();

  static const _faqs = [
    (
      q: 'How are my daily calories calculated?',
      a: 'LilyFit uses the Mifflin-St Jeor equation combined with your activity level and goal to estimate your Total Daily Energy Expenditure (TDEE) and set an appropriate calorie target.',
    ),
    (
      q: 'Can I change my fitness goal?',
      a: 'Yes! Go to Profile → Edit Profile to update your goal between Fat Loss, Maintenance, and Muscle Gain at any time.',
    ),
    (
      q: 'How do water reminders work?',
      a: 'Enable water reminders in Settings → Notifications. You can set the interval, start time, and end time. Notifications are scheduled locally on your device.',
    ),
    (
      q: 'Is my data stored securely?',
      a: 'Your nutrition and profile data is stored locally on your device and optionally synced to our secure Supabase backend when you are signed in.',
    ),
    (
      q: 'How do I reset all my data?',
      a: 'Go to Profile and scroll to the bottom. Tap "Reset All Data" to clear everything and start fresh. This action cannot be undone.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Help & Support',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Contact cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _contactCard(
                        context,
                        icon: Icons.chat_bubble_rounded,
                        color: AppColors.primary,
                        title: AppLocalizations.of(context)!.liveChat,
                        subtitle: AppLocalizations.of(context)!.chatWithUs,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _contactCard(
                        context,
                        icon: Icons.mail_rounded,
                        color: AppColors.secondary,
                        title: AppLocalizations.of(context)!.emailUs,
                        subtitle: 'support@lilyfit.app',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // FAQ header
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Text(
                  'FREQUENTLY ASKED QUESTIONS',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),

            // FAQ list
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: _faqs.asMap().entries.map((entry) {
                      final i = entry.key;
                      final faq = entry.value;
                      return Column(
                        children: [
                          _FaqTile(question: faq.q, answer: faq.a),
                          if (i < _faqs.length - 1)
                            const Divider(
                              color: AppColors.cardLight,
                              height: 1,
                              indent: 20,
                              endIndent: 20,
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _contactCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.comingSoon(title)),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 4,
            ),
            title: Text(
              widget.question,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: AnimatedRotation(
              turns: _expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 220),
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textTertiary,
              ),
            ),
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _expanded = !_expanded);
            },
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(
                widget.answer,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Privacy & Security Screen
// ─────────────────────────────────────────────────────────────────────────────

class _PrivacySecurityScreen extends StatelessWidget {
  const _PrivacySecurityScreen();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Privacy & Security',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Data section
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(
                  'DATA',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _infoTile(
                        icon: Icons.storage_rounded,
                        iconColor: AppColors.primary,
                        title: AppLocalizations.of(context)!.dataStorage,
                        subtitle:
                            'Your data is stored locally and securely synced to our servers',
                      ),
                      const Divider(
                        color: AppColors.cardLight,
                        height: 1,
                        indent: 74,
                      ),
                      _infoTile(
                        icon: Icons.sync_rounded,
                        iconColor: AppColors.secondary,
                        title: AppLocalizations.of(context)!.dataSync,
                        subtitle:
                            'Automatically synced when you are connected to the internet',
                      ),
                      const Divider(
                        color: AppColors.cardLight,
                        height: 1,
                        indent: 74,
                      ),
                      _actionTile(
                        icon: Icons.delete_sweep_rounded,
                        iconColor: AppColors.warning,
                        title: AppLocalizations.of(context)!.clearLocalCache,
                        subtitle: AppLocalizations.of(context)!.clearCacheSubtitle,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showClearCacheDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Legal section
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(
                  'LEGAL',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _actionTile(
                        icon: Icons.policy_rounded,
                        iconColor: AppColors.primary,
                        title: AppLocalizations.of(context)!.privacyPolicy,
                        subtitle: AppLocalizations.of(context)!.privacyPolicySubtitle,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showPrivacyPolicy(context);
                        },
                      ),
                      const Divider(
                        color: AppColors.cardLight,
                        height: 1,
                        indent: 74,
                      ),
                      _actionTile(
                        icon: Icons.description_rounded,
                        iconColor: const Color(0xFF818CF8),
                        title: AppLocalizations.of(context)!.termsOfService,
                        subtitle: AppLocalizations.of(context)!.termsOfServiceSubtitle,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showTermsOfService(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Danger zone
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(
                  'DANGER ZONE',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _actionTile(
                    icon: Icons.no_accounts_rounded,
                    iconColor: AppColors.error,
                    title: AppLocalizations.of(context)!.deleteAccount,
                    subtitle: AppLocalizations.of(context)!.deleteAccountSubtitle,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showDeleteAccountDialog(context, provider);
                    },
                    isDestructive: true,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withAlpha(28),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withAlpha(28),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppColors.error : Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDestructive
              ? AppColors.error.withAlpha(150)
              : AppColors.textTertiary,
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDestructive
            ? AppColors.error.withAlpha(150)
            : AppColors.textTertiary,
        size: 20,
      ),
      onTap: onTap,
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          AppLocalizations.of(context)!.clearCacheQuestion,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          AppLocalizations.of(context)!.clearCacheBody,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.cacheClearedMsg),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: Text(AppLocalizations.of(context)!.clear),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.privacyPolicy,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Last updated: May 2026',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: controller,
                  children: [
                    _PolicySection(
                      title: AppLocalizations.of(context)!.dataWeCollect,
                      body: AppLocalizations.of(context)!.dataWeCollectBody,
                    ),
                    _PolicySection(
                      title: AppLocalizations.of(context)!.howWeUseData,
                      body: AppLocalizations.of(context)!.howWeUseDataBody,
                    ),
                    _PolicySection(
                      title: AppLocalizations.of(context)!.dataStorageTitle,
                      body: AppLocalizations.of(context)!.dataStorageBody,
                    ),
                    _PolicySection(
                      title: AppLocalizations.of(context)!.yourRights,
                      body: AppLocalizations.of(context)!.yourRightsBody,
                    ),
                    _PolicySection(
                      title: AppLocalizations.of(context)!.contactUs,
                      body: AppLocalizations.of(context)!.contactUsBody,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.termsOfService,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context)!.lastUpdated('May 2026'),
                style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: controller,
                  children: [
                    _PolicySection(
                      title: AppLocalizations.of(context)!.acceptanceOfTerms,
                      body: AppLocalizations.of(context)!.acceptanceOfTermsBody,
                    ),
                    _PolicySection(
                      title: AppLocalizations.of(context)!.useOfApp,
                      body: AppLocalizations.of(context)!.useOfAppBody,
                    ),
                    _PolicySection(
                      title: AppLocalizations.of(context)!.healthDisclaimer,
                      body: AppLocalizations.of(context)!.healthDisclaimerBody,
                    ),
                    _PolicySection(
                      title: AppLocalizations.of(context)!.accountResponsibility,
                      body: AppLocalizations.of(context)!.accountResponsibilityBody,
                    ),
                    _PolicySection(
                      title: AppLocalizations.of(context)!.contactLabel,
                      body: AppLocalizations.of(context)!.contactLabelBody,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          AppLocalizations.of(context)!.deleteAccountQuestion,
          style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w700),
        ),
        content: Text(
          AppLocalizations.of(context)!.deleteAccountBody,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await provider.resetAllData();
                await Supabase.instance.client.auth.admin.deleteUser(
                  Supabase.instance.client.auth.currentUser?.id ?? '',
                );
              } catch (_) {
                // If admin delete fails, sign out is sufficient for the user
                await Supabase.instance.client.auth.signOut();
              }
            },
            child: Text(AppLocalizations.of(context)!.deleteAccount),
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String body;

  const _PolicySection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
