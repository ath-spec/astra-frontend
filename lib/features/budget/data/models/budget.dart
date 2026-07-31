class Budget {
  final String name;
  final double amount;

  Budget({
    required this.name,
    required this.amount,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'amount': amount,
      };

  static List<Map<String, dynamic>> listToJson(List<Budget> list) {
    return list.map((b) => b.toJson()).toList();
  }
}
