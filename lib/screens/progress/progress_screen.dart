import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/meal_log.dart';
import '../../models/user_profile.dart';
import '../../utils/unit_converter.dart';
import '../../widgets/monthly_carbs_chart.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();
    final weightEntries = provider.weightEntries;
    final weeklyCalories = provider.weeklyCalories;
    final monthlyCarbs = provider.monthlyCarbs;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Text(
                  AppLocalizations.of(context)!.progress,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // Stats Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    _statCard(
                      context,
                      AppLocalizations.of(context)!.current,
                      weightEntries.isNotEmpty
                          ? UnitConverter.formatWeight(
                              weightEntries.last.weight,
                              provider.userProfile.weightUnit,
                            )
                          : '--',
                      Icons.monitor_weight_outlined,
                      AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    _bmiCard(context, provider.userProfile),
                    const SizedBox(width: 10),
                    _statCard(
                      context,
                      AppLocalizations.of(context)!.streak,
                      '${provider.currentStreak} ${AppLocalizations.of(context)!.days}',
                      Icons.local_fire_department_rounded,
                      AppColors.carbs,
                    ),
                  ],
                ),
              ),
            ),

            // Weight Chart
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.show_chart_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.weightHistory,
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 200,
                        child: weightEntries.length < 2
                            ? Center(
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.logAtLeast2Weights,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        (isDark
                                                ? AppColors.darkTextTertiary
                                                : AppColors.textTertiary)
                                            .withAlpha(150),
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : _buildWeightChart(
                                weightEntries,
                                provider.userProfile.weightUnit,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Weekly Calories Chart
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.bar_chart_rounded,
                            color: AppColors.secondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.weeklyCalories,
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 180,
                        child: _buildWeeklyBarChart(
                          weeklyCalories,
                          provider.userProfile.targetCalories,
                          AppLocalizations.of(context)!.target,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Monthly Carbs Chart
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.analytics_rounded,
                            color: AppColors.carbs,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Monthly Carbs Tracking',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.carbs.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Last 30 Days',
                              style: TextStyle(
                                color: AppColors.carbs,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      MonthlyCarbsChart(
                        data: monthlyCarbs,
                        targetCarbs: provider.userProfile.targetCarbs,
                        isDarkMode: isDark,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Summary stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.weeklySummary,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _summaryRow(
                        AppLocalizations.of(context)!.avgDailyCalories,
                        '${_weeklyAverage(weeklyCalories).toInt()} kcal',
                        AppColors.primary,
                      ),
                      Divider(
                        color: isDark
                            ? AppColors.darkCardLight
                            : AppColors.cardLight,
                        height: 24,
                      ),
                      _summaryRow(
                        AppLocalizations.of(context)!.totalMealsLogged,
                        '${provider.allMealLogs.length}',
                        AppColors.secondary,
                      ),
                      Divider(
                        color: isDark
                            ? AppColors.darkCardLight
                            : AppColors.cardLight,
                        height: 24,
                      ),
                      _summaryRow(
                        AppLocalizations.of(context)!.weightChange,
                        _weightChange(
                          weightEntries,
                          provider.userProfile.weightUnit,
                        ),
                        weightEntries.length >= 2
                            ? (weightEntries.last.weight <=
                                      weightEntries.first.weight
                                  ? AppColors.success
                                  : AppColors.error)
                            : AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom padding for navbar
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.textTertiary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bmiCard(BuildContext context, UserProfile profile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bmi = profile.bmi;
    final category = profile.bmiCategory;
    final categoryColor = _getBmiColor(bmi);
    final categoryText = _getLocalizedBmiCategory(context, category);

    return Expanded(
      child: GestureDetector(
        onTap: () => _showBmiInfo(context),
        onLongPress: () => _showBmiInfo(context),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: categoryColor.withAlpha(100), width: 1.5),
          ),
          child: Column(
            children: [
              Icon(Icons.speed_rounded, color: categoryColor, size: 24),
              const SizedBox(height: 10),
              Text(
                bmi.toStringAsFixed(1),
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context)!.bmi,
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.textTertiary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: categoryColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  categoryText,
                  style: TextStyle(
                    color: categoryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  String _getLocalizedBmiCategory(BuildContext context, String category) {
    final localizations = AppLocalizations.of(context)!;
    switch (category) {
      case 'Underweight':
        return localizations.bmiUnderweight;
      case 'Normal':
        return localizations.bmiNormal;
      case 'Overweight':
        return localizations.bmiOverweight;
      case 'Obese':
        return localizations.bmiObese;
      default:
        return category;
    }
  }

  void _showBmiInfo(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.read<AppProvider>();
    final profile = provider.userProfile;
    final bmi = profile.bmi;
    final categoryColor = _getBmiColor(bmi);
    final categoryText = _getLocalizedBmiCategory(context, profile.bmiCategory);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                  color: isDark ? AppColors.darkCardLight : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: categoryColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.speed_rounded,
                    color: categoryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.bmiStatus,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${AppLocalizations.of(context)!.bmi}: ${bmi.toStringAsFixed(1)}',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: categoryColor.withAlpha(25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: categoryColor.withAlpha(50)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: categoryColor, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    '${AppLocalizations.of(context)!.bmiStatus}: ',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    categoryText,
                    style: TextStyle(
                      color: categoryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.bmiInfo,
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bmiRangeItem(
                    context,
                    AppLocalizations.of(context)!.bmiUnderweight,
                    '< 18.5',
                    Colors.blue,
                    bmi < 18.5,
                  ),
                  const SizedBox(height: 12),
                  _bmiRangeItem(
                    context,
                    AppLocalizations.of(context)!.bmiNormal,
                    '18.5 - 24.9',
                    Colors.green,
                    bmi >= 18.5 && bmi < 25,
                  ),
                  const SizedBox(height: 12),
                  _bmiRangeItem(
                    context,
                    AppLocalizations.of(context)!.bmiOverweight,
                    '25.0 - 29.9',
                    Colors.orange,
                    bmi >= 25 && bmi < 30,
                  ),
                  const SizedBox(height: 12),
                  _bmiRangeItem(
                    context,
                    AppLocalizations.of(context)!.bmiObese,
                    '≥ 30.0',
                    Colors.red,
                    bmi >= 30,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bmiRangeItem(
    BuildContext context,
    String label,
    String range,
    Color color,
    bool isActive,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? color : color.withAlpha(50),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isActive
                  ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)
                  : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary),
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        Text(
          range,
          style: TextStyle(
            color: isActive
                ? color
                : (isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.textTertiary),
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildWeightChart(List<WeightEntry> entries, String weightUnit) {
    final spots = entries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weight);
    }).toList();

    final minY =
        entries.map((e) => e.weight).reduce((a, b) => a < b ? a : b) - 2;
    final maxY =
        entries.map((e) => e.weight).reduce((a, b) => a > b ? a : b) + 2;

    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: (maxY - minY) / 4,
              getDrawingHorizontalLine: (value) => FlLine(
                color: isDark ? AppColors.darkCardLight : AppColors.cardLight,
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 42,
                  getTitlesWidget: (value, meta) {
                    final displayValue = weightUnit == 'lbs'
                        ? UnitConverter.kgToLbs(value)
                        : value;
                    final unit = weightUnit == 'lbs' ? 'lbs' : 'kg';
                    return Text(
                      '${displayValue.toInt()} $unit',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.textTertiary,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < entries.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          DateFormat('d/M').format(entries[index].date),
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.textTertiary,
                            fontSize: 10,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            minY: minY,
            maxY: maxY,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: AppColors.primary,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (p0, p1, p2, p3) => FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.primary,
                    strokeWidth: 2,
                    strokeColor: isDark ? AppColors.darkCard : AppColors.card,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withAlpha(60),
                      AppColors.primary.withAlpha(5),
                    ],
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (touchedSpot) =>
                    isDark ? AppColors.darkCard : AppColors.card,
                tooltipRoundedRadius: 12,
                getTooltipItems: (spots) => spots.map((spot) {
                  return LineTooltipItem(
                    UnitConverter.formatWeight(spot.y, weightUnit),
                    TextStyle(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeeklyBarChart(
    List<MapEntry<DateTime, double>> data,
    double target,
    String targetLabel,
  ) {
    final maxCal = data
        .map((e) => e.value)
        .fold(target, (a, b) => a > b ? a : b);

    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxCal + 200,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxCal / 4,
              getDrawingHorizontalLine: (value) => FlLine(
                color: isDark ? AppColors.darkCardLight : AppColors.cardLight,
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < data.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          DateFormat(
                            'E',
                          ).format(data[index].key).substring(0, 2),
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: data.asMap().entries.map((entry) {
              final isToday = entry.key == data.length - 1;
              final isOverTarget = entry.value.value > target;
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.value,
                    width: 20,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: isOverTarget
                          ? [AppColors.carbs, AppColors.carbs.withAlpha(200)]
                          : isToday
                          ? [
                              AppColors.primary,
                              AppColors.primary.withAlpha(200),
                            ]
                          : [
                              AppColors.primary.withAlpha(100),
                              AppColors.primary.withAlpha(150),
                            ],
                    ),
                  ),
                ],
              );
            }).toList(),
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: target,
                  color: AppColors.carbs.withAlpha(100),
                  strokeWidth: 1,
                  dashArray: [8, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    labelResolver: (_) => targetLabel,
                    style: const TextStyle(
                      color: AppColors.carbs,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) =>
                    isDark ? AppColors.darkCard : AppColors.card,
                tooltipRoundedRadius: 12,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${rod.toY.toInt()} kcal',
                    TextStyle(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _summaryRow(String label, String value, Color color) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
      },
    );
  }

  double _weeklyAverage(List<MapEntry<DateTime, double>> data) {
    final daysWithData = data.where((e) => e.value > 0).length;
    if (daysWithData == 0) return 0;
    final total = data.fold(0.0, (sum, e) => sum + e.value);
    return total / daysWithData;
  }

  String _weightChange(List<WeightEntry> entries, String weightUnit) {
    if (entries.length < 2) return '--';
    final change = entries.last.weight - entries.first.weight;

    // Convert to user's preferred unit
    final displayChange = weightUnit == 'lbs'
        ? UnitConverter.kgToLbs(change.abs())
        : change.abs();

    final sign = change >= 0 ? '+' : '-';
    final unit = weightUnit == 'lbs' ? 'lbs' : 'kg';
    return '$sign${displayChange.toStringAsFixed(1)} $unit';
  }
}
