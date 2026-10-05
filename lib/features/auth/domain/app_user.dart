import 'user_role.dart';

class AppUser {
  final String uid;
  final String email;
  final String fullName;
  final String phoneNumber;
  final UserRole role;
  final String? assignedKitchenId; // Applicable for vendor role
  final bool isPremiumMember;      // Swiggy One membership for customer
  final String? vehicleType;       // Applicable for delivery partner
  final bool isDutyOn;             // Applicable for delivery partner

  const AppUser({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
    this.phoneNumber = '',
    this.assignedKitchenId,
    this.isPremiumMember = false,
    this.vehicleType,
    this.isDutyOn = false,
  });

  factory AppUser.fromMap(Map<String, dynamic> data, String uid) {
    return AppUser(
      uid: uid,
      email: data['email'] as String? ?? '',
      fullName: data['fullName'] as String? ?? 'User',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      role: parseRole(data['role'] as String?),
      assignedKitchenId: data['assignedKitchenId'] as String?,
      isPremiumMember: data['isPremiumMember'] as bool? ?? false,
      vehicleType: data['vehicleType'] as String?,
      isDutyOn: data['isDutyOn'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'role': role.name,
      'assignedKitchenId': assignedKitchenId,
      'isPremiumMember': isPremiumMember,
      'vehicleType': vehicleType,
      'isDutyOn': isDutyOn,
    };
  }

  static UserRole parseRole(String? roleStr) {
    switch (roleStr?.toLowerCase().trim()) {
      case 'vendor':
      case 'kitchen':
        return UserRole.vendor;
      case 'delivery':
        return UserRole.delivery;
      case 'admin':
        return UserRole.admin;
      case 'customer':
      default:
        return UserRole.customer;
    }
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? phoneNumber,
    UserRole? role,
    String? assignedKitchenId,
    bool? isPremiumMember,
    String? vehicleType,
    bool? isDutyOn,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      assignedKitchenId: assignedKitchenId ?? this.assignedKitchenId,
      isPremiumMember: isPremiumMember ?? this.isPremiumMember,
      vehicleType: vehicleType ?? this.vehicleType,
      isDutyOn: isDutyOn ?? this.isDutyOn,
    );
  }
}
