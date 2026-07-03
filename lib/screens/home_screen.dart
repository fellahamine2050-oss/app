import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/subscription_card.dart';
import '../widgets/stat_card.dart';
import 'add_subscription_screen.dart';
import 'stats_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SubscriptionProvider>(context, listen: false).loadSubscriptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final subProvider = Provider.of<SubscriptionProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('مرحباً ${authProvider.user?.name ?? ""}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => subProvider.loadSubscriptions(),
        child: subProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      StatCard(
                        title: 'الإنفاق الشهري',
                        value: '${subProvider.stats['monthlyTotal']}€',
                        icon: Icons.calendar_month,
                        color: const Color(0xFF6C5CE7),
                      ),
                      const SizedBox(width: 12),
                      StatCard(
                        title: 'الاشتراكات النشطة',
                        value: '${subProvider.stats['totalSubscriptions']}',
                        icon: Icons.subscriptions,
                        color: const Color(0xFF2ECC71),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'اشتراكاتك',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (subProvider.subscriptions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Column(
                        children: [
                          Icon(Icons.inbox_outlined, size: 60, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد اشتراكات بعد',
                            style: TextStyle(color: Colors.grey[600], fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  else
                    ...subProvider.subscriptions.map((sub) => SubscriptionCard(
                          subscription: sub,
                          onTap: () {},
                          onDelete: () async {
                            await subProvider.deleteSubscription(sub.id);
                          },
                        )),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddSubscriptionScreen()));
          subProvider.loadSubscriptions();
        },
        backgroundColor: const Color(0xFF6C5CE7),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('إضافة اشتراك', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
