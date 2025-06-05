import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

/// Provider untuk Appwrite Client (di‐override di main.dart)
final appwriteClientProvider = Provider<Client>((ref) {
  throw UnimplementedError();
});

/// Provider untuk service Account (Appwrite Auth)
final accountProvider = Provider<Account>((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Account(client);
});

/// StateProvider menampung data user yang sedang login (null kalau belum)
final currentUserProvider = StateProvider<User?>((ref) => null);

/// AuthController: register, login, logout, cek session
class AuthController {
  final Ref _ref;
  AuthController(this._ref);

  Account get _account => _ref.read(accountProvider);

  /// Cek session user saat aplikasi dijalankan (dipanggil SplashScreen)
  Future<void> checkCurrentUser(WidgetRef ref) async {
    try {
      final User user = await _account.get();
      ref.read(currentUserProvider.notifier).state = user;
    } on AppwriteException {
      // Jika tidak ada session aktif, tetap null
      ref.read(currentUserProvider.notifier).state = null;
    }
  }

  /// Register dengan email & password
  Future<void> register({
    required String email,
    required String password,
  }) async {
    await _account.create(
      userId: ID.unique(),
      email: email.trim(),
      password: password.trim(),
    );
    // Setelah berhasil register, Appwrite otomatis membuat session baru
  }

  /// Login dengan email & password (gunakan createEmailSession)
  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _account.createEmailSession(
      email: email.trim(),
      password: password.trim(),
    );
  }

  /// Logout (hapus session 'current')
  Future<void> logout() async {
    await _account.deleteSession(sessionId: 'current');
  }
}

/// Provider untuk instance AuthController
final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});
