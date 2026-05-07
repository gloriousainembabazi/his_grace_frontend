// lib/models/user.dart

class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String address;
  final bool isActive;
  final bool isAdmin;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.address = '',
    this.isActive = true,
    this.isAdmin = false,
  });

  String get fullName => '$firstName $lastName'.trim();

  /// Derived role label used by profile and staff screens.
  String get role => isAdmin ? 'admin' : 'staff';

  String get initials {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    }
    if (firstName.isNotEmpty) {
      return firstName[0].toUpperCase();
    }
    if (username.isNotEmpty) {
      return username[0].toUpperCase();
    }
    return 'U';
  }

  /// Check if user has admin permissions
  bool get canManageStaff => isAdmin;
  bool get canManageExpenses => isAdmin;
  bool get canViewReports => isAdmin;
  bool get canManageInventory => isAdmin;
  bool get canProcessSales => true; // All logged-in users can process sales

  factory User.fromJson(Map<String, dynamic> json) {
    // Determine admin status from role or is_staff field
    bool isAdminUser = false;
    
    if (json['role'] != null) {
      isAdminUser = json['role'] == 'admin';
    } else if (json['is_staff'] != null) {
      isAdminUser = json['is_staff'] == true;
    } else if (json['is_admin'] != null) {
      isAdminUser = json['is_admin'] == true;
    }
    
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? json['firstName'] ?? '',
      lastName: json['last_name'] ?? json['lastName'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      isActive: json['is_active'] ?? true,
      isAdmin: isAdminUser,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'address': address,
        'is_active': isActive,
        'is_staff': isAdmin,
        'role': role,
      };
}