/// Danh mục thu/chi — Firestore Document model (Member 2).
class Category {
  final String id;
  final String name;

  /// 'income' | 'expense'
  final String type;
  final int? iconCode;
  final String? colorHex;
  final bool isDefault;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    this.iconCode,
    this.colorHex,
    this.isDefault = false,
  });

  bool get isExpense => type == 'expense';
  bool get isIncome => type == 'income';

  factory Category.fromDocument(String id, Map<String, dynamic> data) {
    return Category(
      id: id,
      name: data['name'] as String? ?? '',
      type: data['type'] as String? ?? 'expense',
      iconCode: (data['iconCode'] as num?)?.toInt(),
      colorHex: data['colorHex'] as String?,
      isDefault: data['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'name': name,
      'type': type,
      'iconCode': iconCode,
      'colorHex': colorHex,
      'isDefault': isDefault,
    };
  }

  Category copyWith({String? name, int? iconCode, String? colorHex}) {
    return Category(
      id: id,
      name: name ?? this.name,
      type: type,
      iconCode: iconCode ?? this.iconCode,
      colorHex: colorHex ?? this.colorHex,
      isDefault: isDefault,
    );
  }
}
