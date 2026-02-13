import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:retrieval/features/strategy/presentation/providers/strategy_provider.dart';
import 'package:retrieval/features/task/presentation/providers/task_provider.dart';
import '../../data/datasources/review_schedule_local_datasource.dart';
import '../../data/models/review_schedule_model_v2.dart';
import '../../data/repositories/review_schedule_repository_impl.dart';
import '../../domain/entities/review_schedule.dart';
import '../../domain/repositories/review_schedule_repository.dart';
import '../../domain/usecases/complete_review.dart';
import '../../domain/usecases/create_review_schedules.dart';
import '../../domain/usecases/get_today_reviews.dart';

/// Hive Box Provider
final reviewScheduleBoxProvider = Provider<Box<ReviewScheduleModelV2>>((ref) {
  throw UnimplementedError('reviewScheduleBoxProvider must be overridden');
});

/// DataSource Provider
final reviewScheduleLocalDataSourceProvider =
    Provider<ReviewScheduleLocalDataSource>((ref) {
  final box = ref.watch(reviewScheduleBoxProvider);
  return ReviewScheduleLocalDataSourceImpl(box: box);
});

/// Repository Provider
final reviewScheduleRepositoryProvider =
    Provider<ReviewScheduleRepository>((ref) {
  final dataSource = ref.watch(reviewScheduleLocalDataSourceProvider);
  return ReviewScheduleRepositoryImpl(localDataSource: dataSource);
});

/// UseCase Providers
final createNextReviewScheduleUseCaseProvider =
    Provider<CreateNextReviewSchedule>((ref) {
  final repository = ref.watch(reviewScheduleRepositoryProvider);
  return CreateNextReviewSchedule(repository: repository);
});

final getTodayReviewsUseCaseProvider = Provider<GetTodayReviews>((ref) {
  final repository = ref.watch(reviewScheduleRepositoryProvider);
  return GetTodayReviews(repository: repository);
});

final getPendingReviewsUseCaseProvider = Provider<GetPendingReviews>((ref) {
  final repository = ref.watch(reviewScheduleRepositoryProvider);
  return GetPendingReviews(repository: repository);
});

final completeReviewUseCaseProvider = Provider<CompleteReview>((ref) {
  final repository = ref.watch(reviewScheduleRepositoryProvider);
  final taskRepository = ref.watch(taskRepositoryProvider);
  final strategyRepository = ref.watch(strategyRepositoryProvider);
  return CompleteReview(
    repository: repository,
    taskRepository: taskRepository,
    strategyRepository: strategyRepository,
  );
});

final uncompleteReviewUseCaseProvider = Provider<UncompleteReview>((ref) {
  final repository = ref.watch(reviewScheduleRepositoryProvider);
  return UncompleteReview(repository: repository);
});

/// Today's Review List State
class TodayReviewListNotifier
    extends StateNotifier<AsyncValue<List<ReviewSchedule>>> {
  final GetPendingReviews getPendingReviews;
  final CompleteReview completeReview;
  final UncompleteReview uncompleteReview;

  TodayReviewListNotifier({
    required this.getPendingReviews,
    required this.completeReview,
    required this.uncompleteReview,
  }) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final reviews = await getPendingReviews();
      state = AsyncValue.data(reviews);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> complete(String scheduleId) async {
    try {
      await completeReview(scheduleId);
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> uncomplete(String scheduleId) async {
    try {
      await uncompleteReview(scheduleId);
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggle(String scheduleId) async {
    final currentState = state.value;
    if (currentState == null) return;

    final schedule = currentState.where((s) => s.id == scheduleId).firstOrNull;
    if (schedule == null) return;
    if (schedule.isCompleted) {
      await uncomplete(scheduleId);
    } else {
      await complete(scheduleId);
    }
  }
}

final todayReviewListProvider = StateNotifierProvider<TodayReviewListNotifier,
    AsyncValue<List<ReviewSchedule>>>((ref) {
  return TodayReviewListNotifier(
    getPendingReviews: ref.watch(getPendingReviewsUseCaseProvider),
    completeReview: ref.watch(completeReviewUseCaseProvider),
    uncompleteReview: ref.watch(uncompleteReviewUseCaseProvider),
  );
});
