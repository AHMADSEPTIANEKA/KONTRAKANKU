import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/models.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/property_provider.dart';

class EditPropertyPage extends ConsumerStatefulWidget {
  final Document property;

  const EditPropertyPage({super.key, required this.property});

  @override
  ConsumerState<EditPropertyPage> createState() => _EditPropertyPageState();
}

class _EditPropertyPageState extends ConsumerState<EditPropertyPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController namaController;
  late TextEditingController lokasiController;
  late TextEditingController hargaController;
  late TextEditingController deskripsiController;
  late TextEditingController kamarController;
  late TextEditingController kamarMandiController;
  late TextEditingController luasBangunanController;
  late TextEditingController luasTanahController;
  late TextEditingController fasilitasController;

  File? selectedImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final data = widget.property.data;

    namaController = TextEditingController(text: data['nama'] ?? '');
    lokasiController = TextEditingController(text: data['lokasi'] ?? '');
    hargaController = TextEditingController(text: data['harga_per_bulan']?.toString() ?? '');
    deskripsiController = TextEditingController(text: data['deskripsi'] ?? '');
    kamarController = TextEditingController(text: data['jumlah_kamar']?.toString() ?? '');
    kamarMandiController = TextEditingController(text: data['jumlah_kamar_mandi']?.toString() ?? '');
    luasBangunanController = TextEditingController(text: data['luas_bangunan']?.toString() ?? '');
    luasTanahController = TextEditingController(text: data['luas_tanah']?.toString() ?? '');
    fasilitasController = TextEditingController(text: data['fasilitas'] ?? '');
  }

  Future<void> pilihGambar() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fitur pilih gambar hanya tersedia di Android/iOS')),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = (File as dynamic)(pickedFile.path);
      });
    }
  }

  Future<void> simpanPerubahan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final updatedData = {
        'nama': namaController.text,
        'lokasi': lokasiController.text,
        'harga_per_bulan': int.tryParse(hargaController.text) ?? 0,
        'deskripsi': deskripsiController.text,
        'jumlah_kamar': int.tryParse(kamarController.text) ?? 0,
        'jumlah_kamar_mandi': int.tryParse(kamarMandiController.text) ?? 0,
        'luas_bangunan': int.tryParse(luasBangunanController.text) ?? 0,
        'luas_tanah': int.tryParse(luasTanahController.text) ?? 0,
        'fasilitas': fasilitasController.text,
      };

      await ref.read(propertyListProvider.notifier).updateProperty(
            widget.property.$id,
            updatedData,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data properti berhasil diperbarui')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan perubahan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Properti')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(namaController, 'Nama Properti', true),
              _buildTextField(lokasiController, 'Lokasi', true),
              _buildTextField(hargaController, 'Harga per Bulan', true, TextInputType.number),
              _buildTextField(deskripsiController, 'Deskripsi', false, TextInputType.multiline, 3),
              _buildTextField(kamarController, 'Jumlah Kamar Tidur', false, TextInputType.number),
              _buildTextField(kamarMandiController, 'Jumlah Kamar Mandi', false, TextInputType.number),
              _buildTextField(luasBangunanController, 'Luas Bangunan (m²)', false, TextInputType.number),
              _buildTextField(luasTanahController, 'Luas Tanah (m²)', false, TextInputType.number),
              _buildTextField(fasilitasController, 'Fasilitas (pisahkan dengan koma)', false),

              const SizedBox(height: 24),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: simpanPerubahan,
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan Perubahan'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    bool required, [
    TextInputType type = TextInputType.text,
    int maxLines = 1,
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: required
            ? (value) => value == null || value.trim().isEmpty ? 'Wajib diisi' : null
            : null,
      ),
    );
  }
}
