import 'package:equatable/equatable.dart';

enum TransactionType {
  spent,
  received;

  static TransactionType fromString(String val) {
    if (val.toLowerCase() == 'received' || val.toLowerCase() == 'income') {
      return TransactionType.received;
    }
    return TransactionType.spent;
  }
}

class Transaction extends Equatable {
  final String id;
  final double amount;
  final TransactionType type;
  final String category;
  final String currency;
  final String? note;
  final DateTime date;

  const Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    this.currency = 'USD',
    this.note,
    required this.date,
  });

  bool get isIncome => type == TransactionType.received;
  bool get isExpense => type == TransactionType.spent;

  Transaction copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    String? category,
    String? currency,
    String? note,
    DateTime? date,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      currency: currency ?? this.currency,
      note: note ?? this.note,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type.name,
      'category': category,
      'currency': currency,
      'note': note,
      'date': date.toIso8601String(),
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: TransactionType.fromString(json['type'] as String? ?? 'spent'),
      category: json['category'] as String? ?? 'General',
      currency: json['currency'] as String? ?? 'USD',
      note: json['note'] as String?,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'] as String) ?? DateTime.now()
          : (json['timestamp'] != null
              ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int)
              : DateTime.now()),
    );
  }

  @override
  List<Object?> get props => [id, amount, type, category, currency, note, date];
}
