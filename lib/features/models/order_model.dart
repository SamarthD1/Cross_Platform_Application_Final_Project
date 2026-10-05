import 'package:flutter/material.dart';
import '../../core/utils/pricing_calculator.dart';
import 'menu_item.dart';

enum OrderStatus {
  placed,
  accepted,
  preparing,
  readyForPickup,
  outForDelivery,
  delivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.accepted:
        return 'Accepted by Kitchen';
      case OrderStatus.preparing:
        return 'In Preparation';
      case OrderStatus.readyForPickup:
        return 'Ready for Dispatch';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get statusColor {
    switch (this) {
      case OrderStatus.placed:
        return const Color(0xFF64B5F6);
      case OrderStatus.accepted:
        return const Color(0xFFFFB74D);
      case OrderStatus.preparing:
        return const Color(0xFFFF7043);
      case OrderStatus.readyForPickup:
        return const Color(0xFFBA68C8);
      case OrderStatus.outForDelivery:
        return const Color(0xFF4DD0E1);
      case OrderStatus.delivered:
        return const Color(0xFF81C784);
      case OrderStatus.cancelled:
        return const Color(0xFFE57373);
    }
  }

  int get stepIndex {
    switch (this) {
      case OrderStatus.placed:
        return 0;
      case OrderStatus.accepted:
        return 1;
      case OrderStatus.preparing:
        return 2;
      case OrderStatus.readyForPickup:
        return 3;
      case OrderStatus.outForDelivery:
        return 4;
      case OrderStatus.delivered:
        return 5;
      case OrderStatus.cancelled:
        return -1;
    }
  }
}

class OrderItem {
  final MenuItem item;
  final int quantity;
  final List<CustomizationOption> selectedCustomizations;

  OrderItem({
    required this.item,
    required this.quantity,
    this.selectedCustomizations = const [],
  });

  double get totalPrice {
    final customExtras = selectedCustomizations.fold(
      0.0,
      (sum, opt) => sum + opt.extraPrice,
    );
    return (item.basePrice + customExtras) * quantity;
  }
}

class OrderModel {
  final String id;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final String kitchenId;
  final String kitchenName;
  final List<OrderItem> items;
  final PricingBreakdown pricing;
  OrderStatus status;
  final DateTime createdAt;
  final String paymentMethod;
  String? deliveryPartnerName;
  String? deliveryPartnerPhone;
  int estimatedTimeMinutes;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.kitchenId,
    required this.kitchenName,
    required this.items,
    required this.pricing,
    this.status = OrderStatus.placed,
    required this.createdAt,
    this.paymentMethod = 'UPI (Instant Verification)',
    this.deliveryPartnerName,
    this.deliveryPartnerPhone,
    this.estimatedTimeMinutes = 35,
  });

  OrderModel copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    String? deliveryAddress,
    String? kitchenId,
    String? kitchenName,
    List<OrderItem>? items,
    PricingBreakdown? pricing,
    OrderStatus? status,
    DateTime? createdAt,
    String? paymentMethod,
    String? deliveryPartnerName,
    String? deliveryPartnerPhone,
    int? estimatedTimeMinutes,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      kitchenId: kitchenId ?? this.kitchenId,
      kitchenName: kitchenName ?? this.kitchenName,
      items: items ?? this.items,
      pricing: pricing ?? this.pricing,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      deliveryPartnerName: deliveryPartnerName ?? this.deliveryPartnerName,
      deliveryPartnerPhone: deliveryPartnerPhone ?? this.deliveryPartnerPhone,
      estimatedTimeMinutes: estimatedTimeMinutes ?? this.estimatedTimeMinutes,
    );
  }
}
