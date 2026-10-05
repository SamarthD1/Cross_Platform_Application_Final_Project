import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kitchen.dart';
import '../models/menu_item.dart';
import '../models/order_model.dart';
import '../models/delivery_task.dart';
import '../auth/domain/user_role.dart';
import '../../core/utils/pricing_calculator.dart';

// User State (Role + Subscription)
class UserSessionState {
  final UserRole activeRole;
  final bool isPremiumMember;
  final String userName;
  final String userAddress;

  const UserSessionState({
    this.activeRole = UserRole.customer,
    this.isPremiumMember = true,
    this.userName = 'Samarth Devadiga',
    this.userAddress = '14th Main Rd, Indiranagar, Bengaluru',
  });

  UserSessionState copyWith({
    UserRole? activeRole,
    bool? isPremiumMember,
    String? userName,
    String? userAddress,
  }) {
    return UserSessionState(
      activeRole: activeRole ?? this.activeRole,
      isPremiumMember: isPremiumMember ?? this.isPremiumMember,
      userName: userName ?? this.userName,
      userAddress: userAddress ?? this.userAddress,
    );
  }
}

class UserSessionNotifier extends Notifier<UserSessionState> {
  @override
  UserSessionState build() => const UserSessionState();

  void setRole(UserRole role) {
    state = state.copyWith(activeRole: role);
  }

  void toggleSubscription() {
    state = state.copyWith(isPremiumMember: !state.isPremiumMember);
  }
}

final userSessionProvider =
    NotifierProvider<UserSessionNotifier, UserSessionState>(
  UserSessionNotifier.new,
);

// App Central State
class PlatformState {
  final List<Kitchen> kitchens;
  final List<MenuItem> menuItems;
  final List<OrderModel> orders;
  final List<DeliveryTask> deliveryTasks;

  const PlatformState({
    required this.kitchens,
    required this.menuItems,
    required this.orders,
    required this.deliveryTasks,
  });

  PlatformState copyWith({
    List<Kitchen>? kitchens,
    List<MenuItem>? menuItems,
    List<OrderModel>? orders,
    List<DeliveryTask>? deliveryTasks,
  }) {
    return PlatformState(
      kitchens: kitchens ?? this.kitchens,
      menuItems: menuItems ?? this.menuItems,
      orders: orders ?? this.orders,
      deliveryTasks: deliveryTasks ?? this.deliveryTasks,
    );
  }
}

class PlatformNotifier extends Notifier<PlatformState> {
  @override
  PlatformState build() {
    return _initialData();
  }

  static PlatformState _initialData() {
    // 1. Kitchen Outlets (6 Hubs across Bengaluru)
    final k1 = Kitchen(
      id: 'k1',
      name: 'Nawabi Dum Cloud Kitchen',
      brandTagline: 'Authentic Charcoal & Handi Biryanis',
      cuisines: ['Biryani', 'Mughlai', 'Kebabs'],
      rating: 4.8,
      totalReviews: 840,
      averagePrepTimeMinutes: 18,
      maxOrderCapacity: 12,
      activeOrdersCount: 4,
      isAcceptingOrders: true,
      isSponsored: true,
      commissionRate: 0.20, // 20%
      distanceKm: 2.4,
      address: 'Hub 04, 100 Feet Rd, Indiranagar',
      imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=600',
    );

    final k2 = Kitchen(
      id: 'k2',
      name: 'Bowl & Green Healthy Kitchen',
      brandTagline: 'Micro-greens, Warm Protein Bowls & Smoothies',
      cuisines: ['Healthy', 'Salads', 'Continental'],
      rating: 4.6,
      totalReviews: 512,
      averagePrepTimeMinutes: 14,
      maxOrderCapacity: 8,
      activeOrdersCount: 7, // Near capacity!
      isAcceptingOrders: true,
      isSponsored: false,
      commissionRate: 0.18, // 18%
      distanceKm: 4.1,
      address: 'Kitchen Pod B, Koramangala 5th Block',
      imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600',
    );

    final k3 = Kitchen(
      id: 'k3',
      name: 'Wok Samurai Express',
      brandTagline: 'Live Stir Fry Noodles & Dimsums',
      cuisines: ['Pan-Asian', 'Chinese', 'Thai'],
      rating: 4.5,
      totalReviews: 430,
      averagePrepTimeMinutes: 16,
      maxOrderCapacity: 10,
      activeOrdersCount: 3,
      isAcceptingOrders: true,
      isSponsored: true,
      commissionRate: 0.25, // 25%
      distanceKm: 3.5,
      address: 'Cloud Kitchen Complex, HSR Layout Sector 2',
      imageUrl: 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=600',
    );

    final k4 = Kitchen(
      id: 'k4',
      name: 'Madras Tiffin & Dosa Pod',
      brandTagline: 'Crispy Ghee Podi Dosas & Degree Filter Coffee',
      cuisines: ['South Indian', 'Breakfast', 'Fast Food'],
      rating: 4.7,
      totalReviews: 960,
      averagePrepTimeMinutes: 10,
      maxOrderCapacity: 15,
      activeOrdersCount: 5,
      isAcceptingOrders: true,
      isSponsored: true,
      commissionRate: 0.15, // 15%
      distanceKm: 1.8,
      address: 'Express Pod 12, 9th Main, Jayanagar',
      imageUrl: 'https://images.unsplash.com/photo-1610192244261-3f33de3f55e4?w=600',
    );

    final k5 = Kitchen(
      id: 'k5',
      name: 'The Italian Oven Cloud Lab',
      brandTagline: 'Artisanal Sourdough Pizzas & Handcrafted Pastas',
      cuisines: ['Italian', 'Continental', 'Pizza'],
      rating: 4.9,
      totalReviews: 680,
      averagePrepTimeMinutes: 22,
      maxOrderCapacity: 10,
      activeOrdersCount: 2,
      isAcceptingOrders: true,
      isSponsored: false,
      commissionRate: 0.22, // 22%
      distanceKm: 3.8,
      address: 'Kitchen Loft 3, Inner Ring Rd, Domlur',
      imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600',
    );

    final k6 = Kitchen(
      id: 'k6',
      name: 'Roll Nation & Late Night Munchies',
      brandTagline: 'Flaky Laccha Paratha Rolls & Thick Shakes',
      cuisines: ['Rolls', 'Fast Food', 'Beverages'],
      rating: 4.3,
      totalReviews: 390,
      averagePrepTimeMinutes: 12,
      maxOrderCapacity: 12,
      activeOrdersCount: 6,
      isAcceptingOrders: true,
      isSponsored: false,
      commissionRate: 0.20, // 20%
      distanceKm: 2.9,
      address: 'Hub Pod 07, 80 Feet Rd, Koramangala',
      imageUrl: 'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?w=600',
    );

    // 2. Menu Items (16 Items with rich variations)
    // k1 Items
    final m1 = MenuItem(
      id: 'm1',
      kitchenId: 'k1',
      name: 'Royal Lucknowi Mutton Biryani',
      description: 'Slow-cooked tender cuts with saffron basmati rice & burani raita.',
      category: 'Biryani',
      basePrice: 420.0,
      preparationTimeMinutes: 20,
      imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=600',
      customizationGroups: [
        CustomizationGroup(
          id: 'cg1',
          title: 'Portion Size',
          isRequired: true,
          options: [
            CustomizationOption(id: 'c1', name: 'Regular (Serves 1)', extraPrice: 0),
            CustomizationOption(id: 'c2', name: 'Jumbo Handi (Serves 2-3)', extraPrice: 280),
          ],
        ),
        CustomizationGroup(
          id: 'cg2',
          title: 'Extra Add-ons',
          options: [
            CustomizationOption(id: 'c3', name: 'Boiled Egg (2 Pcs)', extraPrice: 35),
            CustomizationOption(id: 'c4', name: 'Extra Salan & Raita', extraPrice: 45),
          ],
        ),
      ],
    );

    final m2 = MenuItem(
      id: 'm1_2',
      kitchenId: 'k1',
      name: 'Galouti Kebab with Ulta Tawa Paratha',
      description: 'Melt-in-mouth smoked lamb patties served with mint chutney.',
      category: 'Starters',
      basePrice: 340.0,
      preparationTimeMinutes: 15,
      imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600',
    );

    final m1_3 = MenuItem(
      id: 'm1_3',
      kitchenId: 'k1',
      name: 'Shahi Murgh Dum Biryani',
      description: 'Fragrant chicken marinated overnight in roasted spices and curd.',
      category: 'Biryani',
      basePrice: 310.0,
      preparationTimeMinutes: 18,
      imageUrl: 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=600',
    );

    // k2 Items
    final m3 = MenuItem(
      id: 'm2_1',
      kitchenId: 'k2',
      name: 'Grilled Herb Chicken Harvest Bowl',
      description: 'Quinoa, avocado, roasted peppers, edamame with lemon tahini vinaigrette.',
      category: 'Bowls',
      basePrice: 360.0,
      preparationTimeMinutes: 12,
      imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600',
    );

    final m2_2 = MenuItem(
      id: 'm2_2',
      kitchenId: 'k2',
      name: 'Mediterranean Falafel & Hummus Bowl',
      description: 'Crispy herb falafels, beetroot hummus, pickled cucumber & toasted seeds.',
      category: 'Bowls',
      basePrice: 280.0,
      preparationTimeMinutes: 10,
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600',
    );

    final m2_3 = MenuItem(
      id: 'm2_3',
      kitchenId: 'k2',
      name: 'Cold-Pressed Green Detox Smoothie',
      description: 'Baby spinach, green apple, cucumber, chia seeds & coconut water.',
      category: 'Beverages',
      basePrice: 180.0,
      preparationTimeMinutes: 6,
      imageUrl: 'https://images.unsplash.com/photo-1610970881699-44a5587cabec?w=600',
    );

    // k3 Items
    final m4 = MenuItem(
      id: 'm3_1',
      kitchenId: 'k3',
      name: 'Szechuan Chili Garlic Hakka Noodles',
      description: 'Wok tossed hand-pulled noodles with crisp veggies and scallions.',
      category: 'Noodles',
      basePrice: 260.0,
      preparationTimeMinutes: 14,
      imageUrl: 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=600',
    );

    final m3_2 = MenuItem(
      id: 'm3_2',
      kitchenId: 'k3',
      name: 'Steamed Edamame & Truffle Dimsums (6 Pcs)',
      description: 'Translucent crystal pouches infused with white truffle oil & chili dip.',
      category: 'Dimsums',
      basePrice: 320.0,
      preparationTimeMinutes: 15,
      imageUrl: 'https://images.unsplash.com/photo-1496116218417-1a781b1c416c?w=600',
    );

    final m3_3 = MenuItem(
      id: 'm3_3',
      kitchenId: 'k3',
      name: 'Thai Basil Crispy Chicken Rice Bowl',
      description: 'Wok glazed chicken with fiery bird\'s eye chili and fragrant jasmine rice.',
      category: 'Bowls',
      basePrice: 340.0,
      preparationTimeMinutes: 16,
      imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=600',
    );

    // k4 Items (South Indian)
    final m4_1 = MenuItem(
      id: 'm4_1',
      kitchenId: 'k4',
      name: 'Ghee Podi Mysore Masala Dosa',
      description: 'Golden fermented rice crepe brushed with spiced gun powder & potato masala.',
      category: 'Dosas',
      basePrice: 160.0,
      preparationTimeMinutes: 8,
      imageUrl: 'https://images.unsplash.com/photo-1610192244261-3f33de3f55e4?w=600',
    );

    final m4_2 = MenuItem(
      id: 'm4_2',
      kitchenId: 'k4',
      name: 'Crispy Button Idlis (14 Pcs) with Sambar Dip',
      description: 'Mini steamed rice cakes tempered with mustard seeds & curry leaves.',
      category: 'Tiffins',
      basePrice: 120.0,
      preparationTimeMinutes: 6,
      imageUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=600',
    );

    final m4_3 = MenuItem(
      id: 'm4_3',
      kitchenId: 'k4',
      name: 'Traditional Kumbakonam Degree Filter Coffee',
      description: 'Fresh chicory decoction frothed with boiling thick farm milk.',
      category: 'Beverages',
      basePrice: 75.0,
      preparationTimeMinutes: 5,
      imageUrl: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=600',
    );

    // k5 Items (Italian)
    final m5_1 = MenuItem(
      id: 'm5_1',
      kitchenId: 'k5',
      name: '11" Burrata & San Marzano Sourdough Pizza',
      description: 'Slow-fermented crust, whole fresh burrata, basil and extra virgin olive oil.',
      category: 'Pizza',
      basePrice: 480.0,
      preparationTimeMinutes: 20,
      imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600',
    );

    final m5_2 = MenuItem(
      id: 'm5_2',
      kitchenId: 'k5',
      name: 'Truffle Wild Mushroom Fettuccine',
      description: 'Fresh pasta ribbons tossed in aged parmesan cream and porcini reduction.',
      category: 'Pasta',
      basePrice: 390.0,
      preparationTimeMinutes: 18,
      imageUrl: 'https://images.unsplash.com/photo-1621996346565-e3d5d6281699?w=600',
    );

    // k6 Items (Rolls & Munchies)
    final m6_1 = MenuItem(
      id: 'm6_1',
      kitchenId: 'k6',
      name: 'Smoked Butter Chicken Laccha Roll',
      description: 'Crispy paratha stuffed with tandoori tikka, butter gravy & pickled onions.',
      category: 'Rolls',
      basePrice: 220.0,
      preparationTimeMinutes: 10,
      imageUrl: 'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?w=600',
    );

    final m6_2 = MenuItem(
      id: 'm6_2',
      kitchenId: 'k6',
      name: 'Double Paneer Tikka Mayo Roll',
      description: 'Charred cottage cheese cubes with mint emulsion and chaat masala.',
      category: 'Rolls',
      basePrice: 190.0,
      preparationTimeMinutes: 10,
      imageUrl: 'https://images.unsplash.com/photo-1606471191009-63994c53433b?w=600',
    );

    // 3. Pre-Seeded Live Orders Across Diverse Stages
    final order1 = OrderModel(
      id: 'ORD-9821',
      customerName: 'Samarth Devadiga',
      customerPhone: '+91 98765 43210',
      deliveryAddress: '14th Main Rd, Indiranagar, Bengaluru',
      kitchenId: 'k1',
      kitchenName: 'Nawabi Dum Cloud Kitchen',
      items: [
        OrderItem(
          item: m1,
          quantity: 1,
          selectedCustomizations: [m1.customizationGroups[0].options[0]],
        ),
      ],
      pricing: PricingCalculator.compute(
        itemsTotal: 420.0,
        distanceInKm: 2.4,
        kitchenCommissionRate: 0.20,
        isPremiumSubscriber: true,
      ),
      status: OrderStatus.preparing,
      createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
      deliveryPartnerName: 'Ramesh Kumar (Hero Splendor)',
      deliveryPartnerPhone: '+91 99887 76655',
      estimatedTimeMinutes: 22,
    );

    final order2 = OrderModel(
      id: 'ORD-9822',
      customerName: 'Ananya Sharma',
      customerPhone: '+91 98112 33445',
      deliveryAddress: '7th Cross, Koramangala 4th Block',
      kitchenId: 'k3',
      kitchenName: 'Wok Samurai Express',
      items: [
        OrderItem(item: m4, quantity: 1),
        OrderItem(item: m3_2, quantity: 1),
      ],
      pricing: PricingCalculator.compute(
        itemsTotal: 580.0,
        distanceInKm: 3.5,
        kitchenCommissionRate: 0.25,
        isPremiumSubscriber: false,
      ),
      status: OrderStatus.readyForPickup,
      createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
      estimatedTimeMinutes: 14,
    );

    final order3 = OrderModel(
      id: 'ORD-9823',
      customerName: 'Vikram Mehta',
      customerPhone: '+91 97234 56789',
      deliveryAddress: 'Green Glen Layout, Bellandur',
      kitchenId: 'k2',
      kitchenName: 'Bowl & Green Healthy Kitchen',
      items: [
        OrderItem(item: m3, quantity: 1),
      ],
      pricing: PricingCalculator.compute(
        itemsTotal: 360.0,
        distanceInKm: 4.1,
        kitchenCommissionRate: 0.18,
        isPremiumSubscriber: true,
      ),
      status: OrderStatus.placed,
      createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      estimatedTimeMinutes: 28,
    );

    final order4 = OrderModel(
      id: 'ORD-9824',
      customerName: 'Neha Patel',
      customerPhone: '+91 98450 12399',
      deliveryAddress: 'Maple Woods, Domlur Layout',
      kitchenId: 'k4',
      kitchenName: 'Madras Tiffin & Dosa Pod',
      items: [
        OrderItem(item: m4_1, quantity: 1),
        OrderItem(item: m4_3, quantity: 1),
      ],
      pricing: PricingCalculator.compute(
        itemsTotal: 235.0,
        distanceInKm: 1.8,
        kitchenCommissionRate: 0.15,
        isPremiumSubscriber: true,
      ),
      status: OrderStatus.outForDelivery,
      createdAt: DateTime.now().subtract(const Duration(minutes: 24)),
      deliveryPartnerName: 'Suresh Reddy (Bajaj Chetak EV)',
      deliveryPartnerPhone: '+91 98440 55667',
      estimatedTimeMinutes: 7,
    );

    final order5 = OrderModel(
      id: 'ORD-9820',
      customerName: 'Rahul Roy',
      customerPhone: '+91 99001 22334',
      deliveryAddress: 'Prestige Palms, Indiranagar',
      kitchenId: 'k5',
      kitchenName: 'The Italian Oven Cloud Lab',
      items: [
        OrderItem(item: m5_1, quantity: 1),
        OrderItem(item: m5_2, quantity: 1),
      ],
      pricing: PricingCalculator.compute(
        itemsTotal: 870.0,
        distanceInKm: 3.8,
        kitchenCommissionRate: 0.22,
        isPremiumSubscriber: false,
      ),
      status: OrderStatus.delivered,
      createdAt: DateTime.now().subtract(const Duration(minutes: 50)),
      deliveryPartnerName: 'Ramesh Kumar (Hero Splendor)',
      deliveryPartnerPhone: '+91 99887 76655',
      estimatedTimeMinutes: 0,
    );

    // 4. Pre-Seeded Delivery Radar & Missions
    final task1 = DeliveryTask(
      id: 'TASK-101',
      orderId: 'ORD-9821',
      kitchenName: 'Nawabi Dum Cloud Kitchen',
      kitchenAddress: 'Hub 04, 100 Feet Rd, Indiranagar',
      dropAddress: '14th Main Rd, Indiranagar, Bengaluru',
      distanceKm: 2.4,
      riderPayout: 58.0,
      stage: DeliveryStage.enRouteToKitchen,
      riderId: 'rider_01',
      riderName: 'Ramesh Kumar',
    );

    final task2 = DeliveryTask(
      id: 'TASK-102',
      orderId: 'ORD-9822',
      kitchenName: 'Wok Samurai Express',
      kitchenAddress: 'Cloud Kitchen Complex, HSR Layout Sector 2',
      dropAddress: '7th Cross, Koramangala 4th Block',
      distanceKm: 3.5,
      riderPayout: 65.0,
      stage: DeliveryStage.available,
    );

    final task3 = DeliveryTask(
      id: 'TASK-103',
      orderId: 'ORD-9823',
      kitchenName: 'Bowl & Green Healthy Kitchen',
      kitchenAddress: 'Kitchen Pod B, Koramangala 5th Block',
      dropAddress: 'Green Glen Layout, Bellandur',
      distanceKm: 4.1,
      riderPayout: 48.0,
      stage: DeliveryStage.available,
    );

    final task4 = DeliveryTask(
      id: 'TASK-104',
      orderId: 'ORD-9824',
      kitchenName: 'Madras Tiffin & Dosa Pod',
      kitchenAddress: 'Express Pod 12, 9th Main, Jayanagar',
      dropAddress: 'Maple Woods, Domlur Layout',
      distanceKm: 1.8,
      riderPayout: 42.0,
      stage: DeliveryStage.outForDelivery,
      riderId: 'rider_02',
      riderName: 'Suresh Reddy',
    );

    final task5 = DeliveryTask(
      id: 'TASK-100',
      orderId: 'ORD-9820',
      kitchenName: 'The Italian Oven Cloud Lab',
      kitchenAddress: 'Kitchen Loft 3, Inner Ring Rd, Domlur',
      dropAddress: 'Prestige Palms, Indiranagar',
      distanceKm: 3.8,
      riderPayout: 72.0,
      stage: DeliveryStage.delivered,
      riderId: 'rider_01',
      riderName: 'Ramesh Kumar',
    );

    return PlatformState(
      kitchens: [k1, k2, k3, k4, k5, k6],
      menuItems: [
        m1,
        m2,
        m1_3,
        m3,
        m2_2,
        m2_3,
        m4,
        m3_2,
        m3_3,
        m4_1,
        m4_2,
        m4_3,
        m5_1,
        m5_2,
        m6_1,
        m6_2,
      ],
      orders: [order1, order2, order3, order4, order5],
      deliveryTasks: [task1, task2, task3, task4, task5],
    );
  }

  // --- Vendor Actions ---
  void updateKitchenCapacity(String kitchenId, int newMaxCapacity) {
    state = state.copyWith(
      kitchens: state.kitchens.map((k) {
        if (k.id == kitchenId) {
          return k.copyWith(maxOrderCapacity: newMaxCapacity);
        }
        return k;
      }).toList(),
    );
  }

  void toggleKitchenAcceptingOrders(String kitchenId) {
    state = state.copyWith(
      kitchens: state.kitchens.map((k) {
        if (k.id == kitchenId) {
          return k.copyWith(isAcceptingOrders: !k.isAcceptingOrders);
        }
        return k;
      }).toList(),
    );
  }

  void toggleMenuItemAvailability(String menuItemId) {
    state = state.copyWith(
      menuItems: state.menuItems.map((item) {
        if (item.id == menuItemId) {
          return item.copyWith(isAvailable: !item.isAvailable);
        }
        return item;
      }).toList(),
    );
  }

  void addMenuItem(MenuItem newItem) {
    state = state.copyWith(
      menuItems: [...state.menuItems, newItem],
    );
  }

  // --- Customer & Order Engine ---
  String? placeOrder({
    required Kitchen kitchen,
    required List<OrderItem> items,
    required PricingBreakdown pricing,
    required String customerName,
    required String customerPhone,
    required String address,
    String paymentMethod = 'UPI (Razorpay Gateway)',
  }) {
    // 1. Concurrency/Capacity Validation
    if (!kitchen.isAcceptingOrders || kitchen.isAtCapacity) {
      return null; // Kitchen throttle active!
    }

    final newOrderId = 'ORD-${DateTime.now().millisecondsSinceEpoch % 10000}';
    final newOrder = OrderModel(
      id: newOrderId,
      customerName: customerName,
      customerPhone: customerPhone,
      deliveryAddress: address,
      kitchenId: kitchen.id,
      kitchenName: kitchen.name,
      items: items,
      pricing: pricing,
      paymentMethod: paymentMethod,
      status: OrderStatus.placed,
      createdAt: DateTime.now(),
      estimatedTimeMinutes: kitchen.calculateEstimatedDeliveryMinutes(),
    );

    // 2. Increment active kitchen capacity load
    final updatedKitchens = state.kitchens.map((k) {
      if (k.id == kitchen.id) {
        return k.copyWith(activeOrdersCount: k.activeOrdersCount + 1);
      }
      return k;
    }).toList();

    // 3. Create a delivery task broadcast for riders
    final newDeliveryTask = DeliveryTask(
      id: 'TASK-${DateTime.now().millisecondsSinceEpoch % 1000}',
      orderId: newOrderId,
      kitchenName: kitchen.name,
      kitchenAddress: kitchen.address,
      dropAddress: address,
      distanceKm: kitchen.distanceKm,
      riderPayout: (pricing.deliveryFee * 0.85).clamp(40.0, 150.0),
      stage: DeliveryStage.available,
    );

    state = state.copyWith(
      kitchens: updatedKitchens,
      orders: [newOrder, ...state.orders],
      deliveryTasks: [newDeliveryTask, ...state.deliveryTasks],
    );
    return newOrderId;
  }

  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    state = state.copyWith(
      orders: state.orders.map((o) {
        if (o.id == orderId) {
          return o.copyWith(status: newStatus);
        }
        return o;
      }).toList(),
    );
  }

  // --- Delivery Partner Actions ---
  void acceptDeliveryTask(String taskId, String riderName, String riderPhone) {
    final taskIndex = state.deliveryTasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = state.deliveryTasks[taskIndex];
    final updatedTask = task.copyWith(
      stage: DeliveryStage.assigned,
      riderId: 'rider_current',
      riderName: riderName,
    );

    // Update order with rider information without regressing preparation status
    final updatedOrders = state.orders.map((o) {
      if (o.id.trim().toLowerCase() == task.orderId.trim().toLowerCase()) {
        return o.copyWith(
          deliveryPartnerName: riderName,
          deliveryPartnerPhone: riderPhone,
          status: (o.status == OrderStatus.placed) ? OrderStatus.accepted : o.status,
        );
      }
      return o;
    }).toList();

    final updatedTasks = [...state.deliveryTasks];
    updatedTasks[taskIndex] = updatedTask;

    state = state.copyWith(
      deliveryTasks: updatedTasks,
      orders: updatedOrders,
    );
  }

  void advanceDeliveryStage(String taskId) {
    final taskIndex = state.deliveryTasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = state.deliveryTasks[taskIndex];
    DeliveryStage nextStage = task.stage;
    OrderStatus? correspondingOrderStatus;

    switch (task.stage) {
      case DeliveryStage.available:
        nextStage = DeliveryStage.assigned;
        break;
      case DeliveryStage.assigned:
        nextStage = DeliveryStage.enRouteToKitchen;
        break;
      case DeliveryStage.enRouteToKitchen:
        nextStage = DeliveryStage.atKitchen;
        correspondingOrderStatus = OrderStatus.readyForPickup;
        break;
      case DeliveryStage.atKitchen:
        nextStage = DeliveryStage.outForDelivery;
        correspondingOrderStatus = OrderStatus.outForDelivery;
        break;
      case DeliveryStage.outForDelivery:
        nextStage = DeliveryStage.delivered;
        correspondingOrderStatus = OrderStatus.delivered;
        break;
      case DeliveryStage.delivered:
        return;
    }

    final updatedTask = task.copyWith(stage: nextStage);
    final updatedTasks = [...state.deliveryTasks];
    updatedTasks[taskIndex] = updatedTask;

    // Update order and free up kitchen capacity if delivered
    var updatedKitchens = state.kitchens;
    final updatedOrders = state.orders.map((o) {
      if (o.id.trim().toLowerCase() == task.orderId.trim().toLowerCase()) {
        if (correspondingOrderStatus == OrderStatus.delivered) {
          // Release kitchen slot!
          updatedKitchens = state.kitchens.map((k) {
            if (k.id == o.kitchenId && k.activeOrdersCount > 0) {
              return k.copyWith(activeOrdersCount: k.activeOrdersCount - 1);
            }
            return k;
          }).toList();
        }
        return o.copyWith(
          status: correspondingOrderStatus ?? o.status,
        );
      }
      return o;
    }).toList();

    state = state.copyWith(
      deliveryTasks: updatedTasks,
      orders: updatedOrders,
      kitchens: updatedKitchens,
    );
  }

  // --- Admin Portal Controls ---
  void updateKitchenCommission(String kitchenId, double newRate) {
    state = state.copyWith(
      kitchens: state.kitchens.map((k) {
        if (k.id == kitchenId) {
          return k.copyWith(commissionRate: newRate);
        }
        return k;
      }).toList(),
    );
  }

  void toggleSponsoredKitchen(String kitchenId) {
    state = state.copyWith(
      kitchens: state.kitchens.map((k) {
        if (k.id == kitchenId) {
          return k.copyWith(isSponsored: !k.isSponsored);
        }
        return k;
      }).toList(),
    );
  }
}

final platformProvider =
    NotifierProvider<PlatformNotifier, PlatformState>(
  PlatformNotifier.new,
);
