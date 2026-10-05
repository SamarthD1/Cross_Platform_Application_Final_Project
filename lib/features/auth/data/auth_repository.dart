import '../domain/app_user.dart';
import '../domain/user_role.dart';

abstract class IAuthRepository {
  AppUser? get currentUser;
  Future<AppUser> signInWithEmailAndPassword(String email, String password);
  Future<AppUser?> getUserProfile(String uid);
  Future<void> signOut();
  List<AppUser> get demoUsers;
}

/// Production-ready in-memory authentication repository with seeded dummy users.
/// Demonstrates the exact Firestore schema and role-fetching contract, allowing
/// immediate testing of GoRouter redirect & protection without requiring external API keys.
class InMemoryAuthRepository implements IAuthRepository {
  AppUser? _currentUser;

  // The 4 test dummy accounts matching the Firestore NoSQL schema
  final Map<String, ({AppUser user, String password})> _usersDatabase = {
    'customer@cloudkitchen.com': (
      user: const AppUser(
        uid: 'cust_101_rahul',
        email: 'customer@cloudkitchen.com',
        fullName: 'Rahul Sharma',
        phoneNumber: '+91 98765 43210',
        role: UserRole.customer,
        isPremiumMember: true,
      ),
      password: 'password123',
    ),
    'vendor@cloudkitchen.com': (
      user: const AppUser(
        uid: 'vend_202_aslam',
        email: 'vendor@cloudkitchen.com',
        fullName: 'Chef Aslam Khan',
        phoneNumber: '+91 98765 43211',
        role: UserRole.vendor,
        assignedKitchenId: 'k_nawabi_indiranagar',
      ),
      password: 'password123',
    ),
    'delivery@cloudkitchen.com': (
      user: const AppUser(
        uid: 'deli_303_vikram',
        email: 'delivery@cloudkitchen.com',
        fullName: 'Vikram Singh (Rider)',
        phoneNumber: '+91 98765 43212',
        role: UserRole.delivery,
        vehicleType: 'EV Two-Wheeler',
        isDutyOn: true,
      ),
      password: 'password123',
    ),
    'admin@cloudkitchen.com': (
      user: const AppUser(
        uid: 'admn_404_super',
        email: 'admin@cloudkitchen.com',
        fullName: 'Priya Iyer (Super Admin)',
        phoneNumber: '+91 98765 43213',
        role: UserRole.admin,
      ),
      password: 'password123',
    ),
  };

  @override
  AppUser? get currentUser => _currentUser;

  @override
  List<AppUser> get demoUsers => _usersDatabase.values.map((v) => v.user).toList();

  @override
  Future<AppUser> signInWithEmailAndPassword(String email, String password) async {
    // Simulate real network/database latency
    await Future.delayed(const Duration(milliseconds: 300));

    final normalizedEmail = email.trim().toLowerCase();
    final entry = _usersDatabase[normalizedEmail];

    if (entry == null) {
      throw Exception('No account found with $email. Please use one of the test dummy credentials below.');
    }

    if (entry.password != password.trim()) {
      throw Exception('Incorrect password. For testing, use "password123".');
    }

    _currentUser = entry.user;
    return entry.user;
  }

  @override
  Future<AppUser?> getUserProfile(String uid) async {
    for (final entry in _usersDatabase.values) {
      if (entry.user.uid == uid) {
        return entry.user;
      }
    }
    return null;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _currentUser = null;
  }
}
