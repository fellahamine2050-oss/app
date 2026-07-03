import 'package:flutter/material.dart';
import '../models/subscription_model.dart';

class SubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    required this.onDelete,
    required this.onTap,
  });

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'entertainment': return const Color(0xFFE74C3C);
      case 'sport': return const Color(0xFF2ECC71);
      case 'work': return const Color(0xFF3498DB);
      case 'education': return const Color(0xFFF39C12);
      default: return const Color(0xFF9B59B6);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'entertainment': return Icons.movie_outlined;
      case 'sport': return Icons.fitness_center;
      case 'work': return Icons.work_outline;
      case 'education': return Icons.school_outlined;
      default: return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = subscription.daysUntilBilling;
    final isUrgent = daysLeft <= 3;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getCategoryColor(subscription.category).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(subscription.category),
                  color: _getCategoryColor(subscription.category),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isUrgent ? 'يتجدد خلال $daysLeft أيام' : 'يتجدد خلال $daysLeft يوم',
                      style: TextStyle(
                        fontSize: 13,
                        color: isUrgent ? Colors.red : Colors.grey[600],
                        fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${subscription.price.toStringAsFixed(2)}€',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subscription.billingCycle == 'monthly' ? '/شهر' : 
                    subscription.billingCycle == 'yearly' ? '/سنة' : '/أسبوع',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
