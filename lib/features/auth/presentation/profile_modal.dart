import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../domain/app_user.dart';
import '../domain/user_role.dart';
import 'auth_controller.dart';
import '../../data/kitchen_repository.dart';

class UserProfileModal extends ConsumerWidget {
  const UserProfileModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const UserProfileModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final session = ref.watch(userSessionProvider);
    final user = authState.user ??
        AppUser(
          uid: 'demo_session',
          email: 'user@cloudkitchen.com',
          fullName: session.userName,
          role: session.activeRole,
          phoneNumber: '+91 98765 43210',
          isPremiumMember: session.isPremiumMember,
        );

    final roleColor = _getRoleColor(user.role);

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Title Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'User Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.dangerRed,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            backgroundColor: const Color(0xFFFEE2E2).withOpacity(0.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.logout, size: 15),
                          label: const Text('Sign Out', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          onPressed: () async {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            Navigator.of(context).pop();
                            await ref.read(authControllerProvider.notifier).logout();
                            if (context.mounted) {
                              context.go('/login');
                            }
                          },
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppTheme.textMuted, size: 22),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppTheme.lightDivider),

              // Scrollable Profile Details
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Profile Header Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [roleColor.withOpacity(0.08), Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: roleColor.withOpacity(0.25)),
                      ),
                      child: Row(
                        children: [
                          // Avatar Circle
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: roleColor,
                            child: Text(
                              user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.fullName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user.email,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: roleColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    user.role.displayName.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: roleColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Contact & Identification Info
                    _buildSectionHeader('Account Information'),
                    _buildInfoTile(
                      icon: Icons.badge_outlined,
                      title: 'User UID',
                      subtitle: user.uid,
                    ),
                    _buildInfoTile(
                      icon: Icons.phone_outlined,
                      title: 'Phone Number',
                      subtitle: user.phoneNumber.isNotEmpty ? user.phoneNumber : '+91 98765 43210',
                    ),
                    const SizedBox(height: 20),

                    // Role-Specific Capabilities & Controls
                    _buildSectionHeader('${user.role.displayName} Workspace Details'),
                    _buildRoleSpecificContent(context, ref, user),
                    const SizedBox(height: 24),

                    // Switch Role for Evaluation (Demo convenience)
                    _buildSectionHeader('Switch Workspace Role'),
                    const Text(
                      'Quickly preview other role perspectives in the platform:',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: UserRole.values.map((r) {
                        final isSelected = r == user.role;
                        final color = _getRoleColor(r);
                        return ChoiceChip(
                          label: Text(r.displayName),
                          selected: isSelected,
                          selectedColor: color.withOpacity(0.2),
                          side: BorderSide(
                            color: isSelected ? color : AppTheme.lightDivider,
                          ),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? color : AppTheme.textDark,
                          ),
                          onSelected: (_) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ref.read(userSessionProvider.notifier).setRole(r);
                            ref.read(authControllerProvider.notifier).switchRoleForDevelopment(r);
                            Navigator.of(context).pop();
                            // Immediately clear any pushed customer/sub-screens (e.g. OrderTrackingView)
                            shellNavigatorKey.currentState?.popUntil((route) => route.isFirst);
                            context.go(getDashboardPathForRole(r));
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),

                    // Sign Out Button
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.dangerRed,
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: const Color(0xFFFEE2E2).withOpacity(0.4),
                      ),
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('Sign Out of CloudKitchen OS', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        Navigator.of(context).pop();
                        shellNavigatorKey.currentState?.popUntil((route) => route.isFirst);
                        await ref.read(authControllerProvider.notifier).logout();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppTheme.textDark,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightDivider),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  Widget _buildRoleSpecificContent(BuildContext context, WidgetRef ref, AppUser user) {
    switch (user.role) {
      case UserRole.customer:
        return Column(
          children: [
            _buildInfoTile(
              icon: Icons.stars,
              title: 'Swiggy One Membership',
              subtitle: user.isPremiumMember
                  ? 'Active: 100% Free Delivery on all Cloud Kitchens'
                  : 'Standard Tier (Delivery charges apply)',
              trailing: Switch(
                value: user.isPremiumMember,
                activeTrackColor: AppTheme.swiggyOneGold,
                onChanged: (_) {
                  ref.read(userSessionProvider.notifier).toggleSubscription();
                },
              ),
            ),
            _buildInfoTile(
              icon: Icons.location_on_outlined,
              title: 'Primary Delivery Location',
              subtitle: '14th Main Rd, Indiranagar, Bengaluru - 560038',
            ),
            _buildInfoTile(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Swiggy Money & Foodie Credits',
              subtitle: '₹250.00 Available Balance',
            ),
          ],
        );

      case UserRole.vendor:
        return Column(
          children: [
            _buildInfoTile(
              icon: Icons.storefront,
              title: 'Assigned Kitchen Pod',
              subtitle: 'Nawabi Dum Cloud Kitchen (Indiranagar Hub 04)',
            ),
            _buildInfoTile(
              icon: Icons.speed,
              title: 'Kitchen Throttle Controller',
              subtitle: 'Max capacity: 12 concurrent live orders',
            ),
            _buildInfoTile(
              icon: Icons.percent,
              title: 'Platform Take-Rate Agreement',
              subtitle: '20% commission per completed order',
            ),
          ],
        );

      case UserRole.delivery:
        return Column(
          children: [
            _buildInfoTile(
              icon: Icons.two_wheeler,
              title: 'Delivery Fleet Vehicle',
              subtitle: 'EV Two-Wheeler (Hero Splendor / Ather 450X)',
            ),
            _buildInfoTile(
              icon: Icons.offline_bolt_outlined,
              title: 'Current Duty Mode',
              subtitle: 'On Duty • Live Radar Trips Enabled',
            ),
            _buildInfoTile(
              icon: Icons.currency_rupee,
              title: 'Today\'s Total Trip Earnings',
              subtitle: '₹350.00 (7 orders fulfilled)',
            ),
          ],
        );

      case UserRole.admin:
        return Column(
          children: [
            _buildInfoTile(
              icon: Icons.security,
              title: 'Platform Permissions Level',
              subtitle: 'SUPER_ADMIN • Full Multi-Vendor Ledger Access',
            ),
            _buildInfoTile(
              icon: Icons.hub_outlined,
              title: 'Managed Hubs',
              subtitle: '3 Operational Hubs (Indiranagar, Koramangala, Whitefield)',
            ),
            _buildInfoTile(
              icon: Icons.tune,
              title: 'Dynamic Commission Controls',
              subtitle: 'Active tiered take-rate sliders: 15% to 30%',
            ),
          ],
        );
    }
  }

  static Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return const Color(0xFF2563EB);
      case UserRole.vendor:
        return AppTheme.primaryOrange;
      case UserRole.delivery:
        return AppTheme.emeraldGreen;
      case UserRole.admin:
        return const Color(0xFF7C3AED);
    }
  }
}
