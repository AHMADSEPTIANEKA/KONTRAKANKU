// lib/providers/user_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/models.dart' as models;

// 🔧 Model untuk User Data
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? role;
  final bool emailVerification;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> prefs;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role,
    required this.emailVerification,
    required this.createdAt,
    required this.updatedAt,
    required this.prefs,
  });

  factory UserModel.fromAppwriteUser(models.User user) {
    return UserModel(
      id: user.$id,
      name: user.name,
      email: user.email,
      phone: user.phone.isNotEmpty ? user.phone : null,
      role: user.prefs.data['role'] as String?,
      emailVerification: user.emailVerification,
      createdAt: DateTime.parse(user.$createdAt),
      updatedAt: DateTime.parse(user.$updatedAt),
      prefs: user.prefs.data,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    bool? emailVerification,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? prefs,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      emailVerification: emailVerification ?? this.emailVerification,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      prefs: prefs ?? this.prefs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'emailVerification': emailVerification,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'prefs': prefs,
    };
  }
}

// 🔧 Main User Provider
final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<UserModel?>>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  UserNotifier() : super(const AsyncValue.data(null));

  void setUser(models.User appwriteUser) {
    final userModel = UserModel.fromAppwriteUser(appwriteUser);
    state = AsyncValue.data(userModel);
  }

  void updateUser(UserModel user) {
    state = AsyncValue.data(user);
  }

  void updateUserRole(String role) {
    state.whenData((user) {
      if (user != null) {
        final updatedUser = user.copyWith(
          role: role,
          prefs: {...user.prefs, 'role': role},
        );
        state = AsyncValue.data(updatedUser);
      }
    });
  }

  void updateUserProfile({
    String? name,
    String? phone,
  }) {
    state.whenData((user) {
      if (user != null) {
        final updatedUser = user.copyWith(
          name: name ?? user.name,
          phone: phone ?? user.phone,
        );
        state = AsyncValue.data(updatedUser);
      }
    });
  }

  void clearUser() {
    state = const AsyncValue.data(null);
  }

  void setLoading() {
    state = const AsyncValue.loading();
  }

  void setError(Object error, StackTrace stackTrace) {
    state = AsyncValue.error(error, stackTrace);
  }
}

// 🔧 Convenience providers untuk akses cepat
final userRoleProvider = Provider<String?>((ref) {
  final userAsync = ref.watch(userProvider);
  return userAsync.when(
    data: (user) => user?.role,
    loading: () => null,
    error: (_, __) => null,
  );
});

final userNameProvider = Provider<String?>((ref) {
  final userAsync = ref.watch(userProvider);
  return userAsync.when(
    data: (user) => user?.name,
    loading: () => null,
    error: (_, __) => null,
  );
});

final userEmailProvider = Provider<String?>((ref) {
  final userAsync = ref.watch(userProvider);
  return userAsync.when(
    data: (user) => user?.email,
    loading: () => null,
    error: (_, __) => null,
  );
});

final isEmailVerifiedProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(userProvider);
  return userAsync.when(
    data: (user) => user?.emailVerification ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});

// 🔧 Extension untuk kemudahan akses
extension UserProviderX on WidgetRef {
  UserModel? get currentUser {
    final userState = watch(userProvider);
    return userState.when(
      data: (user) => user,
      loading: () => null,
      error: (_, __) => null,
    );
  }

  String? get userRole {
    return currentUser?.role;
  }

  String? get userName {
    return currentUser?.name;
  }

  String? get userEmail {
    return currentUser?.email;
  }

  bool get isEmailVerified {
    return currentUser?.emailVerification ?? false;
  }

  bool get hasRole {
    final role = userRole;
    return role != null && role.isNotEmpty;
  }

  bool get isOwner {
    return userRole?.toLowerCase() == 'owner';
  }

  bool get isRenter {
    return userRole?.toLowerCase() == 'renter';
  }
}