import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/domain/user_role.dart';
import '../../data/kitchen_repository.dart';
import '../../models/kitchen.dart';
import '../../models/menu_item.dart';
import '../cart/cart_provider.dart';

class KitchenDetailView extends ConsumerWidget {
  final Kitchen kitchen;

  const KitchenDetailView({super.key, required this.kitchen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(userSessionProvider);
    if (session.activeRole != UserRole.customer) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final platform = ref.watch(platformProvider);
    final currentKitchen = platform.kitchens.firstWhere(
      (k) => k.id == kitchen.id,
      orElse: () => kitchen,
    );
    final kitchenItems = platform.menuItems.where((m) => m.kitchenId == kitchen.id).toList();

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          currentKitchen.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.textDark),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              color: currentKitchen.isAtCapacity
                  ? const Color(0xFFFEF3C7)
                  : const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: currentKitchen.isAtCapacity
                    ? const Color(0xFFF59E0B)
                    : AppTheme.emeraldGreen,
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.speed,
                  size: 14,
                  color: currentKitchen.isAtCapacity ? const Color(0xFFD97706) : AppTheme.emeraldGreen,
                ),
                const SizedBox(width: 4),
                Text(
                  '${currentKitchen.activeOrdersCount}/${currentKitchen.maxOrderCapacity} Capacity',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: currentKitchen.isAtCapacity ? const Color(0xFFD97706) : AppTheme.emeraldGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Kitchen Profile Card
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentKitchen.brandTagline,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark),
                ),
                const SizedBox(height: 6),
                Text(
                  '📍 ${currentKitchen.address} • ${currentKitchen.distanceKm} km away',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _metricBadge(Icons.star, '${currentKitchen.rating} (${currentKitchen.totalReviews}+)'),
                    _metricBadge(Icons.timer, '${currentKitchen.averagePrepTimeMinutes}m avg prep'),
                    _metricBadge(
                      Icons.delivery_dining,
                      '~${currentKitchen.calculateEstimatedDeliveryMinutes()}m delivery',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Menu Section Header
          Text(
            'Kitchen Menu (${kitchenItems.length} items)',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
          ),
          const SizedBox(height: 12),

          if (kitchenItems.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: const Text('No dishes available right now in this kitchen.', style: TextStyle(color: AppTheme.textMuted)),
            )
          else
            ...kitchenItems.map((item) => _buildMenuItemCard(context, ref, currentKitchen, item)),
        ],
      ),
    );
  }

  Widget _metricBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.lightDivider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.primaryOrange),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 11, color: AppTheme.textDark, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildMenuItemCard(
    BuildContext context,
    WidgetRef ref,
    Kitchen kitchen,
    MenuItem item,
  ) {
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.emeraldGreen, width: 1.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.circle, size: 8, color: AppTheme.emeraldGreen),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${item.basePrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryOrange,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.description,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 13, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${item.preparationTimeMinutes} mins prep',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Dish Image & Add Button
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    item.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 80,
                      height: 80,
                      color: AppTheme.lightInput,
                      child: const Icon(Icons.fastfood, color: AppTheme.primaryOrange),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (!item.isAvailable)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Sold Out', style: TextStyle(color: AppTheme.dangerRed, fontSize: 11, fontWeight: FontWeight.bold)),
                  )
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryOrange,
                      side: const BorderSide(color: AppTheme.primaryOrange, width: 1.2),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      minimumSize: const Size(75, 32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      _openCustomizationModal(context, ref, kitchen, item);
                    },
                    child: Text(
                      item.customizationGroups.isNotEmpty ? 'ADD +' : 'ADD',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openCustomizationModal(
    BuildContext context,
    WidgetRef ref,
    Kitchen kitchen,
    MenuItem item,
  ) {
    if (item.customizationGroups.isEmpty) {
      ref.read(cartProvider.notifier).addItem(
            kitchen: kitchen,
            item: item,
            customizations: [],
          );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 1),
          content: Text('${item.name} added to cart!'),
        ),
      );
      return;
    }

    // Modal for customized portions and add-ons
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CustomizationSheet(kitchen: kitchen, item: item),
    );
  }
}

class _CustomizationSheet extends ConsumerStatefulWidget {
  final Kitchen kitchen;
  final MenuItem item;

  const _CustomizationSheet({required this.kitchen, required this.item});

  @override
  ConsumerState<_CustomizationSheet> createState() => _CustomizationSheetState();
}

class _CustomizationSheetState extends ConsumerState<_CustomizationSheet> {
  final List<CustomizationOption> _selectedOptions = [];

  @override
  void initState() {
    super.initState();
    for (final group in widget.item.customizationGroups) {
      if (group.isRequired && group.options.isNotEmpty) {
        _selectedOptions.add(group.options.first);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double extraSum = _selectedOptions.fold(0.0, (sum, o) => sum + o.extraPrice);
    final double totalPrice = widget.item.basePrice + extraSum;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customize ${widget.item.name}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppTheme.textDark),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(color: AppTheme.lightDivider),
          ...widget.item.customizationGroups.map((group) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    '${group.title} ${group.isRequired ? "(Required)" : "(Optional)"}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryOrange),
                  ),
                ),
                ...group.options.map((option) {
                  final isSelected = _selectedOptions.any((o) => o.id == option.id);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(option.name, style: const TextStyle(color: AppTheme.textDark)),
                    trailing: Text(
                      option.extraPrice > 0 ? '+₹${option.extraPrice.toStringAsFixed(0)}' : 'Free',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    leading: group.isRequired
                        ? Radio<String>(
                            value: option.id,
                            activeColor: AppTheme.primaryOrange,
                            groupValue: _selectedOptions
                                .firstWhere(
                                  (o) => group.options.any((go) => go.id == o.id),
                                  orElse: () => option,
                                )
                                .id,
                            onChanged: (val) {
                              setState(() {
                                _selectedOptions.removeWhere(
                                    (o) => group.options.any((go) => go.id == o.id));
                                _selectedOptions.add(option);
                              });
                            },
                          )
                        : Checkbox(
                            value: isSelected,
                            activeColor: AppTheme.primaryOrange,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedOptions.add(option);
                                } else {
                                  _selectedOptions.removeWhere((o) => o.id == option.id);
                                }
                              });
                            },
                          ),
                  );
                }),
              ],
            );
          }),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref.read(cartProvider.notifier).addItem(
                      kitchen: widget.kitchen,
                      item: widget.item,
                      customizations: _selectedOptions,
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 1),
                    content: Text('${widget.item.name} customized & added to cart!'),
                  ),
                );
              },
              child: Text('Add to Cart • ₹${totalPrice.toStringAsFixed(0)}'),
            ),
          ),
        ],
      ),
    );
  }
}
