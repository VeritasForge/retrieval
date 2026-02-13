import 'dart:ui';

/// 색상 헥스 문자열을 Color로 변환하는 유틸리티
class ColorUtils {
  ColorUtils._();

  /// 6자리 헥스 문자열을 Color로 변환 (e.g., '10B981' -> Color(0xFF10B981))
  static Color fromHex(String hex) {
    final cleanHex = hex.replaceAll('#', '');
    if (cleanHex.length == 6) {
      return Color(int.parse('FF$cleanHex', radix: 16));
    }
    if (cleanHex.length == 8) {
      return Color(int.parse(cleanHex, radix: 16));
    }
    return const Color(0xFF6366F1); // fallback indigo
  }
}
