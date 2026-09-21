class Currency {
  final int? id;
  final String name;
  final String symbol;
  final bool isDefault;
  final DateTime createdAt;

  Currency({
    this.id,
    required this.name,
    required this.symbol,
    this.isDefault = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Currency copyWith({
    int? id,
    String? name,
    String? symbol,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return Currency(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'is_default': isDefault ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Currency.fromMap(Map<String, dynamic> map) {
    return Currency(
      id: map['id'] as int?,
      name: map['name'] as String,
      symbol: map['symbol'] as String,
      isDefault: (map['is_default'] as int? ?? 0) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }
}
