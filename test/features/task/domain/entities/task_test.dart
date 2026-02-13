import 'package:flutter_test/flutter_test.dart';
import 'package:retrieval/features/task/domain/entities/subtask.dart';
import 'package:retrieval/features/task/domain/entities/task.dart';

void main() {
  group('Task', () {
    late Task task;

    setUp(() {
      task = Task(
        id: 'task-1',
        categoryId: 'cat-1',
        strategyId: 'strat-1',
        subtasks: const [
          Subtask(id: 'sub-1', title: '문제 1', isCompleted: false),
          Subtask(id: 'sub-2', title: '문제 2', isCompleted: false),
          Subtask(id: 'sub-3', title: '문제 3', isCompleted: false),
        ],
        level: 0,
        history: const [],
        studyDate: DateTime(2024, 1, 15),
        createdAt: DateTime(2024, 1, 15),
      );
    });

    test('toggleSubtask should toggle the correct subtask', () {
      final updated = task.toggleSubtask('sub-2');

      expect(updated.subtasks[0].isCompleted, isFalse);
      expect(updated.subtasks[1].isCompleted, isTrue);
      expect(updated.subtasks[2].isCompleted, isFalse);
    });

    test('toggleSubtask should toggle back a completed subtask', () {
      final toggled = task.toggleSubtask('sub-1');
      final toggledBack = toggled.toggleSubtask('sub-1');

      expect(toggledBack.subtasks[0].isCompleted, isFalse);
    });

    test('resetSubtasks should reset all subtasks to incomplete', () {
      final completed = task
          .toggleSubtask('sub-1')
          .toggleSubtask('sub-2')
          .toggleSubtask('sub-3');

      expect(completed.allSubtasksCompleted, isTrue);

      final reset = completed.resetSubtasks();

      for (final subtask in reset.subtasks) {
        expect(subtask.isCompleted, isFalse);
      }
    });

    test('advanceLevel should increment level and append history', () {
      final now = DateTime(2024, 1, 16);
      final advanced = task.advanceLevel(completedAt: now);

      expect(advanced.level, 1);
      expect(advanced.history.length, 1);
      expect(advanced.history.first, now);
    });

    test('advanceLevel multiple times should accumulate history', () {
      final first = DateTime(2024, 1, 16);
      final second = DateTime(2024, 1, 17);
      final advanced = task
          .advanceLevel(completedAt: first)
          .advanceLevel(completedAt: second);

      expect(advanced.level, 2);
      expect(advanced.history.length, 2);
      expect(advanced.history[0], first);
      expect(advanced.history[1], second);
    });

    test('allSubtasksCompleted should return false when not all completed', () {
      expect(task.allSubtasksCompleted, isFalse);

      final partial = task.toggleSubtask('sub-1').toggleSubtask('sub-2');
      expect(partial.allSubtasksCompleted, isFalse);
    });

    test('allSubtasksCompleted should return true when all completed', () {
      final allDone = task
          .toggleSubtask('sub-1')
          .toggleSubtask('sub-2')
          .toggleSubtask('sub-3');

      expect(allDone.allSubtasksCompleted, isTrue);
    });

    test('allSubtasksCompleted should return false for empty subtasks', () {
      final emptyTask = task.copyWith(subtasks: const []);
      expect(emptyTask.allSubtasksCompleted, isFalse);
    });

    test('equality should work correctly', () {
      final now = DateTime(2024, 1, 15);
      final task1 = Task(
        id: 'task-1',
        categoryId: 'cat-1',
        strategyId: 'strat-1',
        subtasks: const [],
        level: 0,
        history: const [],
        studyDate: now,
        createdAt: now,
      );
      final task2 = Task(
        id: 'task-1',
        categoryId: 'cat-1',
        strategyId: 'strat-1',
        subtasks: const [],
        level: 0,
        history: const [],
        studyDate: now,
        createdAt: now,
      );

      expect(task1, equals(task2));
    });
  });
}
