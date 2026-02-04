import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../category/presentation/providers/category_provider.dart';
import '../../../statistics/presentation/providers/statistics_provider.dart';
import '../../../statistics/presentation/widgets/completion_donut_chart.dart';
import '../../../study_item/presentation/providers/study_item_provider.dart';
import '../providers/review_provider.dart';
import '../widgets/review_list_item.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(todayReviewListProvider);
    final studyItemsAsync = ref.watch(studyItemListProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final statsAsync = ref.watch(todayStatisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('복습 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder),
            onPressed: () => Navigator.pushNamed(context, '/categories'),
            tooltip: '카테고리 관리',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todayReviewListProvider);
          ref.invalidate(studyItemListProvider);
          ref.invalidate(categoryListProvider);
        },
        child: CustomScrollView(
          slivers: [
            // 통계 섹션
            SliverToBoxAdapter(
              child: statsAsync.when(
                loading: () => const SizedBox(
                  height: 150,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, st) => const SizedBox.shrink(),
                data: (stats) {
                  if (stats.totalReviews == 0) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Text('오늘 복습할 항목이 없습니다.'),
                          ),
                        ),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '오늘의 복습',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CompletionDonutChart(
                                completed: stats.completedReviews,
                                total: stats.totalReviews,
                                title: '전체',
                                size: 100,
                              ),
                            ),
                            ...stats.categoryStats.entries.take(2).map((e) {
                              return Expanded(
                                child: CompletionDonutChart(
                                  completed: e.value.completedReviews,
                                  total: e.value.totalReviews,
                                  title: e.value.categoryName,
                                  size: 100,
                                ),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 복습 목록 헤더
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  '복습 목록',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),

            // 복습 목록
            reviewsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, st) => SliverToBoxAdapter(
                child: Center(child: Text('오류: $e')),
              ),
              data: (reviews) {
                if (reviews.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text('복습 항목이 없습니다.\n새 학습을 기록해보세요.'),
                      ),
                    ),
                  );
                }

                // 학습 항목과 카테고리 정보 가져오기
                final studyItems = studyItemsAsync.value ?? [];
                final categories = categoriesAsync.value ?? [];

                final studyItemMap = {for (var i in studyItems) i.id: i};
                final categoryMap = {for (var c in categories) c.id: c};

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final schedule = reviews[index];
                        final studyItem = studyItemMap[schedule.studyItemId];
                        final category = studyItem != null
                            ? categoryMap[studyItem.categoryId]
                            : null;

                        return ReviewListItem(
                          schedule: schedule,
                          categoryName: category?.name,
                          content: studyItem?.content,
                          isCheckbox: studyItem?.isCheckbox ?? true,
                          onChanged: (_) {
                            ref
                                .read(todayReviewListProvider.notifier)
                                .toggle(schedule.id);
                          },
                        );
                      },
                      childCount: reviews.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add-study'),
        icon: const Icon(Icons.add),
        label: const Text('학습 기록'),
      ),
    );
  }
}
