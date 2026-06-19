import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/adaptive_loading_indicator.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController searchController;
  final bool isAnalyzing;
  final bool isRefreshing;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onRefresh;
  final VoidCallback onAnalyze;

  const SearchBarWidget({
    super.key,
    required this.searchController,
    required this.isAnalyzing,
    required this.isRefreshing,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onRefresh,
    required this.onAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchHint,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.textTertiary,
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.textTertiary,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onClearSearch();
                        },
                      )
                    : null,
              ),
              onChanged: onSearchChanged,
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: isAnalyzing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: AdaptiveLoadingIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                      size: 20,
                    ),
                  )
                : const Icon(Icons.camera_alt_rounded),
            onPressed: isAnalyzing ? null : onAnalyze,
            tooltip: 'Analyze with AI',
          ),
        ],
      ),
    );
  }
}
