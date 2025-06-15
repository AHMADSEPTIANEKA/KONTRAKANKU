import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart';

// Import file lokal
import 'utils/appwrite_client.dart';
import 'pages/shared/splash_screen.dart';
import 'auth/login_page.dart';
import 'auth/register_page.dart';
import 'auth/forgot_password_page.dart';
import 'auth/reset_password_page.dart';
import 'pages/home/home_owner_page.dart';
import 'pages/home/home_renter_page.dart';
import 'pages/property/add_property_page.dart';
import 'pages/property/edit_property_page.dart'; 
import 'pages/property/property_detail_page.dart';

import 'package:appwrite/models.dart'; // untuk Document (edit page args)

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final client = Client()
    ..setEndpoint('https://cloud.appwrite.io/v1') // Ganti dengan endpoint kamu
    ..setProject('684bd5b80002c683fadf'); // Ganti dengan Project ID kamu

  runApp(
    ProviderScope(
      overrides: [appwriteClientProvider.overrideWithValue(client)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kontrakan App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),

      // 🧭 Routing dinamis
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '');

        // 🔐 Reset Password via email link
        if (uri.path == '/reset-password' &&
            uri.queryParameters.containsKey('userId') &&
            uri.queryParameters.containsKey('secret')) {
          final userId = uri.queryParameters['userId']!;
          final secret = uri.queryParameters['secret']!;
          return MaterialPageRoute(
            builder: (_) => ResetPasswordPage(userId: userId, secret: secret),
          );
        }

        // 🧭 Routing statis & dengan arguments
        switch (uri.path) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterPage());
          case '/forgot-password':
            return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
          case '/home-owner':
            return MaterialPageRoute(builder: (_) => const HomeOwnerPage());
          case '/home-renter':
            return MaterialPageRoute(builder: (_) => const HomeRenterPage());
          case '/add-property':
            return MaterialPageRoute(builder: (_) => const AddPropertyPage());
          case '/edit-property':
            final doc = settings.arguments as Document;
            return MaterialPageRoute(
              builder: (_) => EditPropertyPage(property: doc),
            );
          case '/property-detail':
            final doc = settings.arguments as Document;
            return MaterialPageRoute(
              builder: (_) => PropertyDetailPage(property: doc),
            );
          default:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
      },

      // Halaman awal
      home: const SplashScreen(),
    );
  }
}
