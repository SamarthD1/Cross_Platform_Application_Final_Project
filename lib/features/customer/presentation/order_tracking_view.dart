import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/domain/user_role.dart';
import '../../data/kitchen_repository.dart';
import '../../models/order_model.dart';

class OrderTrackingView extends ConsumerWidget {
  final String orderId;

  const OrderTrackingView({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(userSessionProvider);

    // Strict Role Guard: Order tracking is only visible to customers
    if (session.activeRole != UserRole.customer) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
      return Scaffold(
        backgroundColor: AppTheme.lightBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: const Text(
            'Live Tracking Restricted',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.textDark),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_person, size: 48, color: AppTheme.dangerRed),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Customer View Only',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Live delivery tracking is exclusively accessible for Customer accounts. Switch back to Customer Portal to view tracking.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Return to Portal'),
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    final platform = ref.watch(platformProvider);
    final order = platform.orders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => platform.orders.first,
    );

    final steps = [
      {'title': 'Order Placed', 'subtitle': 'Sent to kitchen for acceptance', 'icon': Icons.receipt_long},
      {'title': 'Kitchen Accepted', 'subtitle': 'Slot reserved in prep queue', 'icon': Icons.done_all},
      {'title': 'Food in Preparation', 'subtitle': 'Chefs are crafting your dish', 'icon': Icons.soup_kitchen},
      {'title': 'Ready for Pickup', 'subtitle': 'Waiting for rider pickup', 'icon': Icons.inventory_2_outlined},
      {'title': 'Out for Delivery', 'subtitle': 'Rider is on the way to you', 'icon': Icons.moped},
      {'title': 'Delivered', 'subtitle': 'Enjoy your hot meal!', 'icon': Icons.check_circle},
    ];

    final currentStep = order.status.stepIndex;

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Live Tracking #${order.id}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.textDark),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Estimated Delivery Time Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFD8BF)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.status == OrderStatus.delivered
                            ? 'Order Delivered!'
                            : 'Arriving in ~${order.estimatedTimeMinutes} mins',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kitchen: ${order.kitchenName}',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Destination: ${order.deliveryAddress}',
                        style: const TextStyle(color: AppTheme.textDark, fontSize: 12, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.verified, size: 14, color: AppTheme.emeraldGreen),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Paid via: ${order.paymentMethod}',
                              style: const TextStyle(fontSize: 11, color: AppTheme.emeraldGreen, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    order.status == OrderStatus.delivered
                        ? Icons.check
                        : Icons.delivery_dining,
                    color: AppTheme.primaryOrange,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Delivery Partner Card
          if (order.deliveryPartnerName != null)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.lightDivider),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryOrange.withOpacity(0.12),
                  child: const Icon(Icons.person, color: AppTheme.primaryOrange),
                ),
                title: Text(order.deliveryPartnerName!, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                subtitle: Text('Contact: ${order.deliveryPartnerPhone ?? "+91 98765 00000"}', style: const TextStyle(color: AppTheme.textMuted)),
                trailing: IconButton(
                  icon: const Icon(Icons.phone, color: AppTheme.emeraldGreen),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Calling rider ${order.deliveryPartnerName}...')),
                    );
                  },
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Live Route Progression Stepper
          Text(
            'Order Status Progress',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.lightDivider),
            ),
            child: Column(
              children: List.generate(steps.length, (index) {
                final isCompleted = index <= currentStep;
                final isCurrent = index == currentStep;
                final step = steps[index];

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted
                                ? (isCurrent ? AppTheme.primaryOrange : AppTheme.emeraldGreen)
                                : const Color(0xFFE9ECEF),
                          ),
                          child: Icon(
                            isCompleted ? Icons.check : (step['icon'] as IconData),
                            size: 14,
                            color: isCompleted ? Colors.white : AppTheme.textMuted,
                          ),
                        ),
                        if (index < steps.length - 1)
                          Container(
                            width: 2,
                            height: 34,
                            color: index < currentStep ? AppTheme.emeraldGreen : const Color(0xFFE9ECEF),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step['title'] as String,
                              style: TextStyle(
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                fontSize: 14,
                                color: isCompleted ? AppTheme.textDark : AppTheme.textMuted,
                              ),
                            ),
                            Text(
                              step['subtitle'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: isCurrent ? AppTheme.primaryOrange : AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),

          const SizedBox(height: 16),

          // Items summary
          Text(
            'Ordered Items (${order.items.length})',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.lightDivider),
            ),
            child: Column(
              children: [
                ...order.items.map(
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${i.quantity}x ${i.item.name}', style: const TextStyle(fontSize: 13, color: AppTheme.textDark)),
                        Text('₹${i.totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                      ],
                    ),
                  ),
                ),
                const Divider(color: AppTheme.lightDivider),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Paid', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                    Text(
                      '₹${order.pricing.finalPayable.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryOrange),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
