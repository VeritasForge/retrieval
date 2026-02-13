import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/shell/presentation/pages/shell_page.dart';

class RetrievalApp extends StatelessWidget {
  const RetrievalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Jay's Garden",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const ShellPage(),
    );
  }
}
