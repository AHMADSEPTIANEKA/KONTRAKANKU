import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import '../utils/appwrite_client.dart';

class PropertyNotifier extends StateNotifier<AsyncValue<List<Document>>> {
  PropertyNotifier(this.ref)
      : _db = Databases(ref.read(appwriteClientProvider)),
        super(const AsyncLoading()) {
    fetchProperties(); // ambil data awal
  }

  final Ref ref;
  final Databases _db;
  final String databaseId = '684d0e3c0039eb16c09d';
  final String collectionId = 'properti';

  Future<void> fetchProperties() async {
    try {
      final response = await _db.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
      );
      state = AsyncData(response.documents);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> addProperty(Map<String, dynamic> data) async {
    try {
      await _db.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: ID.unique(),
        data: data,
      );
      await fetchProperties();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateProperty(String id, Map<String, dynamic> data) async {
    try {
      await _db.updateDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: id,
        data: data,
      );
      await fetchProperties();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteProperty(String id) async {
    try {
      await _db.deleteDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: id,
      );
      await fetchProperties();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> toggleStatus(String id, String currentStatus) async {
    final newStatus = currentStatus == 'Tersedia' ? 'Disewa' : 'Tersedia';
    try {
      await _db.updateDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: id,
        data: {'status': newStatus},
      );
      await fetchProperties();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
final propertyListProvider = StateNotifierProvider<PropertyNotifier, AsyncValue<List<Document>>>(
  (ref) => PropertyNotifier(ref),
);
