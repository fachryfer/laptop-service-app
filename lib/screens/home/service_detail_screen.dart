import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:service_laptop/models/service_model.dart';
import 'package:service_laptop/providers/auth_provider.dart';
import 'package:service_laptop/providers/service_provider.dart';

class ServiceDetailScreen extends StatefulWidget {
  final ServiceModel service;

  const ServiceDetailScreen({Key? key, required this.service}) : super(key: key);

  @override
  _ServiceDetailScreenState createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _finalCostController = TextEditingController();
  final _ratingController = TextEditingController();
  final _commentController = TextEditingController();
  bool _isEditingCostAndNotes = false;
  bool _isRating = false;
  double _userRating = 0;

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.service.notes ?? '';
    _finalCostController.text = widget.service.finalCost?.toString() ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    _finalCostController.dispose();
    _ratingController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'inProgress':
        return 'Dalam Proses';
      case 'readyForPickup':
        return 'Siap Diambil';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'inProgress':
        return Colors.blue;
      case 'readyForPickup':
        return Colors.green;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateServiceStatus(String newStatus) async {
    try {
      final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
      await serviceProvider.updateServiceStatus(widget.service.id, newStatus);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status layanan diperbarui menjadi ${_getStatusText(newStatus)}'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitRating() async {
    if (_userRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon berikan rating'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
      await serviceProvider.updateServiceRating(
        widget.service.id,
        _userRating,
        _commentController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rating berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan rating: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateFinalCostAndNotes() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
      double? finalCost = _finalCostController.text.isNotEmpty
          ? double.parse(_finalCostController.text)
          : null;
      String? notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

      await serviceProvider.updateServiceStatus(
        widget.service.id,
        widget.service.status,
        finalCost: finalCost,
        notes: notes,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Biaya akhir dan catatan berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() { // Update UI after saving
        _isEditingCostAndNotes = false;
      });
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui biaya/catatan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.currentUser?.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Layanan'),
        actions: [
          if (isAdmin)
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              onSelected: _updateServiceStatus,
              itemBuilder: (context) => [
                if (widget.service.status == 'pending')
                  const PopupMenuItem(
                    value: 'inProgress',
                    child: Row(
                      children: [
                        Icon(Icons.build, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Mulai Proses'),
                      ],
                    ),
                  ),
                if (widget.service.status == 'inProgress')
                  const PopupMenuItem(
                    value: 'readyForPickup',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Siap Diambil'),
                      ],
                    ),
                  ),
                if (widget.service.status == 'readyForPickup')
                  const PopupMenuItem(
                    value: 'completed',
                    child: Row(
                      children: [
                        Icon(Icons.done_all, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Selesai'),
                      ],
                    ),
                  ),
                if (widget.service.status != 'cancelled' && widget.service.status != 'completed')
                  const PopupMenuItem(
                    value: 'cancelled',
                    child: Row(
                      children: [
                        Icon(Icons.cancel, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Batalkan'),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              title: 'Informasi Laptop',
              children: [
                _buildInfoRow('Merek', widget.service.laptopBrand),
                _buildInfoRow('Model', widget.service.laptopModel),
                _buildInfoRow('Masalah', widget.service.problem),
                _buildInfoRow('Dibuat Pada', DateFormat('dd-MM-yyyy HH:mm').format(widget.service.createdAt)),
                _buildInfoRow('Diperbarui Pada', DateFormat('dd-MM-yyyy HH:mm').format(widget.service.updatedAt)),
              ],
            ),
            const SizedBox(height: 16),

            // Display Service Images
            if (widget.service.images.isNotEmpty)
              _buildInfoCard(
                title: 'Gambar Layanan',
                children: [
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.service.images.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              widget.service.images[index],
                              width: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 150,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            _buildInfoCard(
              title: 'Status & Biaya',
              children: [
                _buildInfoRow('Status', _getStatusText(widget.service.status),
                    color: _getStatusColor(widget.service.status)),
                _buildInfoRow('Perkiraan Biaya', widget.service.estimatedCost != null ? 'Rp ${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(widget.service.estimatedCost)}' : 'Belum ditentukan'),
                if (widget.service.finalCost != null && !_isEditingCostAndNotes)
                  _buildInfoRow('Biaya Akhir', 'Rp ${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(widget.service.finalCost)}'),
                if (widget.service.notes != null && widget.service.notes!.isNotEmpty && !_isEditingCostAndNotes)
                  _buildInfoRow('Catatan Admin', widget.service.notes!),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Riwayat Layanan',
              children: [
                _buildTimelineRow(
                  'Dibuat',
                  widget.service.createdAt,
                  Icons.add_circle_outline,
                  Colors.grey,
                ),
                if (widget.service.startedAt != null)
                  _buildTimelineRow(
                    'Mulai Dalam Proses',
                    widget.service.startedAt!,
                    Icons.build,
                    Colors.blue,
                  ),
                if (widget.service.status == 'readyForPickup' || widget.service.status == 'completed')
                  _buildTimelineRow(
                    'Siap Diambil',
                    widget.service.updatedAt, // Asumsi updatedAt adalah saat status menjadi Siap Diambil
                    Icons.check_circle_outline,
                    Colors.green,
                  ),
                if (widget.service.completedAt != null)
                  _buildTimelineRow(
                    'Selesai',
                    widget.service.completedAt!,
                    Icons.done_all,
                    Colors.green,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Section for Admin to edit Final Cost and Notes
            if (isAdmin)
              _buildInfoCard(
                title: 'Pengaturan Admin',
                children: [
                  if (!_isEditingCostAndNotes)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isEditingCostAndNotes = true;
                          });
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Biaya Akhir & Catatan'),
                      ),
                    ),
                  if (_isEditingCostAndNotes)
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _finalCostController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Biaya Akhir (Opsional)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.money),
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                                return 'Mohon masukkan angka yang valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Catatan Admin (Opsional)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.note),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _updateFinalCostAndNotes();
                                  },
                                  child: const Text('Simpan'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isEditingCostAndNotes = false;
                                      _notesController.text = widget.service.notes ?? '';
                                      _finalCostController.text = widget.service.finalCost?.toString() ?? '';
                                    });
                                  },
                                  child: const Text('Batal'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 16),

            // Section for User to give Rating and Comment
            if (widget.service.status == 'completed' && !isAdmin && widget.service.rating == null)
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Berikan Rating Layanan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < _userRating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 32,
                            ),
                            onPressed: () {
                              setState(() {
                                _userRating = index + 1;
                              });
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          labelText: 'Komentar (Opsional)',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitRating,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Kirim Rating', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Section to display Rating and Comment
            if (widget.service.rating != null)
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rating & Komentar Pengguna',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < widget.service.rating! ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 24,
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.service.rating}/5',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      if (widget.service.comment != null && widget.service.comment!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.service.comment!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineRow(
    String title,
    DateTime timestamp,
    IconData icon,
    Color iconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('dd MMMM yyyy, HH:mm').format(timestamp),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: color ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}