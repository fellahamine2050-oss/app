const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Subscription = require('../models/Subscription');

// جلب كل الاشتراكات
router.get('/', auth, async (req, res) => {
  try {
    const subscriptions = await Subscription.find({ userId: req.userId, isActive: true })
      .sort({ nextBillingDate: 1 });
    res.json(subscriptions);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// إضافة اشتراك جديد
router.post('/', auth, async (req, res) => {
  try {
    const subscription = new Subscription({ ...req.body, userId: req.userId });
    await subscription.save();
    res.status(201).json(subscription);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// تعديل اشتراك
router.put('/:id', auth, async (req, res) => {
  try {
    const subscription = await Subscription.findOneAndUpdate(
      { _id: req.params.id, userId: req.userId },
      req.body,
      { new: true }
    );
    res.json(subscription);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// حذف اشتراك
router.delete('/:id', auth, async (req, res) => {
  try {
    await Subscription.findOneAndUpdate(
      { _id: req.params.id, userId: req.userId },
      { isActive: false }
    );
    res.json({ message: 'Subscription deleted' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// إحصائيات (المجموع الشهري/السنوي)
router.get('/stats', auth, async (req, res) => {
  try {
    const subscriptions = await Subscription.find({ userId: req.userId, isActive: true });
    
    let monthlyTotal = 0;
    subscriptions.forEach(sub => {
      if (sub.billingCycle === 'monthly') monthlyTotal += sub.price;
      else if (sub.billingCycle === 'yearly') monthlyTotal += sub.price / 12;
      else if (sub.billingCycle === 'weekly') monthlyTotal += sub.price * 4.33;
    });

    res.json({
      monthlyTotal: monthlyTotal.toFixed(2),
      yearlyTotal: (monthlyTotal * 12).toFixed(2),
      totalSubscriptions: subscriptions.length
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
