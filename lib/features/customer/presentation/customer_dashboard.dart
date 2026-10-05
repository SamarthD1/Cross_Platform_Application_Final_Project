import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../data/kitchen_repository.dart';
import '../../models/kitchen.dart';
import '../../models/order_model.dart';
import '../cart/cart_provider.dart';
import 'kitchen_detail_view.dart';
import 'order_tracking_view.dart';

class CustomerDashboard extends ConsumerStatefulWidget {
  const CustomerDashboard({super.key});

  @override
  ConsumerState<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends ConsumerState<CustomerDashboard> {
  String _selectedCuisine = 'All';
  String _searchQuery = '';

  final List<String> _cuisines = [
    'All',
    'Biryani',
    'Healthy',
    'Pan-Asian',
    'South Indian',
    'Italian',
    'Mughlai',
    'Rolls',
    'Continental',
  ];

  @override
  Widget build(BuildContext context) {
    final platform = ref.watch(platformProvider);
    final cart = ref.watch(cartProvider);
    final session = ref.watch(userSessionProvider);

    // Active placed orders for current user
    final activeOrders = platform.orders
        .where((o) =>
            o.status != OrderStatus.delivered &&
            o.status != OrderStatus.cancelled)
        .toList();

    final filteredKitchens = platform.kitchens.where((k) {
      final matchesSearch = k.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          k.cuisines.any((c) => c.toLowerCase().contains(_searchQuery.toLowerCase()));
      final matchesCuisine = _selectedCuisine == 'All' ||
          k.cuisines.any((c) => c.toLowerCase() == _selectedCuisine.toLowerCase());
      return matchesSearch && matchesCuisine;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Search & Location Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: AppTheme.primaryOrange, size: 20),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              session.userAddress,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textDark),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.lightDivider),
                            ),
                            child: const Text('Within 5 km', style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Search TextField (Swiggy crisp light input)
                      TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: const TextStyle(color: AppTheme.textDark),
                        decoration: InputDecoration(
                          hintText: 'Search cloud kitchens, biryani, bowls...',
                          prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18, color: AppTheme.textMuted),
                                  onPressed: () => setState(() => _searchQuery = ''),
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Active Order Alert Bar (if customer has an active order)
              if (activeOrders.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderTrackingView(orderId: activeOrders.first.id),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFFD8BF)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryOrange.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.moped, color: AppTheme.primaryOrange, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Active Order #${activeOrders.first.id} • ${activeOrders.first.status.label}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark),
                                  ),
                                  Text(
                                    'Kitchen: ${activeOrders.first.kitchenName}',
                                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            const Text(
                              'Track Live',
                              style: TextStyle(
                                color: AppTheme.primaryOrange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.primaryOrange),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Cuisine Filter Chips
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _cuisines.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final c = _cuisines[index];
                      final isSelected = c == _selectedCuisine;
                      return ChoiceChip(
                        label: Text(
                          c,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.textDark,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryOrange,
                        backgroundColor: Colors.white,
                        onSelected: (_) => setState(() => _selectedCuisine = c),
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Section Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Cloud Kitchens Near You (${filteredKitchens.length})',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Fast Delivery Hubs',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Kitchen List
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final kitchen = filteredKitchens[index];
                      return _buildKitchenCard(context, kitchen);
                    },
                    childCount: filteredKitchens.length,
                  ),
                ),
              ),

              // Bottom padding for cart floating bar
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          // Floating Cart Bottom Bar (Swiggy iconic dark slate bar with green total)
          if (cart.items.isNotEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: _buildCartBottomBar(context, cart, session.isPremiumMember),
            ),
        ],
      ),
    );
  }

  Widget _buildKitchenCard(BuildContext context, Kitchen kitchen) {
    final edt = kitchen.calculateEstimatedDeliveryMinutes();
    final isFull = kitchen.isAtCapacity;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightDivider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => KitchenDetailView(kitchen: kitchen),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Banner Row (Sponsored & Capacity Status)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kitchen Thumbnail Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        kitchen.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 80,
                          color: AppTheme.lightInput,
                          child: const Icon(Icons.restaurant, color: AppTheme.primaryOrange),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  kitchen.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppTheme.textDark,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (kitchen.isSponsored)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  margin: const EdgeInsets.only(left: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF8E7),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFFFFE082)),
                                  ),
                                  child: const Text(
                                    'PROMOTED',
                                    style: TextStyle(
                                      color: Color(0xFFD97706),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            kitchen.cuisines.join(' • '),
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          // Ratings & Timing Metrics (Responsive Wrap to prevent mobile overflow)
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              // Swiggy rating green pill
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.emeraldGreen,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star, color: Colors.white, size: 11),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${kitchen.rating}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.timer_outlined, size: 13, color: AppTheme.textMuted),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${kitchen.averagePrepTimeMinutes}m prep',
                                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.directions_bike_outlined, size: 13, color: AppTheme.textMuted),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${kitchen.distanceKm} km (~$edt mins)',
                                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(color: AppTheme.lightDivider, height: 1),
                const SizedBox(height: 10),

                // Real-Time Capacity & Throttle Indicator (Bounded for mobile screens)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: !kitchen.isAcceptingOrders
                                  ? AppTheme.dangerRed
                                  : isFull
                                      ? AppTheme.warningYellow
                                      : AppTheme.emeraldGreen,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              !kitchen.isAcceptingOrders
                                  ? 'Kitchen Paused (Offline)'
                                  : isFull
                                      ? 'Kitchen at Peak Capacity'
                                      : 'Kitchen Active (${kitchen.activeOrdersCount}/${kitchen.maxOrderCapacity} load)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: !kitchen.isAcceptingOrders
                                    ? AppTheme.dangerRed
                                    : isFull
                                        ? const Color(0xFFD97706)
                                        : AppTheme.emeraldGreen,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Explore Menu →',
                      style: TextStyle(
                        color: AppTheme.primaryOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCartBottomBar(
      BuildContext context, CartState cart, bool isPremium) {
    final pricing = cart.calculatePricing(isPremium);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2235), // Swiggy iconic dark bottom bar
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${cart.itemCount} Items • ₹${pricing.finalPayable.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  isPremium
                      ? 'Swiggy One: Free Delivery Applied'
                      : '+₹${pricing.deliveryFee} Delivery + ₹${pricing.platformFee} Fee',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isPremium ? FontWeight.w600 : FontWeight.normal,
                    color: isPremium ? AppTheme.swiggyOneGold : const Color(0xFFA0A5BA),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () {
              _showCheckoutBottomSheet(context);
            },
            child: const Text('View Cart'),
          ),
        ],
      ),
    );
  }

  void _showCheckoutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CartCheckoutSheet(
        onOrderPlaced: (orderId) {
          ScaffoldMessenger.of(context).clearSnackBars();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderTrackingView(orderId: orderId),
            ),
          );
        },
      ),
    );
  }
}

class CartCheckoutSheet extends ConsumerStatefulWidget {
  final void Function(String orderId)? onOrderPlaced;

  const CartCheckoutSheet({super.key, this.onOrderPlaced});

  @override
  ConsumerState<CartCheckoutSheet> createState() => _CartCheckoutSheetState();
}

class _CartCheckoutSheetState extends ConsumerState<CartCheckoutSheet> {
  String _selectedPaymentMethod = 'UPI (GPay / PhonePe / Paytm)';

  final List<Map<String, dynamic>> _paymentGateways = [
    {
      'title': 'UPI (GPay / PhonePe / Paytm)',
      'subtitle': 'Instant Gateway Verification',
      'icon': Icons.account_balance_wallet_outlined,
    },
    {
      'title': 'Credit / Debit Card (Razorpay Gateway)',
      'subtitle': 'Visa, Mastercard, RuPay',
      'icon': Icons.credit_card,
    },
    {
      'title': 'Swiggy Money & Wallet Balance',
      'subtitle': 'Fast 1-Click Checkout',
      'icon': Icons.wallet,
    },
    {
      'title': 'Cash on Delivery (COD)',
      'subtitle': 'Pay cash or scan QR upon drop',
      'icon': Icons.payments_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final session = ref.watch(userSessionProvider);
    final pricing = cart.calculatePricing(session.isPremiumMember);

    if (cart.items.isEmpty || cart.kitchen == null) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Your cart is empty', style: TextStyle(color: AppTheme.textMuted))),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Summary',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.textDark),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Text(
              'From: ${cart.kitchen!.name}',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 12),
            const Divider(color: AppTheme.lightDivider),

            // Items list
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 160),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  final item = cart.items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.item.name,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textDark),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (item.selectedCustomizations.isNotEmpty)
                                Text(
                                  item.selectedCustomizations.map((c) => c.name).join(', '),
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, size: 18, color: AppTheme.primaryOrange),
                              onPressed: () => ref.read(cartProvider.notifier).updateQuantity(index, -1),
                            ),
                            Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, size: 18, color: AppTheme.primaryOrange),
                              onPressed: () => ref.read(cartProvider.notifier).updateQuantity(index, 1),
                            ),
                          ],
                        ),
                        Text(
                          '₹${item.totalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const Divider(color: AppTheme.lightDivider),
            const SizedBox(height: 6),

            // Pricing Breakdown (Monetization Engine visualization)
            const Text('Bill Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark)),
            const SizedBox(height: 4),
            _billRow('Items Total', '₹${pricing.itemsTotal.toStringAsFixed(2)}'),
            _billRow(
              'Delivery Fee (${cart.kitchen!.distanceKm} km)',
              session.isPremiumMember ? 'FREE (Swiggy One)' : '₹${pricing.deliveryFee.toStringAsFixed(2)}',
              isDiscount: session.isPremiumMember,
            ),
            _billRow('Platform Fee', '₹${pricing.platformFee.toStringAsFixed(2)}'),
            const Divider(color: AppTheme.lightDivider),
            _billRow('To Pay', '₹${pricing.finalPayable.toStringAsFixed(2)}', isBold: true),

            const SizedBox(height: 12),

            // Payment Gateway Selection Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Payment Gateway Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('100% SECURE', style: TextStyle(fontSize: 9, color: AppTheme.emeraldGreen, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Gateway Options
            ..._paymentGateways.map((gw) {
              final isSelected = _selectedPaymentMethod == gw['title'];
              return InkWell(
                onTap: () => setState(() => _selectedPaymentMethod = gw['title'] as String),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryOrange.withOpacity(0.06) : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryOrange : AppTheme.lightDivider,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(gw['icon'] as IconData, size: 18, color: isSelected ? AppTheme.primaryOrange : AppTheme.textMuted),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gw['title'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppTheme.primaryOrange : AppTheme.textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              gw['subtitle'] as String,
                              style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Radio<String>(
                        value: gw['title'] as String,
                        groupValue: _selectedPaymentMethod,
                        activeColor: AppTheme.primaryOrange,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedPaymentMethod = val);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 12),

            // Pay & Place Order Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.lock, size: 16),
                label: Text('Pay & Place Order • ₹${pricing.finalPayable.toStringAsFixed(2)}'),
                onPressed: () {
                  final newOrderId = ref.read(platformProvider.notifier).placeOrder(
                        kitchen: cart.kitchen!,
                        items: cart.items,
                        pricing: pricing,
                        customerName: session.userName,
                        customerPhone: '+91 98765 43210',
                        address: session.userAddress,
                        paymentMethod: _selectedPaymentMethod,
                      );

                  if (newOrderId != null) {
                    ref.read(cartProvider.notifier).clearCart();
                    Navigator.pop(context); // close sheet
                    widget.onOrderPlaced?.call(newOrderId);
                  } else {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        duration: Duration(seconds: 2),
                        backgroundColor: AppTheme.dangerRed,
                        content: Text('Kitchen is currently at maximum capacity! Please try in a few minutes.'),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _billRow(String label, String value, {bool isDiscount = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AppTheme.textDark : AppTheme.textMuted,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isDiscount
                  ? AppTheme.emeraldGreen
                  : (isBold ? AppTheme.primaryOrange : AppTheme.textDark),
            ),
          ),
        ],
      ),
    );
  }
}
