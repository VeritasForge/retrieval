/// 기본 카테고리 정의
class DefaultCategory {
  final String name;
  final String iconName;
  final String colorHex;

  const DefaultCategory({
    required this.name,
    required this.iconName,
    required this.colorHex,
  });

  static const List<DefaultCategory> defaults = [
    DefaultCategory(name: '독서', iconName: 'menu_book', colorHex: '10B981'),
    DefaultCategory(name: '알고리즘', iconName: 'code', colorHex: '6366F1'),
    DefaultCategory(name: '강의', iconName: 'school', colorHex: 'F59E0B'),
    DefaultCategory(name: '메모', iconName: 'description', colorHex: 'F43F5E'),
  ];
}
