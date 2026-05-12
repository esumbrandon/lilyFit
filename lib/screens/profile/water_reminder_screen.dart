import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../services/notification_service.dart';

class WaterReminderScreen extends StatefulWidget {
  const WaterReminderScreen({super.key});

  @override
  State<WaterReminderScreen> createState() => _WaterReminderScreenState();
}

class _WaterReminderScreenState extends State<WaterReminderScreen> {
  late bool _enabled;
  late int _intervalMinutes;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  bool _saving = false;

  static const List<int> _intervalOptions = [30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    final p = context.read<AppProvider>();
    _enabled = p.waterRemindersEnabled;
    _intervalMinutes = p.waterReminderIntervalMinutes;
    _startTime = TimeOfDay(
      hour: p.waterReminderStartHour,
      minute: p.waterReminderStartMinute,
    );
    _endTime = TimeOfDay(
      hour: p.waterReminderEndHour,
      minute: p.waterReminderEndMinute,
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────

  String _formatInterval(int minutes) {
    if (minutes < 60) return 'Every $minutes min';
    if (minutes == 60) return 'Every hour';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? 'Every ${h}h' : 'Every ${h}h ${m}m';
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  int _totalDailyReminders() {
    final startMin = _startTime.hour * 60 + _startTime.minute;
    final endMin = _endTime.hour * 60 + _endTime.minute;
    if (endMin <= startMin || _intervalMinutes <= 0) return 0;
    return ((endMin - startMin) ~/ _intervalMinutes) + 1;
  }

  // ─── Actions ────────────────────────────────────────────────────

  Future<void> _pickTime(bool isStart) async {
    final initial = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;

    // Validate: end must be after start
    if (isStart) {
      final endMin = _endTime.hour * 60 + _endTime.minute;
      final newMin = picked.hour * 60 + picked.minute;
      if (newMin >= endMin) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.startTimeError)),
          );
        }
        return;
      }
      setState(() => _startTime = picked);
    } else {
      final startMin = _startTime.hour * 60 + _startTime.minute;
      final newMin = picked.hour * 60 + picked.minute;
      if (newMin <= startMin) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.endTimeError)),
          );
        }
        return;
      }
      setState(() => _endTime = picked);
    }
  }

  Future<void> _save() async {
    HapticFeedback.mediumImpact();
    setState(() => _saving = true);

    // Request permission when the user turns reminders on.
    if (_enabled) {
      final granted = await NotificationService.requestPermissions();
      if (!mounted) return;
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Notification permission denied. Please enable it in Settings.',
            ),
          ),
        );
        setState(() => _saving = false);
        return;
      }
    }

    final provider = context.read<AppProvider>();
    await provider.updateWaterReminders(
      enabled: _enabled,
      intervalMinutes: _intervalMinutes,
      startHour: _startTime.hour,
      startMinute: _startTime.minute,
      endHour: _endTime.hour,
      endMinute: _endTime.minute,
    );

    if (_enabled) {
      await NotificationService.scheduleWaterReminders(
        intervalMinutes: _intervalMinutes,
        startHour: _startTime.hour,
        startMinute: _startTime.minute,
        endHour: _endTime.hour,
        endMinute: _endTime.minute,
      );
    } else {
      await NotificationService.cancelWaterReminders();
    }

    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _enabled
                ? AppLocalizations.of(context)!.waterRemindersEnabled(_totalDailyReminders())
                : AppLocalizations.of(context)!.waterRemindersDisabled,
          ),
          backgroundColor: AppColors.secondary,
        ),
      );
    }
  }

  // ─── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          AppLocalizations.of(context)!.waterRemindersTitle,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Hero card
            _buildHeroCard(),
            const SizedBox(height: 24),

            // Enable toggle
            _buildSection(child: _buildToggleRow()),
            const SizedBox(height: 16),

            // Interval picker
            AnimatedOpacity(
              opacity: _enabled ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !_enabled,
                child: Column(
                  children: [
                    _buildSection(
                      title: AppLocalizations.of(context)!.reminderInterval,
                      child: _buildIntervalChips(),
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      title: AppLocalizations.of(context)!.activeHours,
                      child: _buildTimeRow(),
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryCard(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Sub-widgets ─────────────────────────────────────────────────

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.coolGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.water_drop, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay Hydrated',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Set up reminders to help you hit your daily water goal.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({String? title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildToggleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (_enabled ? AppColors.primary : AppColors.textTertiary)
                    .withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.notifications_active_rounded,
                color: _enabled ? AppColors.primary : AppColors.textTertiary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enable Reminders',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Get notified to drink water',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        Switch(
          value: _enabled,
          onChanged: (v) {
            HapticFeedback.selectionClick();
            setState(() => _enabled = v);
          },
          activeThumbColor: AppColors.primary,
          activeTrackColor: AppColors.primary.withAlpha(100),
        ),
      ],
    );
  }

  Widget _buildIntervalChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _intervalOptions.map((minutes) {
        final selected = _intervalMinutes == minutes;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _intervalMinutes = minutes);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.cardLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? AppColors.primary
                    : Colors.white.withAlpha(15),
              ),
            ),
            child: Text(
              _formatInterval(minutes),
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeRow() {
    return Row(
      children: [
        Expanded(child: _buildTimeTile('Start', _startTime, true)),
        const SizedBox(width: 12),
        const Icon(
          Icons.arrow_forward_rounded,
          color: AppColors.textTertiary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(child: _buildTimeTile('End', _endTime, false)),
      ],
    );
  }

  Widget _buildTimeTile(String label, TimeOfDay time, bool isStart) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _pickTime(isStart);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withAlpha(15)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(time),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final count = _totalDailyReminders();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.secondary.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withAlpha(60)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.secondary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              count > 0
                  ? 'You\'ll receive $count reminder${count == 1 ? '' : 's'} per day between ${_formatTime(_startTime)} and ${_formatTime(_endTime)}.'
                  : 'Adjust the time window or interval to see reminders.',
              style: const TextStyle(color: AppColors.secondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
