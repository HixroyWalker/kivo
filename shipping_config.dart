
class ShippingConfig {
  // Subscription Settings
  static const double monthlySubscriptionFee = 9.99; 
  
  // Tiered Shipping Rules
  static const double freeShippingThreshold = 150.0; 
  static const double discountedShippingThreshold = 100.0; 
  static const double discountMultiplier = 0.5; // 50% off
  
  // Default Merchant Fee if no rules apply
  static const double defaultMerchantFee = 5.99;
}
