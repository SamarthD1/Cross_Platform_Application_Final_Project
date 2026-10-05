import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/pricing_calculator.dart';
import '../../data/kitchen_repository.dart';
import '../../models/kitchen.dart';
import '../../models/menu_item.dart';
import '../../models/order_model.dart';

class KitchenDashboard extends ConsumerStatefulWidget {
  const KitchenDashboard({super.key});

  @override
  ConsumerState<KitchenDashboard> createState() => _KitchenDashboardState();
}

class _KitchenDashboardState extends ConsumerState<KitchenDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedKitchenId = 'k1';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final platform = ref.watch(platformProvider);
    final kitchen = platform.kitchens.firstWhere(
      (k) => k.id == _selectedKitchenId,
      orElse: () => platform.kitchens.first,
    );

    final kitchenOrders =
        platform.orders.where((o) => o.kitchenId == kitchen.id).toList();

    final placedOrders =
        kitchenOrders.where((o) => o.status == OrderStatus.placed).toList();
    final preparingOrders =
        kitchenOrders.where((o) => o.status == OrderStatus.preparing || o.status == OrderStatus.accepted).toList();
    final readyOrders =
        kitchenOrders.where((o) => o.status == OrderStatus.readyForPickup || o.status == OrderStatus.outForDelivery).toList();

    final menuItems =
        platform.menuItems.where((m) => m.kitchenId == kitchen.id).toList();

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Outlet Selector & Operational Switch Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.lightDivider),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.storefront, color: AppTheme.primaryOrange, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cloud Kitchen Outlet',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedKitchenId,
                          isDense: true,
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primaryOrange, size: 20),
                          selectedItemBuilder: (context) {
                            return platform.kitchens.map((k) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  k.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList();
                          },
                          items: platform.kitchens.map((k) {
                            return DropdownMenuItem(
                              value: k.id,
                              child: Text(
                                k.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedKitchenId = val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: kitchen.isAcceptingOrders ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        kitchen.isAcceptingOrders ? 'ONLINE' : 'PAUSED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: kitchen.isAcceptingOrders ? AppTheme.emeraldGreen : AppTheme.dangerRed,
                        ),
                      ),
                    ),
                    Transform.scale(
                      scale: 0.85,
                      child: Switch(
                        value: kitchen.isAcceptingOrders,
                        activeTrackColor: AppTheme.emeraldGreen,
                        onChanged: (_) {
                          ref.read(platformProvider.notifier).toggleKitchenAcceptingOrders(kitchen.id);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Capacity & Live Load Meter
          _buildCapacityMeterCard(context, ref, kitchen),
          const SizedBox(height: 16),

          // Quick Action: Add Menu Item Modal & Simulate Order
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Text(
                'Live Orders Kanban',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.emeraldGreen,
                      side: const BorderSide(color: AppTheme.emeraldGreen),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.bolt, size: 15),
                    label: const Text('Simulate', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: () => _simulateIncomingOrder(ref, kitchen),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryOrange,
                      side: const BorderSide(color: AppTheme.primaryOrange),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.add, size: 15),
                    label: const Text('Add Dish', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: () => _showAddMenuItemDialog(context, ref, kitchen.id),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Order Status Tabs
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.lightDivider),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primaryOrange,
              labelColor: AppTheme.primaryOrange,
              unselectedLabelColor: AppTheme.textMuted,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: [
                Tab(text: 'Incoming (${placedOrders.length})'),
                Tab(text: 'Preparing (${preparingOrders.length})'),
                Tab(text: 'Dispatched (${readyOrders.length})'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Kanban Content Area
          SizedBox(
            height: 280,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(placedOrders, 'No incoming orders', (order) {
                  ref.read(platformProvider.notifier).updateOrderStatus(order.id, OrderStatus.preparing);
                }, actionLabel: 'Accept & Cook', actionColor: AppTheme.emeraldGreen),
                _buildOrderList(preparingOrders, 'No orders currently cooking', (order) {
                  ref.read(platformProvider.notifier).updateOrderStatus(order.id, OrderStatus.readyForPickup);
                }, actionLabel: 'Mark Ready for Pickup', actionColor: AppTheme.primaryAmber),
                _buildOrderList(readyOrders, 'No dispatched orders in queue', null),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Menu Inventory & Stock Toggles
          Text(
            'Live Inventory Management (${menuItems.length} Dishes)',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
          ),
          const SizedBox(height: 10),

          ...menuItems.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.lightDivider),
              ),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.imageUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, color: AppTheme.primaryOrange),
                  ),
                ),
                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark)),
                subtitle: Text('₹${item.basePrice.toStringAsFixed(0)} • ${item.preparationTimeMinutes}m prep', style: const TextStyle(color: AppTheme.textMuted)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.isAvailable ? 'In Stock' : 'Sold Out',
                      style: TextStyle(
                        fontSize: 11,
                        color: item.isAvailable ? AppTheme.emeraldGreen : AppTheme.dangerRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Switch(
                      value: item.isAvailable,
                      activeTrackColor: AppTheme.emeraldGreen,
                      onChanged: (_) {
                        ref.read(platformProvider.notifier).toggleMenuItemAvailability(item.id);
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCapacityMeterCard(BuildContext context, WidgetRef ref, Kitchen kitchen) {
    final double percentage = kitchen.capacityPercentage;
    final isFull = kitchen.isAtCapacity;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightDivider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.speed, color: AppTheme.primaryOrange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Kitchen Capacity & Throttle',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isFull ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isFull ? 'SLOTS FULL' : 'AVAILABLE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isFull ? AppTheme.dangerRed : AppTheme.emeraldGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Active Kitchen Load: ${kitchen.activeOrdersCount} / ${kitchen.maxOrderCapacity} orders',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(percentage * 100).toInt()}% Used',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: percentage > 0.8 ? AppTheme.dangerRed : AppTheme.emeraldGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage,
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
            backgroundColor: const Color(0xFFE9ECEF),
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage > 0.85
                  ? AppTheme.dangerRed
                  : (percentage > 0.65 ? AppTheme.warningYellow : AppTheme.emeraldGreen),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Max Capacity Limit: ', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: AppTheme.primaryOrange, size: 20),
                    onPressed: kitchen.maxOrderCapacity > 2
                        ? () => ref.read(platformProvider.notifier).updateKitchenCapacity(kitchen.id, kitchen.maxOrderCapacity - 1)
                        : null,
                  ),
                  Text('${kitchen.maxOrderCapacity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark)),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: AppTheme.primaryOrange, size: 20),
                    onPressed: () => ref.read(platformProvider.notifier).updateKitchenCapacity(kitchen.id, kitchen.maxOrderCapacity + 1),
                  ),
                ],
              ),
              const Text('Prevents kitchen overbooking', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(
    List<OrderModel> orders,
    String emptyMessage,
    Function(OrderModel)? onAction, {
    String? actionLabel,
    Color? actionColor,
  }) {
    if (orders.isEmpty) {
      return Center(
        child: Text(emptyMessage, style: const TextStyle(color: AppTheme.textMuted)),
      );
    }

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.lightDivider),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: order.status.statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        order.status.label,
                        style: TextStyle(color: order.status.statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ...order.items.map(
                  (i) => Text(
                    '• ${i.quantity}x ${i.item.name}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textDark),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Net Payout: ₹${order.pricing.kitchenNetPayout.toStringAsFixed(2)}',
                        style: const TextStyle(color: AppTheme.emeraldGreen, fontWeight: FontWeight.bold, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (onAction != null && actionLabel != null) ...[
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: actionColor ?? AppTheme.primaryOrange,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: const Size(60, 28),
                        ),
                        onPressed: () => onAction(order),
                        child: Text(actionLabel, style: const TextStyle(fontSize: 11)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddMenuItemDialog(BuildContext context, WidgetRef ref, String kitchenId) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final prepCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Add Dish to Kitchen Menu', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: AppTheme.textDark),
                decoration: const InputDecoration(labelText: 'Dish Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.textDark),
                decoration: const InputDecoration(labelText: 'Base Price (₹)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: prepCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.textDark),
                decoration: const InputDecoration(labelText: 'Prep Time (minutes)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                style: const TextStyle(color: AppTheme.textDark),
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
                final newItem = MenuItem(
                  id: 'm_${DateTime.now().millisecondsSinceEpoch}',
                  kitchenId: kitchenId,
                  name: nameCtrl.text.trim(),
                  description: descCtrl.text.trim().isEmpty ? 'Chef special recipe' : descCtrl.text.trim(),
                  category: 'Specials',
                  basePrice: double.tryParse(priceCtrl.text) ?? 250.0,
                  preparationTimeMinutes: int.tryParse(prepCtrl.text) ?? 15,
                  imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600',
                );

                ref.read(platformProvider.notifier).addMenuItem(newItem);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dish added to live menu!')),
                );
              }
            },
            child: const Text('Add Dish'),
          ),
        ],
      ),
    );
  }

  void _simulateIncomingOrder(WidgetRef ref, Kitchen kitchen) {
    final platform = ref.read(platformProvider);
    final items = platform.menuItems.where((i) => i.kitchenId == kitchen.id).toList();
    if (items.isEmpty) return;

    final orderItems = [
      OrderItem(item: items.first, quantity: 2),
    ];
    final double itemsTotal = orderItems.fold(0.0, (sum, i) => sum + i.totalPrice);
    final pricing = PricingCalculator.compute(
      itemsTotal: itemsTotal,
      distanceInKm: kitchen.distanceKm,
      isPremiumSubscriber: false,
      kitchenCommissionRate: kitchen.commissionRate,
    );

    final orderId = ref.read(platformProvider.notifier).placeOrder(
      kitchen: kitchen,
      items: orderItems,
      pricing: pricing,
      customerName: 'Ananya Verma (Live Demo)',
      customerPhone: '+91 98450 11223',
      address: 'Indiranagar 100ft Road, Flat 402',
    );

    ScaffoldMessenger.of(context).clearSnackBars();
    if (orderId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          backgroundColor: AppTheme.emeraldGreen,
          content: Text('Simulated live order received for ${kitchen.name}! Check Incoming column.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 2),
          backgroundColor: AppTheme.dangerRed,
          content: Text('Kitchen throttle is active! Maximum order capacity reached.'),
        ),
      );
    }
  }
}
