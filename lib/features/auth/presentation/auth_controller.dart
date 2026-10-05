import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../domain/app_user.dart';
import '../domain/user_role.dart';
import '../../data/kitchen_repository.dart';

// Authentication Repository Provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return InMemoryAuthRepository();
});

// Authentication State
class AuthState {
  final bool isLoading;
  final AppUser? user;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    AppUser? user,
    String? errorMessage,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// Authentication Controller
class AuthController extends Notifier<AuthState> {
  late final IAuthRepository _repo;

  @override
  AuthState build() {
    _repo = ref.read(authRepositoryProvider);
    return const AuthState();
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repo.signInWithEmailAndPassword(email, password);

      // Sync active role with the userSessionProvider
      ref.read(userSessionProvider.notifier).setRole(user.role);

      state = state.copyWith(
        isLoading: false,
        user: user,
        clearError: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _repo.signOut();
    state = const AuthState(user: null, isLoading: false);
  }

  void quickLoginWithDemoUser(AppUser demoUser) {
    login(demoUser.email, 'password123');
  }

  void switchRoleForDevelopment(UserRole newRole) {
    if (state.user != null) {
      final updatedUser = state.user!.copyWith(role: newRole);
      ref.read(userSessionProvider.notifier).setRole(newRole);
      state = state.copyWith(user: updatedUser);
    }
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
