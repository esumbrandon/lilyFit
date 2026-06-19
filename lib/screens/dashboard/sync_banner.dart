import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/adaptive_loading_indicator.dart';

class SyncBanner extends StatelessWidget {
  const SyncBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDone = provider.syncStatus == SyncStatus.done;
    final isSyncing = provider.syncStatus == SyncStatus.syncing;
    final hasPendingItems = provider.pendingOperationsCount > 0;
    final isOffline = !provider.isOnline;

    late Color bgColor;
    late Color borderColor;
    late Color iconColor;
    late IconData icon;
    late String message;

    if (isDone) {
      bgColor = Colors.green.withValues(alpha: 0.2);
      borderColor = Colors.green.withValues(alpha: 0.2);
      iconColor = Colors.green;
      icon = Icons.check_circle_rounded;
      message = 'All changes synced';
    } else if (isSyncing) {
      bgColor = AppColors.primary.withValues(alpha: 0.2);
      borderColor = AppColors.primary.withValues(alpha: 0.2);
      iconColor = AppColors.primary;
      icon = Icons.sync_rounded;
      final count = provider.pendingOperationsCount;
      message = count > 0
          ? 'Syncing $count ${count == 1 ? "item" : "items"}...'
          : 'Syncing...';
    } else if (isOffline && hasPendingItems) {
      bgColor = AppColors.accent.withValues(alpha: 0.2);
      borderColor = AppColors.accent.withValues(alpha: 0.2);
      iconColor = AppColors.accent;
      icon = Icons.cloud_off_rounded;
      final count = provider.pendingOperationsCount;
      message = 'Offline – $count ${count == 1 ? "change" : "changes"} pending';
    } else if (isOffline) {
      // Just offline, no pending items
      bgColor = AppColors.accent.withValues(alpha: 0.2);
      borderColor = AppColors.accent.withValues(alpha: 0.2);
      iconColor = AppColors.accent;
      icon = Icons.cloud_off_rounded;
      message = 'Offline mode';
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      key: ValueKey(
        isDone
            ? 'done'
            : isSyncing
            ? 'syncing'
            : 'offline',
      ),
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          isSyncing && !isDone
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: AdaptiveLoadingIndicator(
                    color: iconColor,
                    strokeWidth: 2,
                    size: 18,
                  ),
                )
              : Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: iconColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
