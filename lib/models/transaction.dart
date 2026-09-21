class TransactionModel {
  static const String typeDebit = 'debit';   // عليه
  static const String typeCredit = 'credit'; // له

  final int? id;
  final int accountId;
  final double amount;
  final String type; // 'debit' or 'credit'
  final int currencyId;
  final DateTime date;
  final String? description;
  final String? imagePath;
  final DateTime createdAt;

  TransactionModel({
    this.id,
    required this.accountId,
    required this.amount,
    required this.type,
    required this.currencyId,
    required this.date,
    this.description,
    this.imagePath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isDebit => type == typeDebit;
  bool get isCredit => type == typeCredit;

  TransactionModel copyWith({
    int? id,
    int? accountId,
    double? amount,
    String? type,
    int? currencyId,
    DateTime? date,
    String? description,
    String? imagePath,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      currencyId: currencyId ?? this.currencyId,
      date: date ?? this.date,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'amount': amount,
      'type': type,
      'currency_id': currencyId,
      'date': date.toIso8601String(),
      'description': description,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      accountId: map['account_id'] as int,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      currencyId: map['currency_id'] as int,
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String?,
      imagePath: map['image_path'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }
}
