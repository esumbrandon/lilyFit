import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class MonthlyCarbsChart extends StatefulWidget {
  final List<MapEntry<DateTime, double>> data;
  final double targetCarbs;
  final bool isDarkMode;

  const MonthlyCarbsChart({
    super.key,
    required this.data,
    required this.targetCarbs,
    required this.isDarkMode,
  });

  @override
  State<MonthlyCarbsChart> createState() => _MonthlyCarbsChartState();
}

class _MonthlyCarbsChartState extends State<MonthlyCarbsChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Statistics Row
        _buildStatsRow(),
        const SizedBox(height: 20),

        // Chart
        SizedBox(
          height: 220,
          child: widget.data.isEmpty ? _buildEmptyState() : _buildChart(),
        ),

        const SizedBox(height: 16),

        // Legend
        _buildLegend(),
      ],
    );
  }

  Widget _buildStatsRow() {
    final daysWithData = widget.data.where((e) => e.value > 0).length;
    final totalCarbs = widget.data.fold(0.0, (sum, e) => sum + e.value);
    final avgCarbs = daysWithData > 0 ? totalCarbs / daysWithData : 0;
    final daysMetGoal = widget.data
        .where(
          (e) =>
              e.value >= widget.targetCarbs * 0.9 &&
              e.value <= widget.targetCarbs * 1.1,
        )
        .length;
    final goalPercentage = daysWithData > 0
        ? (daysMetGoal / daysWithData * 100)
        : 0;

    return Row(
      children: [
        Expanded(
          child: _statCard(
            'Avg Daily',
            '${avgCarbs.toInt()}g',
            Icons.show_chart_rounded,
            AppColors.carbs,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            'Goal Met',
            '${goalPercentage.toInt()}%',
            Icons.check_circle_outline_rounded,
            goalPercentage >= 70 ? AppColors.success : AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            'Target',
            '${widget.targetCarbs.toInt()}g',
            Icons.flag_rounded,
            AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: widget.isDarkMode
                  ? AppColors.darkTextTertiary
                  : AppColors.textTertiary,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final maxCarbs = widget.data
        .map((e) => e.value)
        .fold(widget.targetCarbs * 1.2, (a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxCarbs / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: widget.isDarkMode
                ? AppColors.darkCardLight
                : AppColors.cardLight,
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              interval: maxCarbs / 4,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '${value.toInt()}g',
                    style: TextStyle(
                      color: widget.isDarkMode
                          ? AppColors.darkTextTertiary
                          : AppColors.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 &&
                    index < widget.data.length &&
                    index % 5 == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('d/M').format(widget.data[index].key),
                      style: TextStyle(
                        color: widget.isDarkMode
                            ? AppColors.darkTextTertiary
                            : AppColors.textTertiary,
                        fontSize: 9,
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
        minY: 0,
        maxY: maxCarbs,
        lineBarsData: [
          LineChartBarData(
            spots: widget.data.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.value);
            }).toList(),
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppColors.carbs,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final isSelected = _touchedIndex == index;
                final carbs = spot.y;
                final isGoalMet =
                    carbs >= widget.targetCarbs * 0.9 &&
                    carbs <= widget.targetCarbs * 1.1;

                return FlDotCirclePainter(
                  radius: isSelected ? 6 : 3,
                  color: isGoalMet ? AppColors.success : AppColors.carbs,
                  strokeWidth: isSelected ? 3 : 1.5,
                  strokeColor: widget.isDarkMode
                      ? AppColors.darkCard
                      : AppColors.card,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.carbs.withAlpha(80),
                  AppColors.carbs.withAlpha(20),
                  AppColors.carbs.withAlpha(5),
                ],
              ),
            ),
          ),
        ],
        // Target line
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: widget.targetCarbs,
              color: AppColors.primary.withAlpha(120),
              strokeWidth: 2,
              dashArray: [8, 4],
              label: HorizontalLineLabel(
                show: true,
                labelResolver: (_) => 'Goal',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(right: 5, bottom: 5),
              ),
            ),
          ],
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
            if (response == null || response.lineBarSpots == null) {
              setState(() => _touchedIndex = null);
              return;
            }
            setState(() {
              _touchedIndex = response.lineBarSpots!.first.spotIndex;
            });
          },
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => widget.isDarkMode
                ? AppColors.darkCard.withAlpha(230)
                : AppColors.card.withAlpha(230),
            tooltipRoundedRadius: 12,
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            getTooltipItems: (spots) => spots.map((spot) {
              final index = spot.spotIndex;
              final date = widget.data[index].key;
              final carbs = spot.y;
              final percentOfGoal = (carbs / widget.targetCarbs * 100).toInt();

              return LineTooltipItem(
                '${DateFormat('MMM d').format(date)}\n${carbs.toInt()}g ($percentOfGoal%)',
                TextStyle(
                  color: widget.isDarkMode
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 48,
            color:
                (widget.isDarkMode
                        ? AppColors.darkTextTertiary
                        : AppColors.textTertiary)
                    .withAlpha(100),
          ),
          const SizedBox(height: 12),
          Text(
            'No carbs data yet',
            style: TextStyle(
              color: widget.isDarkMode
                  ? AppColors.darkTextTertiary
                  : AppColors.textTertiary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Start logging meals to see your progress',
            style: TextStyle(
              color:
                  (widget.isDarkMode
                          ? AppColors.darkTextTertiary
                          : AppColors.textTertiary)
                      .withAlpha(150),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem('Goal Met', AppColors.success),
        const SizedBox(width: 20),
        _legendItem('Below/Above', AppColors.carbs),
        const SizedBox(width: 20),
        _legendItem('Target Line', AppColors.primary),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: widget.isDarkMode
                ? AppColors.darkTextTertiary
                : AppColors.textTertiary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
