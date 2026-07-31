// lib/models/spend.dart
class Spend {
  final String name;
  final double amount;

  Spend({required this.name, required this.amount});

  factory Spend.fromJson(Map<String, dynamic> json) => Spend(
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'amount': amount,
      };
}
