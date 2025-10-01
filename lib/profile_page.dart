import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _imageFile; // Menyimpan foto profil yang dipilih
  final ImagePicker _picker = ImagePicker();

  // Fungsi pilih foto dari galeri
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // simpan hasil foto ke variabel
      });
    }
  }

  // Fungsi hapus foto (balik ke default asset)
  void _removeImage() {
    setState(() {
      _imageFile = null; // reset ke null
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text("Profil"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Foto Profil
              CircleAvatar(
                key: ValueKey(
                  _imageFile,
                ), // tambahkan key biar refresh saat hapus
                radius: 70,
                backgroundColor: Colors.orange.shade200,
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!) as ImageProvider
                    : const AssetImage("assets/images/profil.jpg"),
              ),
              const SizedBox(height: 24),

              // Nama
              const Text(
                "Fatimatuzzahra Filhayati",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // NIM
              const Text(
                "124230027",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
              const SizedBox(height: 32),

              // Tombol Edit & Hapus Foto
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage, // pilih foto baru
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Foto"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _removeImage, // hapus foto
                    icon: const Icon(Icons.delete),
                    label: const Text("Hapus Foto"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
