class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String description;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
  });

  factory Expense.fromJson(Map<String, dynamic> j) => Expense(
        id: j['id'] as String,
        title: j['title'] as String,
        amount: (j['amount'] as num).toDouble(),
        category: j['category'] as String,
        date: DateTime.parse(j['date'] as String),
        description: j['description'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'category': category,
        'date': date.toIso8601String(),
        'description': description,
      };

  // format tampilan
  String get formattedAmount => 'Rp ${amount.toStringAsFixed(0)}';
  String get formattedDate => '${date.day}/${date.month}/${date.year}';
}
