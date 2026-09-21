class RecurringTransaction {
  static const String freqDaily = 'daily';
  static const String freqWeekly = 'weekly';
  static const String freqMonthly = 'monthly';

  final int? id;
  final int accountId;
  final double amount;
  final String type;
  final int currencyId;
  final String? description;
  final String frequency;
  final DateTime startDate;
  final DateTime nextExecutionDate;
  final bool isActive;
  final DateTime createdAt;

  RecurringTransaction({
    this.id,
    required this.accountId,
    required this.amount,
    required this.type,
    required this.currencyId,
    this.description,
    required this.frequency,
    required this.startDate,
    required this.nextExecutionDate,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  RecurringTransaction copyWith({
    int? id,
    int? accountId,
    double? amount,
    String? type,
    int? currencyId,
    String? description,
    String? frequency,
    DateTime? startDate,
    DateTime? nextExecutionDate,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      currencyId: currencyId ?? this.currencyId,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      nextExecutionDate: nextExecutionDate ?? this.nextExecutionDate,
      isActive: isActive ?? this.isActive,
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
      'description': description,
      'frequency': frequency,
      'start_date': startDate.toIso8601String(),
      'next_execution_date': nextExecutionDate.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory RecurringTransaction.fromMap(Map<String, dynamic> map) {
    return RecurringTransaction(
      id: map['id'] as int?,
      accountId: map['account_id'] as int,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      currencyId: map['currency_id'] as int,
      description: map['description'] as String?,
      frequency: map['frequency'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      nextExecutionDate: DateTime.parse(map['next_execution_date'] as String),
      isActive: (map['is_active'] as int? ?? 1) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }
}
