import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CompletionDonutChart extends StatelessWidget {
  final int completed;
  final int total;
  final String? title;
  final double size;

  const CompletionDonutChart({
    super.key,
    required this.completed,
    required this.total,
    this.title,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final pending = total - completed;
    final rate = total > 0 ? (completed / total * 100).round() : 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title!,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: size * 0.3,
                  sections: [
                    PieChartSectionData(
                      value: completed.toDouble(),
                      color: Colors.green,
                      title: '',
                      radius: size * 0.2,
                    ),
                    PieChartSectionData(
                      value: pending.toDouble(),
                      color: Colors.grey.shade300,
                      title: '',
                      radius: size * 0.2,
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$rate%',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '$completed/$total',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
