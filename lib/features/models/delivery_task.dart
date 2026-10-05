enum DeliveryStage {
  available,
  assigned,
  enRouteToKitchen,
  atKitchen,
  outForDelivery,
  delivered,
}

extension DeliveryStageExtension on DeliveryStage {
  String get label {
    switch (this) {
      case DeliveryStage.available:
        return 'Available for Pickup';
      case DeliveryStage.assigned:
        return 'Trip Accepted';
      case DeliveryStage.enRouteToKitchen:
        return 'En Route to Kitchen';
      case DeliveryStage.atKitchen:
        return 'Arrived at Kitchen';
      case DeliveryStage.outForDelivery:
        return 'On the Way to Customer';
      case DeliveryStage.delivered:
        return 'Order Delivered';
    }
  }
}

class DeliveryTask {
  final String id;
  final String orderId;
  final String kitchenName;
  final String kitchenAddress;
  final String dropAddress;
  final double distanceKm;
  final double riderPayout;
  DeliveryStage stage;
  String? riderId;
  String? riderName;

  DeliveryTask({
    required this.id,
    required this.orderId,
    required this.kitchenName,
    required this.kitchenAddress,
    required this.dropAddress,
    required this.distanceKm,
    required this.riderPayout,
    this.stage = DeliveryStage.available,
    this.riderId,
    this.riderName,
  });

  DeliveryTask copyWith({
    String? id,
    String? orderId,
    String? kitchenName,
    String? kitchenAddress,
    String? dropAddress,
    double? distanceKm,
    double? riderPayout,
    DeliveryStage? stage,
    String? riderId,
    String? riderName,
  }) {
    return DeliveryTask(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      kitchenName: kitchenName ?? this.kitchenName,
      kitchenAddress: kitchenAddress ?? this.kitchenAddress,
      dropAddress: dropAddress ?? this.dropAddress,
      distanceKm: distanceKm ?? this.distanceKm,
      riderPayout: riderPayout ?? this.riderPayout,
      stage: stage ?? this.stage,
      riderId: riderId ?? this.riderId,
      riderName: riderName ?? this.riderName,
    );
  }
}
