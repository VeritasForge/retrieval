import 'package:flutter/material.dart';

import 'features/category/presentation/pages/category_page.dart';
import 'features/review/presentation/pages/home_page.dart';
import 'features/study_item/presentation/pages/add_study_item_page.dart';

class RetrievalApp extends StatelessWidget {
  const RetrievalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '복습 관리',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/categories': (context) => const CategoryPage(),
        '/add-study': (context) => const AddStudyItemPage(),
      },
    );
  }
}
