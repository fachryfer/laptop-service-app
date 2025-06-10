import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/service_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AdminCreateServiceScreen extends StatefulWidget {
  const AdminCreateServiceScreen({super.key});

  @override
  State<AdminCreateServiceScreen> createState() => _AdminCreateServiceScreenState();
}

class _AdminCreateServiceScreenState extends State<AdminCreateServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _laptopBrandController = TextEditingController();
  final _laptopModelController = TextEditingController();
  final _problemController = TextEditingController();
  final _estimatedCostController = TextEditingController();
  final _notesController = TextEditingController();
  List<String> _selectedImages = [];
  UserModel? _selectedUser;
  List<UserModel> _users = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await context.read<AuthProvider>().getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();

    if (images != null && images.isNotEmpty) {
      setState(() {
        _selectedImages = images.map((image) => image.path).toList();
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih pengguna terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<ServiceProvider>().createService(
        userId: _selectedUser!.id,
        userEmail: _selectedUser!.email,
        userName: _selectedUser!.fullName,
        laptopBrand: _laptopBrandController.text,
        laptopModel: _laptopModelController.text,
        problem: _problemController.text,
        images: _selectedImages,
        estimatedCost: double.tryParse(_estimatedCostController.text),
        notes: _notesController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Layanan berhasil dibuat')),
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Layanan Baru'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Pemilihan Pengguna
                    DropdownButtonFormField<UserModel>(
                      value: _selectedUser,
                      decoration: const InputDecoration(
                        labelText: 'Pemilik Laptop',
                        border: OutlineInputBorder(),
                      ),
                      items: _users.map((user) {
                        return DropdownMenuItem(
                          value: user,
                          child: Text('${user.fullName} (${user.email})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedUser = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Pilih pemilik laptop';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Merek Laptop
                    TextFormField(
                      controller: _laptopBrandController,
                      decoration: const InputDecoration(
                        labelText: 'Merek Laptop',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan merek laptop';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Model Laptop
                    TextFormField(
                      controller: _laptopModelController,
                      decoration: const InputDecoration(
                        labelText: 'Model Laptop',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan model laptop';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Masalah
                    TextFormField(
                      controller: _problemController,
                      decoration: const InputDecoration(
                        labelText: 'Masalah',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan masalah laptop';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Estimasi Biaya
                    TextFormField(
                      controller: _estimatedCostController,
                      decoration: const InputDecoration(
                        labelText: 'Estimasi Biaya',
                        border: OutlineInputBorder(),
                        prefixText: 'Rp ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Catatan
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Catatan',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Pilih Gambar
                    ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Pilih Gambar'),
                    ),
                    if (_selectedImages.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Image.file(
                                File(_selectedImages[index]),
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Tombol Submit
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Buat Layanan'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _laptopBrandController.dispose();
    _laptopModelController.dispose();
    _problemController.dispose();
    _estimatedCostController.dispose();
    _notesController.dispose();
    super.dispose();
  }
} 