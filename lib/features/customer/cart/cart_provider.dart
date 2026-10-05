import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/kitchen.dart';
import '../../models/menu_item.dart';
import '../../models/order_model.dart';
import '../../../core/utils/pricing_calculator.dart';

class CartState {
  final Kitchen? kitchen;
  final List<OrderItem> items;

  const CartState({
    this.kitchen,
    this.items = const [],
  });

  double get itemsTotal => items.fold(0.0, (sum, i) => sum + i.totalPrice);
  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  PricingBreakdown calculatePricing(bool isPremiumSubscriber) {
    if (kitchen == null || items.isEmpty) {
      return const PricingBreakdown(
        itemsTotal: 0,
        deliveryFee: 0,
        platformFee: 0,
        membershipDiscount: 0,
        finalPayable: 0,
        platformCommission: 0,
        kitchenNetPayout: 0,
      );
    }

    return PricingCalculator.compute(
      itemsTotal: itemsTotal,
      distanceInKm: kitchen!.distanceKm,
      kitchenCommissionRate: kitchen!.commissionRate,
      isPremiumSubscriber: isPremiumSubscriber,
    );
  }

  CartState copyWith({
    Kitchen? kitchen,
    List<OrderItem>? items,
  }) {
    return CartState(
      kitchen: kitchen ?? this.kitchen,
      items: items ?? this.items,
    );
  }
}

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() => const CartState();

  void addItem({
    required Kitchen kitchen,
    required MenuItem item,
    required List<CustomizationOption> customizations,
  }) {
    // If adding from a different kitchen, reset cart to new kitchen
    if (state.kitchen != null && state.kitchen!.id != kitchen.id) {
      state = CartState(kitchen: kitchen, items: []);
    }

    final existingIndex = state.items.indexWhere((element) =>
        element.item.id == item.id &&
        _areCustomizationsEqual(
            element.selectedCustomizations, customizations));

    if (existingIndex >= 0) {
      final updatedList = [...state.items];
      final current = updatedList[existingIndex];
      updatedList[existingIndex] = OrderItem(
        item: current.item,
        quantity: current.quantity + 1,
        selectedCustomizations: current.selectedCustomizations,
      );
      state = state.copyWith(kitchen: kitchen, items: updatedList);
    } else {
      final newItem = OrderItem(
        item: item,
        quantity: 1,
        selectedCustomizations: customizations,
      );
      state = state.copyWith(
        kitchen: kitchen,
        items: [...state.items, newItem],
      );
    }
  }

  void updateQuantity(int index, int delta) {
    if (index < 0 || index >= state.items.length) return;
    final item = state.items[index];
    final newQty = item.quantity + delta;

    final updated = [...state.items];
    if (newQty <= 0) {
      updated.removeAt(index);
    } else {
      updated[index] = OrderItem(
        item: item.item,
        quantity: newQty,
        selectedCustomizations: item.selectedCustomizations,
      );
    }

    state = CartState(
      kitchen: updated.isEmpty ? null : state.kitchen,
      items: updated,
    );
  }

  void clearCart() {
    state = const CartState();
  }

  bool _areCustomizationsEqual(
      List<CustomizationOption> a, List<CustomizationOption> b) {
    if (a.length != b.length) return false;
    final setA = a.map((e) => e.id).toSet();
    final setB = b.map((e) => e.id).toSet();
    return setA.difference(setB).isEmpty;
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(
  CartNotifier.new,
);
