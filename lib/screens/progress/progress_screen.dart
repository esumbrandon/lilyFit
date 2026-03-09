import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/meal_log.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final _weightController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final weightEntries = provider.weightEntries;
    final weeklyCalories = provider.weeklyCalories;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Text(
                  'Progress',
                  style: TextStyle(
                    color: Colors.white,
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
                      'Current',
                      weightEntries.isNotEmpty
                          ? '${weightEntries.last.weight.toStringAsFixed(1)} kg'
                          : '--',
                      Icons.monitor_weight_outlined,
                      AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    _statCard(
                      'BMI',
                      provider.userProfile.bmi.toStringAsFixed(1),
                      Icons.speed_rounded,
                      AppColors.secondary,
                    ),
                    const SizedBox(width: 10),
                    _statCard(
                      'Streak',
                      '${provider.currentStreak} days',
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
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.show_chart_rounded, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Weight History',
                            style: TextStyle(
                              color: Colors.white,
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
                                  'Log at least 2 weights\nto see your chart',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.textTertiary.withAlpha(150),
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : _buildWeightChart(weightEntries),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Log weight button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: ElevatedButton.icon(
                  onPressed: () => _showLogWeightDialog(context),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('Log Today\'s Weight'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.bar_chart_rounded, color: AppColors.secondary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Weekly Calories',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 180,
                        child: _buildWeeklyBarChart(weeklyCalories, provider.userProfile.targetCalories),
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
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weekly Summary',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _summaryRow(
                        'Average Daily Calories',
                        '${_weeklyAverage(weeklyCalories).toInt()} kcal',
                        AppColors.primary,
                      ),
                      const Divider(color: AppColors.cardLight, height: 24),
                      _summaryRow(
                        'Total Meals Logged',
                        '${provider.allMealLogs.length}',
                        AppColors.secondary,
                      ),
                      const Divider(color: AppColors.cardLight, height: 24),
                      _summaryRow(
                        'Weight Change',
                        _weightChange(weightEntries),
                        weightEntries.length >= 2
                            ? (weightEntries.last.weight <= weightEntries.first.weight
                                ? AppColors.success
                                : AppColors.error)
                            : AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightChart(List<WeightEntry> entries) {
    final spots = entries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weight);
    }).toList();

    final minY = entries.map((e) => e.weight).reduce((a, b) => a < b ? a : b) - 2;
    final maxY = entries.map((e) => e.weight).reduce((a, b) => a > b ? a : b) + 2;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.cardLight,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()} kg',
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                ),
              ),
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
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                strokeColor: Colors.white,
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
            getTooltipColor: (touchedSpot) => AppColors.card,
            tooltipRoundedRadius: 12,
            getTooltipItems: (spots) => spots.map((spot) {
              return LineTooltipItem(
                '${spot.y.toStringAsFixed(1)} kg',
                const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyBarChart(
    List<MapEntry<DateTime, double>> data,
    double target,
  ) {
    final maxCal = data.map((e) => e.value).fold(target, (a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxCal + 200,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxCal / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.cardLight,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('E').format(data[index].key).substring(0, 2),
                      style: const TextStyle(
                        color: AppColors.textTertiary,
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: isOverTarget
                      ? [const Color(0xFFEF4444), const Color(0xFFFBBF24)]
                      : isToday
                          ? [AppColors.primary, AppColors.secondary]
                          : [
                              AppColors.primary.withAlpha(100),
                              AppColors.secondary.withAlpha(100),
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
                labelResolver: (_) => 'Target',
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
            getTooltipColor: (group) => AppColors.card,
            tooltipRoundedRadius: 12,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()} kcal',
                const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
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
  }

  double _weeklyAverage(List<MapEntry<DateTime, double>> data) {
    final daysWithData = data.where((e) => e.value > 0).length;
    if (daysWithData == 0) return 0;
    final total = data.fold(0.0, (sum, e) => sum + e.value);
    return total / daysWithData;
  }

  String _weightChange(List<WeightEntry> entries) {
    if (entries.length < 2) return '--';
    final change = entries.last.weight - entries.first.weight;
    final sign = change >= 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(1)} kg';
  }

  void _showLogWeightDialog(BuildContext context) {
    _weightController.text = context.read<AppProvider>().userProfile.weight.toStringAsFixed(1);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Log Weight',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your current weight',
              style: TextStyle(color: Colors.white.withAlpha(150)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                suffixText: 'kg',
                suffixStyle: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 16,
                ),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textTertiary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final weight = double.tryParse(_weightController.text);
              if (weight != null && weight > 0) {
                context.read<AppProvider>().addWeight(weight);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
