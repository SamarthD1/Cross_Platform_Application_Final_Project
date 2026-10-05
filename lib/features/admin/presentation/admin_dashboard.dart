import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../data/kitchen_repository.dart';
import '../../models/kitchen.dart';
import '../../models/order_model.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platform = ref.watch(platformProvider);

    // Compute Platform Analytics
    final double totalGMV = platform.orders.fold(
      0.0,
      (sum, o) => sum + o.pricing.finalPayable,
    );

    final double totalCommissionsEarned = platform.orders.fold(
      0.0,
      (sum, o) => sum + o.pricing.platformCommission + o.pricing.platformFee,
    );

    final int totalActiveKitchens =
        platform.kitchens.where((k) => k.isAcceptingOrders).length;

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Platform Header KPI Cards
          Text(
            'Platform Financial Analytics',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  'Gross Merchandise (GMV)',
                  '₹${totalGMV.toStringAsFixed(0)}',
                  Icons.currency_rupee,
                  AppTheme.primaryOrange,
                  'Total customer order spends',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKpiCard(
                  'Platform Net Revenue',
                  '₹${totalCommissionsEarned.toStringAsFixed(0)}',
                  Icons.trending_up,
                  AppTheme.emeraldGreen,
                  '15-30% Commissions + Fees',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  'Total Orders',
                  '${platform.orders.length}',
                  Icons.receipt,
                  const Color(0xFF6366F1),
                  'Across all locations',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKpiCard(
                  'Active Kitchens',
                  '$totalActiveKitchens / ${platform.kitchens.length}',
                  Icons.store,
                  const Color(0xFF0EA5E9),
                  'Real-time operational pods',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Multi-Vendor Management & Commission Engine
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cloud Kitchen Vendors (${platform.kitchens.length})',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Monetization & Commission Controls',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...platform.kitchens.map((k) => _buildKitchenVendorCard(context, ref, k)),

          const SizedBox(height: 24),

          // Order Financial Ledger Audit
          Text(
            'Order Transactions & Commission Audit Log',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.lightDivider),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: platform.orders.length,
              separatorBuilder: (_, __) => const Divider(color: AppTheme.lightDivider, height: 1),
              itemBuilder: (context, index) {
                final order = platform.orders[index];
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.receipt_long, size: 18, color: AppTheme.primaryOrange),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${order.id} • ${order.kitchenName}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Customer: ${order.customerName} (${order.status.label})',
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₹${order.pricing.finalPayable.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark)),
                          Text(
                            'Platform Cut: +₹${order.pricing.platformCommission.toStringAsFixed(0)}',
                            style: const TextStyle(color: AppTheme.emeraldGreen, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
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
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildKitchenVendorCard(BuildContext context, WidgetRef ref, Kitchen kitchen) {
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
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              kitchen.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (kitchen.isSponsored)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              margin: const EdgeInsets.only(left: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8E7),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFFFE082)),
                              ),
                              child: const Text('SPONSORED', style: TextStyle(color: Color(0xFFD97706), fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      Text(kitchen.address, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
                Switch(
                  value: kitchen.isAcceptingOrders,
                  activeTrackColor: AppTheme.emeraldGreen,
                  onChanged: (_) {
                    ref.read(platformProvider.notifier).toggleKitchenAcceptingOrders(kitchen.id);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: AppTheme.lightDivider),
            const SizedBox(height: 8),

            // Commission & Sponsored Controls (Responsive Wrap for mobile)
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Commission Rate: ${(kitchen.commissionRate * 100).toInt()}%',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textDark),
                    ),
                    const Text('Platform take rate', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final rate in [0.15, 0.20, 0.25, 0.30])
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kitchen.commissionRate == rate ? AppTheme.primaryOrange : const Color(0xFFF1F3F6),
                            foregroundColor: kitchen.commissionRate == rate ? Colors.white : AppTheme.textDark,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: const Size(40, 28),
                            elevation: 0,
                          ),
                          onPressed: () => ref.read(platformProvider.notifier).updateKitchenCommission(kitchen.id, rate),
                          child: Text('${(rate * 100).toInt()}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Sponsored toggle button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Promoted / Sponsored Listing Slot',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: Icon(
                    kitchen.isSponsored ? Icons.star : Icons.star_border,
                    size: 16,
                    color: AppTheme.primaryAmber,
                  ),
                  label: Text(
                    kitchen.isSponsored ? 'Featured' : 'Make Featured',
                    style: const TextStyle(fontSize: 12, color: Color(0xFFD97706), fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    ref.read(platformProvider.notifier).toggleSponsoredKitchen(kitchen.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
