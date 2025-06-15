import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../auth/login_page.dart';
import '../home/home_owner_page.dart';
import '../home/home_renter_page.dart';
import 'package:app_kontrakan_ku/providers/user_provider.dart';

enum AuthStatus { authenticated, unauthenticated }

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  late final ProviderSubscription _authSub;

  @override
  void initState() {
    super.initState();

    // Gunakan listenManual untuk mendengarkan authProvider
    _authSub = ref.listenManual<AsyncValue<bool>>(authProvider, (previous, next) {
      next.when(
        data: (isAuthenticated) {
          final status =
              isAuthenticated ? AuthStatus.authenticated : AuthStatus.unauthenticated;

          if (status == AuthStatus.authenticated) {
            final role = ref.read(userRoleProvider);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              if (role == 'owner') {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomeOwnerPage()),
                );
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomeRenterPage()),
                );
              }
            });
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            });
          }
        },
        loading: () {
          // Optional: bisa tampilkan loading atau abaikan
        },
        error: (err, stack) {
          // Optional: tampilkan error page atau log
        },
      );
    });
  }

  @override
  void dispose() {
    _authSub.close(); // Penting untuk mencegah memory leak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
