import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../data/kitchen_repository.dart';
import '../../models/delivery_task.dart';

class DeliveryDashboard extends ConsumerStatefulWidget {
  const DeliveryDashboard({super.key});

  @override
  ConsumerState<DeliveryDashboard> createState() => _DeliveryDashboardState();
}

class _DeliveryDashboardState extends ConsumerState<DeliveryDashboard> {
  bool _isOnline = true;
  final String _riderName = 'Ramesh Kumar (Hero Splendor)';
  final String _riderPhone = '+91 98877 66554';

  @override
  Widget build(BuildContext context) {
    final platform = ref.watch(platformProvider);

    // Available unassigned tasks
    final availableTasks = platform.deliveryTasks
        .where((t) => t.stage == DeliveryStage.available)
        .toList();

    // Active ongoing task assigned to this rider
    final myActiveTasks = platform.deliveryTasks
        .where((t) =>
            t.stage != DeliveryStage.available &&
            t.stage != DeliveryStage.delivered)
        .toList();

    // Completed tasks
    final completedTasks = platform.deliveryTasks
        .where((t) => t.stage == DeliveryStage.delivered)
        .toList();

    final double totalEarnings =
        completedTasks.fold(0.0, (sum, t) => sum + t.riderPayout);

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Rider Profile & Duty Toggle Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.only(bottom: 16),
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
                CircleAvatar(
                  backgroundColor: AppTheme.primaryOrange.withOpacity(0.12),
                  child: const Icon(Icons.delivery_dining, color: AppTheme.primaryOrange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _riderName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Rider Phone: $_riderPhone',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isOnline ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _isOnline ? 'DUTY ON' : 'DUTY OFF',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _isOnline ? AppTheme.emeraldGreen : AppTheme.dangerRed,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Switch(
                      value: _isOnline,
                      activeTrackColor: AppTheme.emeraldGreen,
                      onChanged: (val) => setState(() => _isOnline = val),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Rider Metric Summary Card
          Container(
            padding: const EdgeInsets.all(16),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _riderStat('Today\'s Payout', '₹${totalEarnings.toStringAsFixed(0)}', AppTheme.emeraldGreen),
                Container(width: 1, height: 40, color: AppTheme.lightDivider),
                _riderStat('Trips Done', '${completedTasks.length}', AppTheme.textDark),
                Container(width: 1, height: 40, color: AppTheme.lightDivider),
                _riderStat('Rating', '4.9 ★', AppTheme.primaryOrange),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Active Delivery Missions List (Multi-order batching)
          if (myActiveTasks.isNotEmpty) ...[
            Text(
              'Active Delivery Missions (${myActiveTasks.length})',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
            ),
            const SizedBox(height: 10),
            ...myActiveTasks.map(
              (task) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildActiveTaskCard(context, ref, task),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Available Orders for Allocation
          Row(
            children: [
              Expanded(
                child: Text(
                  'Available Deliveries (${availableTasks.length})',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_isOnline) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Live Dispatch Radar', style: TextStyle(fontSize: 10, color: AppTheme.emeraldGreen, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          if (!_isOnline)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: const Text('Switch DUTY ON to receive delivery requests.', style: TextStyle(color: AppTheme.textMuted)),
            )
          else if (availableTasks.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  Icon(Icons.radar, size: 40, color: AppTheme.textMuted),
                  SizedBox(height: 8),
                  Text('Scanning for ready cloud kitchen dispatches...', style: TextStyle(color: AppTheme.textMuted)),
                ],
              ),
            )
          else
            ...availableTasks.map((task) => _buildAvailableTaskCard(context, ref, task)),
        ],
      ),
    );
  }

  Widget _riderStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
      ],
    );
  }

  Widget _buildActiveTaskCard(BuildContext context, WidgetRef ref, DeliveryTask task) {
    final stage = task.stage;

    String nextButtonLabel = 'Advance Stage';
    if (stage == DeliveryStage.assigned) nextButtonLabel = 'Start Journey to Kitchen';
    if (stage == DeliveryStage.enRouteToKitchen) nextButtonLabel = 'Arrived at Cloud Kitchen';
    if (stage == DeliveryStage.atKitchen) nextButtonLabel = 'Order Picked Up • Start Delivery';
    if (stage == DeliveryStage.outForDelivery) nextButtonLabel = 'Confirm Delivery to Customer';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryOrange, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFFD8BF)),
                    ),
                    child: Text(
                      'TRIP #${task.orderId} • ${stage.label}',
                      style: const TextStyle(color: AppTheme.primaryOrange, fontSize: 11, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Payout: ₹${task.riderPayout.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.emeraldGreen, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.store, color: AppTheme.primaryOrange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pickup: ${task.kitchenName}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                      Text(task.kitchenAddress, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.home, color: AppTheme.emeraldGreen, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Delivery Drop Point', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                      Text(task.dropAddress, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.navigation, size: 18),
                label: Text(nextButtonLabel),
                onPressed: () {
                  ref.read(platformProvider.notifier).advanceDeliveryStage(task.id);
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 1),
                      content: Text('Order #${task.orderId}: Delivery stage updated!'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableTaskCard(BuildContext context, WidgetRef ref, DeliveryTask task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${task.orderId}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark),
                ),
                Text(
                  '₹${task.riderPayout.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.emeraldGreen,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('📍 Pickup: ${task.kitchenName}', style: const TextStyle(fontSize: 12, color: AppTheme.textDark)),
            Text('🎯 Drop: ${task.dropAddress}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${task.distanceKm} km route distance', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.emeraldGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    minimumSize: const Size(80, 32),
                  ),
                  onPressed: () {
                    ref.read(platformProvider.notifier).acceptDeliveryTask(
                          task.id,
                          _riderName,
                          _riderPhone,
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Delivery trip accepted! Follow route to kitchen.')),
                    );
                  },
                  child: const Text('Accept Trip', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
