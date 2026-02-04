import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:retrieval/core/utils/date_utils.dart';
import '../../domain/entities/review_schedule.dart';

class ReviewListItem extends StatelessWidget {
  final ReviewSchedule schedule;
  final String? categoryName;
  final String? content;
  final bool isCheckbox;
  final ValueChanged<bool?>? onChanged;

  const ReviewListItem({
    super.key,
    required this.schedule,
    this.categoryName,
    this.content,
    this.isCheckbox = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = AppDateUtils.isPast(schedule.scheduledDate);

    return Card(
      color: isOverdue && !schedule.isCompleted
          ? Colors.red.shade50
          : null,
      child: ListTile(
        leading: isCheckbox
            ? Checkbox(
                value: schedule.isCompleted,
                onChanged: onChanged,
              )
            : Icon(
                schedule.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                color: schedule.isCompleted ? Colors.green : Colors.grey,
              ),
        title: Text(
          content ?? '학습 항목',
          style: schedule.isCompleted
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (categoryName != null)
              Text(categoryName!, style: const TextStyle(fontSize: 12)),
            Row(
              children: [
                Text(
                  '${schedule.reviewOrder}차 복습',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 8),
                if (isOverdue && !schedule.isCompleted)
                  Text(
                    '${AppDateUtils.daysBetween(schedule.scheduledDate, DateTime.now())}일 지남',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: Text(
          DateFormat('MM/dd').format(schedule.scheduledDate),
          style: TextStyle(
            color: isOverdue && !schedule.isCompleted ? Colors.red : null,
          ),
        ),
        onTap: isCheckbox ? null : () => onChanged?.call(!schedule.isCompleted),
      ),
    );
  }
}
