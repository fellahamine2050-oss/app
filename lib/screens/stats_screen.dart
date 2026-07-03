import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/subscription_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  Map<String, double> _getCategoryTotals(List subscriptions) {
    final Map<String, double> totals = {};
    for (var sub in subscriptions) {
      double monthlyPrice = sub.price;
      if (sub.billingCycle == 'yearly') monthlyPrice = sub.price / 12;
      if (sub.billingCycle == 'weekly') monthlyPrice = sub.price * 4.33;
      totals[sub.category] = (totals[sub.category] ?? 0) + monthlyPrice;
    }
    return totals;
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'entertainment': return const Color(0xFFE74C3C);
      case 'sport': return const Color(0xFF2ECC71);
      case 'work': return const Color(0xFF3498DB);
      case 'education': return const Color(0xFFF39C12);
      default: return const Color(0xFF9B59B6);
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'entertainment': return 'ترفيه';
      case 'sport': return 'رياضة';
      case 'work': return 'عمل';
      case 'education': return 'تعليم';
      default: return 'أخرى';
    }
  }

  @override
  Widget build(BuildContext context) {
    final subProvider = Provider.of<SubscriptionProvider>(context);
    final categoryTotals = _getCategoryTotals(subProvider.subscriptions);

    return Scaffold(
      appBar: AppBar(title: const Text('الإحصائيات')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFF8E7CF1)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text('إجمالي الإنفاق السنوي', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text(
                    '${subProvider.stats['yearlyTotal']}€',
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            if (categoryTotals.isNotEmpty) ...[
              const Text('التوزيع حسب الفئة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: categoryTotals.entries.map((entry) {
                      return PieChartSectionData(
                        value: entry.value,
                        title: '${entry.value.toStringAsFixed(0)}€',
                        color: _getCategoryColor(entry.key),
                        radius: 80,
                        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ...categoryTotals.entries.map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: _getCategoryColor(entry.key),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(_getCategoryLabel(entry.key)),
                        const Spacer(),
                        Text('${entry.value.toStringAsFixed(2)}€/شهر'),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
