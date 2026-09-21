class Account {
  final int? id;
  final String name;
  final int? categoryId;
  final int? currencyId;
  final String? phone;
  final String? notes;
  final String? iconCode;
  final double initialBalance;
  final double currentBalance;
  final DateTime createdAt;
  final DateTime updatedAt;

  Account({
    this.id,
    required this.name,
    this.categoryId,
    this.currencyId,
    this.phone,
    this.notes,
    this.iconCode,
    this.initialBalance = 0.0,
    this.currentBalance = 0.0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Account copyWith({
    int? id,
    String? name,
    int? categoryId,
    int? currencyId,
    String? phone,
    String? notes,
    String? iconCode,
    double? initialBalance,
    double? currentBalance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      currencyId: currencyId ?? this.currencyId,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      iconCode: iconCode ?? this.iconCode,
      initialBalance: initialBalance ?? this.initialBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category_id': categoryId,
      'currency_id': currencyId,
      'phone': phone,
      'notes': notes,
      'icon_code': iconCode,
      'initial_balance': initialBalance,
      'current_balance': currentBalance,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as int?,
      name: map['name'] as String,
      categoryId: map['category_id'] as int?,
      currencyId: map['currency_id'] as int?,
      phone: map['phone'] as String?,
      notes: map['notes'] as String?,
      iconCode: map['icon_code'] as String?,
      initialBalance: (map['initial_balance'] as num?)?.toDouble() ?? 0.0,
      currentBalance: (map['current_balance'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.now(),
    );
  }
}
