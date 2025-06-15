import 'dart:io' show File, Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../../../utils/appwrite_client.dart';

class AddPropertyPage extends ConsumerStatefulWidget {
  const AddPropertyPage({super.key});

  @override
  ConsumerState<AddPropertyPage> createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends ConsumerState<AddPropertyPage> {
  final _formKey = GlobalKey<FormState>();

  final namaController = TextEditingController();
  final lokasiController = TextEditingController();
  final hargaController = TextEditingController();
  final deskripsiController = TextEditingController();
  final kamarController = TextEditingController();
  final kamarMandiController = TextEditingController();
  final luasBangunanController = TextEditingController();
  final luasTanahController = TextEditingController();
  final fasilitasController = TextEditingController();

  File? selectedImage;
  bool isLoading = false;

  Future<void> pilihGambar() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Fitur pilih gambar hanya tersedia di Android/iOS'),
          backgroundColor: Colors.orange.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> uploadGambar(File file) async {
    final client = ref.read(appwriteClientProvider);
    final storage = Storage(client);

    final fileName = path.basename(file.path);
    final result = await storage.createFile(
      bucketId: 'bucket_gambar',
      fileId: ID.unique(),
      file: InputFile.fromPath(path: file.path, filename: fileName),
    );

    return result.$id;
  }

  Future<void> tambahProperti() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final client = ref.read(appwriteClientProvider);
      final databases = Databases(client);
      final account = Account(client);
      final user = await account.get();

      String? imageFileId;
      if (selectedImage != null) {
        imageFileId = await uploadGambar(selectedImage!);
      }

      await databases.createDocument(
        databaseId: '684d0e3c0039eb16c09d',
        collectionId: 'properti',
        documentId: ID.unique(),
        data: {
          'nama': namaController.text,
          'lokasi': lokasiController.text,
          'harga_per_bulan': int.tryParse(hargaController.text) ?? 0,
          'status': 'Tersedia',
          'pemilik_id': user.$id,
          'deskripsi': deskripsiController.text,
          'jumlah_kamar': int.tryParse(kamarController.text) ?? 0,
          'jumlah_kamar_mandi': int.tryParse(kamarMandiController.text) ?? 0,
          'luas_bangunan': int.tryParse(luasBangunanController.text) ?? 0,
          'luas_tanah': int.tryParse(luasTanahController.text) ?? 0,
          'fasilitas': fasilitasController.text,
          'gambar_url': imageFileId ?? '',
          'tanggal_dibuat': DateTime.now().toUtc().toIso8601String(),
        },
        permissions: [
          Permission.read(Role.user(user.$id)),
          Permission.update(Role.user(user.$id)),
          Permission.delete(Role.user(user.$id)),
        ],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Properti berhasil ditambahkan!'),
              ],
            ),
            backgroundColor: Colors.green.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Gagal menambah properti: $e')),
              ],
            ),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Tambah Properti', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey.shade200,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildSectionHeader('Informasi Dasar', Icons.home_outlined),
                const SizedBox(height: 16),
                
                _buildModernCard([
                  _buildModernTextField(
                    namaController, 
                    'Nama Properti', 
                    Icons.business_outlined,
                    true
                  ),
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    lokasiController, 
                    'Lokasi', 
                    Icons.location_on_outlined,
                    true
                  ),
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    hargaController, 
                    'Harga per Bulan (Rp)', 
                    Icons.attach_money_outlined,
                    true,
                    TextInputType.number
                  ),
                ]),

                const SizedBox(height: 24),
                
                // Description Section
                _buildSectionHeader('Deskripsi', Icons.description_outlined),
                const SizedBox(height: 16),
                
                _buildModernCard([
                  _buildModernTextField(
                    deskripsiController,
                    'Deskripsi Properti',
                    Icons.notes_outlined,
                    false,
                    TextInputType.multiline,
                    4
                  ),
                ]),

                const SizedBox(height: 24),
                
                // Property Details Section
                _buildSectionHeader('Detail Properti', Icons.info_outline),
                const SizedBox(height: 16),
                
                _buildModernCard([
                  Row(
                    children: [
                      Expanded(
                        child: _buildModernTextField(
                          kamarController,
                          'Kamar Tidur',
                          Icons.bed_outlined,
                          false,
                          TextInputType.number
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildModernTextField(
                          kamarMandiController,
                          'Kamar Mandi',
                          Icons.bathroom_outlined,
                          false,
                          TextInputType.number
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildModernTextField(
                          luasBangunanController,
                          'Luas Bangunan (m²)',
                          Icons.straighten_outlined,
                          false,
                          TextInputType.number
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildModernTextField(
                          luasTanahController,
                          'Luas Tanah (m²)',
                          Icons.landscape_outlined,
                          false,
                          TextInputType.number
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    fasilitasController,
                    'Fasilitas (pisahkan dengan koma)',
                    Icons.featured_play_list_outlined,
                    false
                  ),
                ]),

                const SizedBox(height: 24),
                
                // Image Section
                _buildSectionHeader('Gambar Properti', Icons.image_outlined),
                const SizedBox(height: 16),
                
                _buildImageSection(),

                const SizedBox(height: 32),
                
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: isLoading
                      ? Container(
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                              ),
                            ),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: tambahProperti,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text(
                            'Simpan Properti',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildModernCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildModernTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool required, [
    TextInputType type = TextInputType.text,
    int maxLines = 1,
  ]) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(color: Colors.grey.shade600),
      ),
      validator: required
          ? (value) => value == null || value.trim().isEmpty ? 'Wajib diisi' : null
          : null,
    );
  }

  Widget _buildImageSection() {
    return _buildModernCard([
      if (selectedImage != null) ...[
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              selectedImage!,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: pilihGambar,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Ganti Gambar'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(() => selectedImage = null),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text('Hapus', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ] else ...[
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade300,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 32,
                color: Colors.grey.shade500,
              ),
              const SizedBox(height: 8),
              Text(
                'Belum ada gambar dipilih',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: pilihGambar,
            icon: const Icon(Icons.image_outlined),
            label: const Text('Pilih Gambar dari Galeri'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).primaryColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: Theme.of(context).primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    ]);
  }
}