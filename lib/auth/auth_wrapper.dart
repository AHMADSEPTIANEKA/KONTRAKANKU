import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';
import '../pages/home_page.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    // Jika user != null → sudah login, tampilkan HomePage.
    // Jika null → tampilkan LoginPage.
    if (user != null) {
      return const HomePage();
    } else {
      return const LoginPage();
    }
  }
}
