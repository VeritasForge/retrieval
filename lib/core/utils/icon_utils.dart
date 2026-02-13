import 'package:flutter/material.dart';

/// 아이콘 이름 문자열을 IconData로 변환하는 유틸리티
class IconUtils {
  IconUtils._();

  static const Map<String, IconData> _iconMap = {
    'menu_book': Icons.menu_book,
    'code': Icons.code,
    'school': Icons.school,
    'description': Icons.description,
    'science': Icons.science,
    'language': Icons.language,
    'brush': Icons.brush,
    'music_note': Icons.music_note,
    'fitness_center': Icons.fitness_center,
    'calculate': Icons.calculate,
    'psychology': Icons.psychology,
    'work': Icons.work,
    'favorite': Icons.favorite,
    'star': Icons.star,
    'lightbulb': Icons.lightbulb,
  };

  /// 아이콘 이름으로 IconData 조회 (없으면 기본 아이콘 반환)
  static IconData getIcon(String iconName) {
    return _iconMap[iconName] ?? Icons.category;
  }

  /// 사용 가능한 모든 아이콘 이름 목록
  static List<String> get availableIcons => _iconMap.keys.toList();
}
