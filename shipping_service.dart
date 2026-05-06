
import 'shipping_config.dart';

class ShippingService {
  double calculateFinalShipping({
    required double cartSubtotal,
    required bool isUnlimitedMember,
    double? customMerchantFee,
  }) {
    // 1. Unlimited Mode (Subscription)
    if (isUnlimitedMember) return 0.0;

    // 2. High-Value Thresholds
    if (cartSubtotal >= ShippingConfig.freeShippingThreshold) return 0.0;

    double baseFee = customMerchantFee ?? ShippingConfig.defaultMerchantFee;

    if (cartSubtotal >= ShippingConfig.discountedShippingThreshold) {
      return baseFee * ShippingConfig.discountMultiplier;
    }

    return baseFee;
  }
}
