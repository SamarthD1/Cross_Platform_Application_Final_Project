enum UserRole {
  customer,
  vendor,
  delivery,
  admin,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.vendor:
        return 'Kitchen (Vendor)';
      case UserRole.delivery:
        return 'Delivery Partner';
      case UserRole.admin:
        return 'Admin Portal';
    }
  }

  String get description {
    switch (this) {
      case UserRole.customer:
        return 'Discover kitchens, customize dishes & track orders';
      case UserRole.vendor:
        return 'Manage menus, control kitchen capacity & live dispatch';
      case UserRole.delivery:
        return 'Accept delivery tasks & update live route tracking';
      case UserRole.admin:
        return 'Monitor platform GMV, commissions & vendor network';
    }
  }
}
