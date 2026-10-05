import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'customer@cloudkitchen.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.disposeNavigator();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillCredentials(String email, String password) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).login(
          _emailController.text,
          _passwordController.text,
        );

    if (!success && mounted) {
      final error = ref.read(authControllerProvider).errorMessage ?? 'Login failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.lightDivider),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Logo & Header
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primaryOrange, AppTheme.primaryAmber],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryOrange.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.soup_kitchen, color: Colors.white, size: 36),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'CloudKitchen OS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Multi-Vendor FoodTech Platform • Secure Role-Based Access',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 24),

                    // Error Message Banner (if any)
                    if (authState.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppTheme.dangerRed, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                authState.errorMessage!,
                                style: const TextStyle(fontSize: 12, color: AppTheme.dangerRed, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Email Field
                    const Text('Email Address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textMuted, size: 20),
                        hintText: 'name@cloudkitchen.com',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Please enter your email';
                        if (!val.contains('@')) return 'Enter a valid email address';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    const Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textMuted, size: 20),
                        hintText: '••••••••',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: AppTheme.textMuted,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Please enter your password';
                        if (val.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 22),

                    // Sign In Button
                    ElevatedButton(
                      onPressed: authState.isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text(
                              'Sign In to Dashboard',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                    ),
                    const SizedBox(height: 24),

                    const Divider(color: AppTheme.lightDivider),
                    const SizedBox(height: 14),

                    // Quick-Test Dummy Accounts Section
                    Row(
                      children: [
                        const Icon(Icons.touch_app, size: 16, color: AppTheme.primaryOrange),
                        const SizedBox(width: 6),
                        const Text(
                          'Test Pre-Seeded Role Accounts:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tap any role below to pre-fill credentials and test GoRouter automatic redirection:',
                      style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 12),

                    // 4 Dummy Role Buttons
                    _buildRoleQuickPill(
                      roleName: 'Customer',
                      email: 'customer@cloudkitchen.com',
                      routeDesc: 'Routes to /customer (Order Food, Swiggy One)',
                      icon: Icons.person_outline,
                      color: const Color(0xFF2563EB),
                    ),
                    const SizedBox(height: 8),
                    _buildRoleQuickPill(
                      roleName: 'Kitchen (Vendor)',
                      email: 'vendor@cloudkitchen.com',
                      routeDesc: 'Routes to /vendor (Live Orders, Throttle Control)',
                      icon: Icons.storefront,
                      color: AppTheme.primaryOrange,
                    ),
                    const SizedBox(height: 8),
                    _buildRoleQuickPill(
                      roleName: 'Delivery Partner',
                      email: 'delivery@cloudkitchen.com',
                      routeDesc: 'Routes to /delivery (Trip Stepper, Radar Dispatch)',
                      icon: Icons.delivery_dining,
                      color: AppTheme.emeraldGreen,
                    ),
                    const SizedBox(height: 8),
                    _buildRoleQuickPill(
                      roleName: 'Platform Admin',
                      email: 'admin@cloudkitchen.com',
                      routeDesc: 'Routes to /admin (GMV, Commissions, Take-Rates)',
                      icon: Icons.admin_panel_settings,
                      color: const Color(0xFF7C3AED),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleQuickPill({
    required String roleName,
    required String email,
    required String routeDesc,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _emailController.text.trim().toLowerCase() == email;

    return InkWell(
      onTap: () {
        _fillCredentials(email, 'password123');
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : AppTheme.lightDivider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    children: [
                      Text(
                        roleName,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color),
                      ),
                      Text(
                        '($email)',
                        style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                  Text(
                    routeDesc,
                    style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, size: 16, color: color)
            else
              const Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

extension on TextEditingController {
  void disposeNavigator() {}
}
