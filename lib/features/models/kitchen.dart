class Kitchen {
  final String id;
  final String name;
  final String brandTagline;
  final List<String> cuisines;
  final double rating;
  final int totalReviews;
  final int averagePrepTimeMinutes;
  int maxOrderCapacity;
  int activeOrdersCount;
  bool isAcceptingOrders;
  bool isSponsored;
  double commissionRate; // e.g. 0.20 for 20%
  final double distanceKm;
  final String address;
  final String imageUrl;

  Kitchen({
    required this.id,
    required this.name,
    required this.brandTagline,
    required this.cuisines,
    required this.rating,
    required this.totalReviews,
    required this.averagePrepTimeMinutes,
    this.maxOrderCapacity = 10,
    this.activeOrdersCount = 0,
    this.isAcceptingOrders = true,
    this.isSponsored = false,
    this.commissionRate = 0.20,
    required this.distanceKm,
    required this.address,
    required this.imageUrl,
  });

  bool get isAtCapacity => activeOrdersCount >= maxOrderCapacity;

  double get capacityPercentage =>
      maxOrderCapacity > 0 ? (activeOrdersCount / maxOrderCapacity).clamp(0.0, 1.0) : 1.0;

  int calculateEstimatedDeliveryMinutes() {
    // Delivery time = prep time + transit (approx 3 min/km) + delay if capacity > 70%
    final transitTime = (distanceKm * 3.0).ceil();
    final delay = capacityPercentage > 0.7 ? 8 : 0;
    return averagePrepTimeMinutes + transitTime + delay;
  }

  Kitchen copyWith({
    String? id,
    String? name,
    String? brandTagline,
    List<String>? cuisines,
    double? rating,
    int? totalReviews,
    int? averagePrepTimeMinutes,
    int? maxOrderCapacity,
    int? activeOrdersCount,
    bool? isAcceptingOrders,
    bool? isSponsored,
    double? commissionRate,
    double? distanceKm,
    String? address,
    String? imageUrl,
  }) {
    return Kitchen(
      id: id ?? this.id,
      name: name ?? this.name,
      brandTagline: brandTagline ?? this.brandTagline,
      cuisines: cuisines ?? this.cuisines,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      averagePrepTimeMinutes:
          averagePrepTimeMinutes ?? this.averagePrepTimeMinutes,
      maxOrderCapacity: maxOrderCapacity ?? this.maxOrderCapacity,
      activeOrdersCount: activeOrdersCount ?? this.activeOrdersCount,
      isAcceptingOrders: isAcceptingOrders ?? this.isAcceptingOrders,
      isSponsored: isSponsored ?? this.isSponsored,
      commissionRate: commissionRate ?? this.commissionRate,
      distanceKm: distanceKm ?? this.distanceKm,
      address: address ?? this.address,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
