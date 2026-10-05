import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../auth/presentation/auth_controller.dart';
import '../auth/presentation/profile_modal.dart';
import '../auth/domain/user_role.dart';
import '../data/kitchen_repository.dart';

class RoleSwitchHeader extends ConsumerWidget {
  const RoleSwitchHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(userSessionProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.lightSurface,
        border: const Border(
          bottom: BorderSide(color: AppTheme.lightDivider, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 520;

            if (isMobile) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Row: Brand & Unified Profile/Role Button (Single Right Action)
                  Row(
                    children: [
                      // Swiggy Brand Icon
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primaryOrange, AppTheme.primaryAmber],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.soup_kitchen, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 8),
                      const Flexible(
                        child: Text(
                          'CloudKitchen OS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppTheme.textDark,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // UNIFIED PROFILE & ROLE BUTTON (Contains Profile, Role Switcher & Logout)
                      Flexible(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _buildUnifiedProfileButton(context, ref, session),
                        ),
                      ),
                    ],
                  ),

                  // Sub Row on Mobile: Portal label + Swiggy One Toggle
                  if (session.activeRole == UserRole.customer) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppTheme.emeraldGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Flexible(
                                child: Text(
                                  'Customer Portal',
                                  style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildSwiggyOneToggle(context, ref, session),
                      ],
                    ),
                  ],
                ],
              );
            }

            // Desktop / Tablet Layout: Single Row
            return Row(
              children: [
                // Swiggy Brand Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryOrange, AppTheme.primaryAmber],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.soup_kitchen, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'CloudKitchen OS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Portal: ${session.activeRole.displayName}',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const Spacer(),

                // Swiggy One Membership Toggle
                if (session.activeRole == UserRole.customer) ...[
                  _buildSwiggyOneToggle(context, ref, session),
                  const SizedBox(width: 12),
                ],

                // UNIFIED PROFILE & ROLE BUTTON (Contains Profile, Role Switcher & Logout)
                _buildUnifiedProfileButton(context, ref, session),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Single Unified Profile Button on the Header
  /// Clicking this opens the full profile modal which includes profile details, role switcher, and logout.
  Widget _buildUnifiedProfileButton(BuildContext context, WidgetRef ref, UserSessionState session) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final initial = (user != null && user.fullName.isNotEmpty)
        ? user.fullName[0].toUpperCase()
        : (session.userName.isNotEmpty ? session.userName[0].toUpperCase() : 'U');

    return Tooltip(
      message: 'View Profile, Switch Role & Logout',
      child: InkWell(
        onTap: () => UserProfileModal.show(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.primaryOrange.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primaryOrange.withOpacity(0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppTheme.primaryOrange,
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  session.activeRole.displayName,
                  style: const TextStyle(
                    color: AppTheme.primaryOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, size: 16, color: AppTheme.primaryOrange),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwiggyOneToggle(BuildContext context, WidgetRef ref, UserSessionState session) {
    return InkWell(
      onTap: () {
        ref.read(userSessionProvider.notifier).toggleSubscription();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text(
              session.isPremiumMember
                  ? 'Swiggy One Membership Paused'
                  : 'Swiggy One Activated: 100% Free Delivery on all Cloud Kitchens!',
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: session.isPremiumMember
              ? AppTheme.swiggyOneBg
              : AppTheme.lightInput,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: session.isPremiumMember
                ? AppTheme.swiggyOneGold.withOpacity(0.5)
                : AppTheme.lightDivider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.stars,
              size: 14,
              color: session.isPremiumMember
                  ? AppTheme.swiggyOneGold
                  : AppTheme.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              session.isPremiumMember ? 'Swiggy One' : 'Standard',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: session.isPremiumMember
                    ? const Color(0xFFB7791F)
                    : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
