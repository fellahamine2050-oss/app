import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';

class AddSubscriptionScreen extends StatefulWidget {
  const AddSubscriptionScreen({super.key});

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String _billingCycle = 'monthly';
  String _category = 'entertainment';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;

  final List<Map<String, dynamic>> _categories = [
    {'value': 'entertainment', 'label': 'ترفيه', 'icon': Icons.movie_outlined},
    {'value': 'sport', 'label': 'رياضة', 'icon': Icons.fitness_center},
    {'value': 'work', 'label': 'عمل', 'icon': Icons.work_outline},
    {'value': 'education', 'label': 'تعليم', 'icon': Icons.school_outlined},
    {'value': 'other', 'label': 'أخرى', 'icon': Icons.category_outlined},
  ];

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final subProvider = Provider.of<SubscriptionProvider>(context, listen: false);
      await subProvider.addSubscription({
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'currency': 'EUR',
        'billingCycle': _billingCycle,
        'category': _category,
        'nextBillingDate': _selectedDate.toIso8601String(),
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة اشتراك جديد')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'اسم الاشتراك (مثال: Netflix)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'السعر (€)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('دورة الفوترة', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildCycleChip('monthly', 'شهري'),
                const SizedBox(width: 8),
                _buildCycleChip('yearly', 'سنوي'),
                const SizedBox(width: 8),
                _buildCycleChip('weekly', 'أسبوعي'),
              ],
            ),
            const SizedBox(height: 20),
            const Text('الفئة', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final isSelected = _category == cat['value'];
                return ChoiceChip(
                  label: Text(cat['label']),
                  avatar: Icon(cat['icon'], size: 18),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _category = cat['value']),
                  selectedColor: const Color(0xFF6C5CE7).withOpacity(0.2),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('تاريخ التجديد القادم', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 12),
                    Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('حفظ الاشتراك', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleChip(String value, String label) {
    final isSelected = _billingCycle == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _billingCycle = value),
      selectedColor: const Color(0xFF6C5CE7).withOpacity(0.2),
    );
  }
}
