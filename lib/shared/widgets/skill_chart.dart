import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Radar-style skill chart displaying skill scores.
class SkillChart extends StatelessWidget {
  final List<SkillData> skills;
  final double size;

  const SkillChart({
    super.key,
    required this.skills,
    this.size = 280,
  });

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) {
      return SizedBox(
        height: size,
        child: Center(
          child: Text(
            'No skills tracked yet',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return SizedBox(
      height: size,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          tickCount: 4,
          ticksTextStyle: const TextStyle(fontSize: 0),
          tickBorderData: BorderSide(
            color: AppColors.glassBorder,
            width: 0.5,
          ),
          gridBorderData: BorderSide(
            color: AppColors.glassBorder,
            width: 0.5,
          ),
          titlePositionPercentageOffset: 0.2,
          titleTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          dataSets: [
            RadarDataSet(
              fillColor: AppColors.primary.withValues(alpha: 0.2),
              borderColor: AppColors.primary,
              borderWidth: 2,
              entryRadius: 4,
              dataEntries: skills
                  .map((s) => RadarEntry(value: s.score.toDouble()))
                  .toList(),
            ),
          ],
          getTitle: (index, angle) {
            if (index < skills.length) {
              return RadarChartTitle(
                text: skills[index].name,
              );
            }
            return const RadarChartTitle(text: '');
          },
        ),
      ),
    );
  }
}

/// Bar chart showing skill progress over categories.
class SkillBarChart extends StatelessWidget {
  final List<SkillData> skills;
  final double height;

  const SkillBarChart({
    super.key,
    required this.skills,
    this.height = 250,
  });

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No skills to display',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${skills[groupIndex].name}\n${rod.toY.toInt()}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < skills.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        skills[index].name.length > 6
                            ? '${skills[index].name.substring(0, 6)}..'
                            : skills[index].name,
                        style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: List.generate(skills.length, (index) {
            final colorIndex = index % AppColors.chartColors.length;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: skills[index].score.toDouble(),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.chartColors[colorIndex],
                      AppColors.chartColors[colorIndex]
                          .withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  width: 24,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

/// Skill data model for charts.
class SkillData {
  final String name;
  final int score;
  final String? category;

  const SkillData({
    required this.name,
    required this.score,
    this.category,
  });
}
