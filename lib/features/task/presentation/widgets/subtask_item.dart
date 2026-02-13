import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/subtask.dart';

/// 서브태스크 아이템 위젯
class SubtaskItem extends StatelessWidget {
  final Subtask subtask;
  final VoidCallback? onTap;

  const SubtaskItem({
    super.key,
    required this.subtask,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = subtask.isCompleted;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.emerald.withValues(alpha: 0.15)
              : AppColors.surfaceVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? AppColors.emerald.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isCompleted
                  ? Icons.check_box_rounded
                  : Icons.square_rounded,
              color: isCompleted ? AppColors.emerald : AppColors.textQuaternary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                subtask.title,
                style: TextStyle(
                  color: isCompleted
                      ? AppColors.emerald.withValues(alpha: 0.7)
                      : AppColors.textPrimary,
                  fontSize: 14,
                  decoration:
                      isCompleted ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.emerald.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
