class PricingBreakdown {
  final double itemsTotal;
  final double deliveryFee;
  final double platformFee;
  final double membershipDiscount;
  final double finalPayable;
  final double platformCommission;
  final double kitchenNetPayout;

  const PricingBreakdown({
    required this.itemsTotal,
    required this.deliveryFee,
    required this.platformFee,
    required this.membershipDiscount,
    required this.finalPayable,
    required this.platformCommission,
    required this.kitchenNetPayout,
  });
}

class PricingCalculator {
  static const double baseDeliveryRadiusKm = 3.0;
  static const double baseDeliveryFee = 35.0;
  static const double perKmExtraRate = 12.0;
  static const double staticPlatformFee = 10.0;

  static PricingBreakdown compute({
    required double itemsTotal,
    required double distanceInKm,
    required double kitchenCommissionRate, // e.g. 0.20 for 20%
    required bool isPremiumSubscriber,
  }) {
    // 1. Delivery Fee Calculation (Base + Distance Surcharge)
    double calculatedDeliveryFee = baseDeliveryFee;
    if (distanceInKm > baseDeliveryRadiusKm) {
      final double extraDistance = distanceInKm - baseDeliveryRadiusKm;
      calculatedDeliveryFee += (extraDistance * perKmExtraRate);
    }

    // 2. Subscription Membership Benefits (Waives delivery fee)
    double discount = 0.0;
    if (isPremiumSubscriber) {
      discount = calculatedDeliveryFee;
    }

    // 3. Final Order Amount
    final double netDeliveryFee =
        (calculatedDeliveryFee - discount).clamp(0.0, double.infinity);
    final double finalPayable = itemsTotal + netDeliveryFee + staticPlatformFee;

    // 4. Platform Monetization Engine (15-30% Commission from Vendor)
    final double platformCommission = itemsTotal * kitchenCommissionRate;
    final double kitchenNetPayout = itemsTotal - platformCommission;

    return PricingBreakdown(
      itemsTotal: double.parse(itemsTotal.toStringAsFixed(2)),
      deliveryFee: double.parse(calculatedDeliveryFee.toStringAsFixed(2)),
      platformFee: staticPlatformFee,
      membershipDiscount: double.parse(discount.toStringAsFixed(2)),
      finalPayable: double.parse(finalPayable.toStringAsFixed(2)),
      platformCommission:
          double.parse(platformCommission.toStringAsFixed(2)),
      kitchenNetPayout: double.parse(kitchenNetPayout.toStringAsFixed(2)),
    );
  }
}
