import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/icon_utils.dart';
import '../../../category/domain/entities/category.dart';
import '../../../strategy/domain/entities/strategy.dart';
import '../../domain/entities/task.dart';
import 'subtask_item.dart';

/// 태스크 카드 위젯
class TaskCard extends StatelessWidget {
  final Task task;
  final Category? category;
  final Strategy? strategy;
  final DateTime? scheduledDate;
  final void Function(String subtaskId)? onToggleSubtask;
  final VoidCallback? onComplete;

  const TaskCard({
    super.key,
    required this.task,
    this.category,
    this.strategy,
    this.scheduledDate,
    this.onToggleSubtask,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final allDone = task.allSubtasksCompleted && task.subtasks.isNotEmpty;
    final completedCount = task.subtasks.where((s) => s.isCompleted).length;
    final totalCount = task.subtasks.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    final progressPercent = (progress * 100).round();

    final categoryColor = category != null
        ? ColorUtils.fromHex(category!.colorHex)
        : AppColors.textQuaternary;

    final studyDateStr = DateFormat('MM.dd').format(task.studyDate);
    final categoryName = category?.name ?? '미분류';
    final displayTitle = '$categoryName · $studyDateStr';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: allDone
              ? AppColors.emerald.withValues(alpha: 0.5)
              : AppColors.surfaceVariant,
          width: allDone ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top badges row
            Row(
              children: [
                // Category badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: categoryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category != null
                            ? IconUtils.getIcon(category!.iconName)
                            : Icons.help_outline,
                        size: 14,
                        color: categoryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category?.name ?? '미분류',
                        style: TextStyle(
                          color: categoryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Strategy badge
                if (strategy != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      _buildStrategyLabel(strategy!, task),
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Title: category + study date
            Text(
              displayTitle,
              style: TextStyle(
                color: allDone ? AppColors.emerald : AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Review schedule dates
            if (strategy != null) ...[
              const SizedBox(height: 8),
              _buildScheduleDates(strategy!, task, categoryColor),
            ] else if (scheduledDate != null) ...[
              const SizedBox(height: 8),
              _buildSingleDateChip(scheduledDate!, categoryColor),
            ],

            // Subtask list
            if (task.subtasks.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...task.subtasks.map((subtask) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SubtaskItem(
                      subtask: subtask,
                      onTap: onToggleSubtask != null
                          ? () => onToggleSubtask!(subtask.id)
                          : null,
                    ),
                  )),
            ],

            const SizedBox(height: 16),

            // Progress / Complete button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: allDone
                  ? _CompleteButton(onTap: onComplete)
                  : _ProgressButton(percent: progressPercent),
            ),
          ],
        ),
      ),
    );
  }

  String _buildStrategyLabel(Strategy strategy, Task task) {
    if (task.level + 1 < strategy.intervals.length) {
      final nextDays = strategy.intervals[task.level + 1];
      final nextDate = AppDateUtils.addDays(task.studyDate, nextDays);
      final dateStr = DateFormat('MM.dd').format(nextDate);
      return '${strategy.name} · 다음 복습 $nextDays일 후 ($dateStr)';
    }
    return '${strategy.name} · 최종 복습';
  }

  Widget _buildSingleDateChip(DateTime date, Color categoryColor) {
    final dateStr = DateFormat('MM.dd').format(date);
    return Wrap(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: categoryColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: categoryColor.withValues(alpha: 0.4)),
          ),
          child: Text(
            dateStr,
            style: TextStyle(
              color: categoryColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleDates(
      Strategy strategy, Task task, Color categoryColor) {
    // Show remaining review dates from current level onward
    final dates = <_ScheduleDate>[];
    for (var i = 0; i < strategy.intervals.length; i++) {
      final date = AppDateUtils.addDays(task.studyDate, strategy.intervals[i]);
      dates.add(_ScheduleDate(
        date: date,
        isCurrent: i == task.level,
        isPast: i < task.level,
      ));
    }

    // Only show dates from current level onward
    final relevantDates = dates.where((d) => !d.isPast).toList();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: relevantDates.map((sd) {
        final dateStr = DateFormat('MM.dd').format(sd.date);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: sd.isCurrent
                ? categoryColor.withValues(alpha: 0.15)
                : AppColors.surfaceVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: sd.isCurrent
                ? Border.all(color: categoryColor.withValues(alpha: 0.4))
                : null,
          ),
          child: Text(
            dateStr,
            style: TextStyle(
              color: sd.isCurrent ? categoryColor : AppColors.textQuaternary,
              fontSize: 11,
              fontWeight: sd.isCurrent ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ScheduleDate {
  final DateTime date;
  final bool isCurrent;
  final bool isPast;

  const _ScheduleDate({
    required this.date,
    required this.isCurrent,
    required this.isPast,
  });
}

class _CompleteButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _CompleteButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.emerald, Color(0xFF14B8A6)],
          ),
          borderRadius: BorderRadius.circular(32),
        ),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'COMPLETE & GROW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressButton extends StatelessWidget {
  final int percent;

  const _ProgressButton({required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Center(
        child: Text(
          'PROGRESS: $percent%',
          style: const TextStyle(
            color: AppColors.textQuaternary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
