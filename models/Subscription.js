const mongoose = require('mongoose');

const subscriptionSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  name: { type: String, required: true },
  price: { type: Number, required: true },
  currency: { type: String, default: 'EUR' },
  billingCycle: { type: String, enum: ['monthly', 'yearly', 'weekly'], default: 'monthly' },
  category: { type: String, enum: ['entertainment', 'sport', 'work', 'education', 'other'], default: 'other' },
  nextBillingDate: { type: Date, required: true },
  icon: { type: String, default: 'default' },
  isActive: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Subscription', subscriptionSchema);
