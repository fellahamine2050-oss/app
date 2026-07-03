import 'package:flutter/foundation.dart';
import '../models/subscription_model.dart';
import '../services/api_service.dart';

class SubscriptionProvider with ChangeNotifier {
  List<Subscription> _subscriptions = [];
  Map<String, dynamic> _stats = {'monthlyTotal': '0', 'yearlyTotal': '0', 'totalSubscriptions': 0};
  bool _isLoading = false;

  List<Subscription> get subscriptions => _subscriptions;
  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;

  Future<void> loadSubscriptions() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiService.getSubscriptions();
      _subscriptions = data.map((json) => Subscription.fromJson(json)).toList();
      await loadStats();
    } catch (e) {
      debugPrint('Error loading subscriptions: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadStats() async {
    try {
      _stats = await ApiService.getStats();
    } catch (e) {
      debugPrint('Error loading stats: $e');
    }
  }

  Future<void> addSubscription(Map<String, dynamic> subscription) async {
    await ApiService.addSubscription(subscription);
    await loadSubscriptions();
  }

  Future<void> deleteSubscription(String id) async {
    await ApiService.deleteSubscription(id);
    await loadSubscriptions();
  }

  List<Subscription> get upcomingSubscriptions {
    final sorted = List<Subscription>.from(_subscriptions);
    sorted.sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
    return sorted.take(3).toList();
  }
}
