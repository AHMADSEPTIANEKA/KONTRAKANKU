import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart';
import '../utils/appwrite_client.dart';
import 'user_provider.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<bool>>((ref) {
  return AuthNotifier(ref);
});

final authErrorProvider = StateProvider<String?>((ref) => null);
final authLoadingProvider = StateProvider<bool>((ref) => false);

class AuthNotifier extends StateNotifier<AsyncValue<bool>> {
  final Ref ref;
  late final Account account;

  AuthNotifier(this.ref) : super(const AsyncValue.loading()) {
    final client = ref.read(appwriteClientProvider);
    account = Account(client);
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final user = await account.get();
      ref.read(userProvider.notifier).setUser(user);
      state = const AsyncValue.data(true);
    } catch (_) {
      state = const AsyncValue.data(false);
    }
  }

  Future<String> login({required String email, required String password}) async {
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;

    try {
      await account.createEmailSession(email: email, password: password);
      final user = await account.get();
      ref.read(userProvider.notifier).setUser(user);
      state = const AsyncValue.data(true);

      final role = user.prefs.data['role'] as String?;

      if (role == 'owner' || role == 'renter') {
        return role!;
      } else {
        throw Exception('Role pengguna tidak ditemukan atau tidak valid');
      }
    } catch (e) {
      ref.read(authErrorProvider.notifier).state = _getErrorMessage(e);
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;

    try {
      // Buat akun
      await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );

      // Login sementara
      await account.createEmailSession(email: email, password: password);

      // Simpan role ke prefs
      await account.updatePrefs(prefs: {'role': role});

      // Logout lagi
      await account.deleteSession(sessionId: 'current');

      state = const AsyncValue.data(false);
      return true;
    } catch (e) {
      ref.read(authErrorProvider.notifier).state = _getErrorMessage(e);
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  Future<void> logout() async {
    try {
      await account.deleteSessions();
    } catch (_) {}
    ref.read(userProvider.notifier).clearUser();
    state = const AsyncValue.data(false);
    ref.read(authErrorProvider.notifier).state = null;
  }

  Future<void> refreshAuth() async {
    state = const AsyncValue.loading();
    await _checkAuth();
  }

  Future<bool> updateUserRole(String role) async {
    try {
      await account.updatePrefs(prefs: {'role': role});
      final user = await account.get();
      ref.read(userProvider.notifier).setUser(user);
      return true;
    } catch (e) {
      ref.read(authErrorProvider.notifier).state = _getErrorMessage(e);
      return false;
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is AppwriteException) {
      switch (error.code) {
        case 401:
          return 'Email atau password tidak valid';
        case 409:
          return 'Email sudah terdaftar';
        case 429:
          return 'Terlalu banyak percobaan, coba lagi nanti';
        default:
          return error.message ?? 'Terjadi kesalahan yang tidak diketahui';
      }
    }
    return error.toString();
  }
}
