class Subscription {
  final String id;
  final String name;
  final double price;
  final String currency;
  final String billingCycle;
  final String category;
  final DateTime nextBillingDate;
  final String icon;

  Subscription({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.billingCycle,
    required this.category,
    required this.nextBillingDate,
    required this.icon,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['_id'],
      name: json['name'],
      price: json['price'].toDouble(),
      currency: json['currency'] ?? 'EUR',
      billingCycle: json['billingCycle'],
      category: json['category'],
      nextBillingDate: DateTime.parse(json['nextBillingDate']),
      icon: json['icon'] ?? 'default',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'currency': currency,
      'billingCycle': billingCycle,
      'category': category,
      'nextBillingDate': nextBillingDate.toIso8601String(),
      'icon': icon,
    };
  }

  int get daysUntilBilling {
    return nextBillingDate.difference(DateTime.now()).inDays;
  }
}
