import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart';

// Provider global untuk Appwrite Client
final appwriteClientProvider = Provider<Client>((ref) {
  throw UnimplementedError(); // Akan dioverride di main.dart
});
