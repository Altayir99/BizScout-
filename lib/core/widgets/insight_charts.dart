import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Collapsible source domain distribution chart for search results.
class SourceDomainChart extends StatelessWidget {
  final List<String> sources;
  const SourceDomainChart({super.key, required this.sources});

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) return const SizedBox.shrink();

    // Count domains
    final domainCounts = <String, int>{};
    for (final url in sources) {
      try {
        final domain = Uri.parse(url).host.replaceFirst('www.', '');
        final short = domain.split('.').take(2).join('.');
        domainCounts[short] = (domainCounts[short] ?? 0) + 1;
      } catch (_) {}
    }

    if (domainCounts.isEmpty) return const SizedBox.shrink();

    // Sort by count descending, take top 6
    final sorted = domainCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(6).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, size: 16, color: AppColors.accent),
              const SizedBox(width: 6),
              Text('QUELLEN-VERTEILUNG',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  )),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: top.length * 34.0 + 8,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (top.first.value + 1).toDouble(),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBorderRadius: BorderRadius.circular(8),
                    getTooltipColor: (_) => const Color(0xFF2C2C2A),
                    getTooltipItem: (group, gI, rod, rI) {
                      return BarTooltipItem(
                        '${top[group.x.toInt()].key}\n${rod.toY.toInt()}×',
                        TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= top.length) return const SizedBox.shrink();
                        final label = top[idx].key;
                        final short = label.length > 12
                            ? '${label.substring(0, 10)}…'
                            : label;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(short,
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 9,
                              )),
                        );
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
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: top.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.value.toDouble(),
                        color: AppColors.accent,
                        width: 18,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: (top.first.value + 1).toDouble(),
                          color: AppColors.accentSubtle,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mode usage history pie chart.
class ModeUsagePieChart extends StatelessWidget {
  final Map<String, int> modeCounts;
  const ModeUsagePieChart({super.key, required this.modeCounts});

  static const _modeColors = {
    'general': Color(0xFF3498DB),
    'markt': Color(0xFFF39C12),
    'firmen': Color(0xFF2ECC71),
    'finanzen': Color(0xFF9B59B6),
    'tech': Color(0xFFE67E22),
    'recht': Color(0xFF1ABC9C),
    'trends': Color(0xFFE74C3C),
    'akquise': Color(0xFF34495E),
  };

  static const _modeLabels = {
    'general': 'Suche',
    'markt': 'Marktanalyse',
    'firmen': 'Firmen',
    'finanzen': 'Finanzen',
    'tech': 'Tech & Tools',
    'recht': 'Recht & Gesetz',
    'trends': 'Trends',
    'akquise': 'B2B & Sales',
  };

  @override
  Widget build(BuildContext context) {
    if (modeCounts.isEmpty) return const SizedBox.shrink();
    final total = modeCounts.values.fold(0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    final entries = modeCounts.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart_rounded, size: 16, color: AppColors.accent),
              const SizedBox(width: 6),
              Text('MODUS-VERTEILUNG',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  )),
              const Spacer(),
              Text('$total Suchen',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  )),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 24,
                    sections: entries.map((e) {
                      final pct = (e.value / total * 100).round();
                      return PieChartSectionData(
                        value: e.value.toDouble(),
                        color: _modeColors[e.key] ?? AppColors.accent,
                        radius: 32,
                        title: pct >= 10 ? '$pct%' : '',
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: entries.take(5).map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _modeColors[e.key] ?? AppColors.accent,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _modeLabels[e.key] ?? e.key,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            '${e.value}',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
