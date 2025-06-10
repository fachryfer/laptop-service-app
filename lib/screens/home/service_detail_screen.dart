import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider.dart';
import '../../models/service_model.dart';

class ServiceDetailScreen extends StatefulWidget {
  final ServiceModel service;
  const ServiceDetailScreen({super.key, required this.service});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _notesController;
  late TextEditingController _finalCostController;
  bool _isEditingCostAndNotes = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.service.notes);
    _finalCostController = TextEditingController(text: widget.service.finalCost?.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _notesController.dispose();
    _finalCostController.dispose();
    super.dispose();
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pre_registered':
        return 'Pra-Terdaftar';
      case 'pending':
        return 'Menunggu';
      case 'in_progress':
        return 'Dalam Proses';
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
      case 'pre_registered':
        return Colors.blueGrey;
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
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

  Future<void> _updateCostAndNotes() async {
    if (_formKey.currentState!.validate()) {
      try {
        final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
        double? finalCost = _finalCostController.text.isNotEmpty
            ? double.parse(_finalCostController.text)
            : null;

        final updatedService = widget.service.copyWith(
          finalCost: finalCost,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          updatedAt: DateTime.now(),
        );

        await serviceProvider.updateServiceStatus(
          widget.service.id,
          widget.service.status,
          finalCost: finalCost,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );

        if (!mounted) return;

        setState(() {
          _isEditingCostAndNotes = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biaya akhir dan catatan diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
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
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Layanan'),
        actions: [
          if (user.role == 'admin')
            PopupMenuButton<String>(
              onSelected: _updateServiceStatus,
              itemBuilder: (BuildContext context) {
                List<PopupMenuEntry<String>> items = [];
                if (widget.service.status == 'pre_registered') {
                  items.add(const PopupMenuItem(
                    value: 'pending',
                    child: Text('Set ke Menunggu'),
                  ));
                } else if (widget.service.status == 'pending') {
                  items.add(const PopupMenuItem(
                    value: 'in_progress',
                    child: Text('Set ke Dalam Proses'),
                  ));
                } else if (widget.service.status == 'in_progress') {
                  items.add(const PopupMenuItem(
                    value: 'completed',
                    child: Text('Set ke Selesai'),
                  ));
                  items.add(const PopupMenuItem(
                    value: 'cancelled',
                    child: Text('Set ke Dibatalkan'),
                  ));
                }
                return items;
              },
            ),
          if (user.role == 'admin' && !_isEditingCostAndNotes)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditingCostAndNotes = true;
                });
              },
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
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Status & Biaya',
              children: [
                _buildInfoRow('Status', _getStatusText(widget.service.status),
                    color: _getStatusColor(widget.service.status)),
                _buildInfoRow('Perkiraan Biaya', widget.service.estimatedCost != null ? 'Rp ${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(widget.service.estimatedCost)}' : 'Belum ditentukan'),
                if (_isEditingCostAndNotes && user.role == 'admin')
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
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
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _isEditingCostAndNotes = false;
                                    _notesController.text = widget.service.notes ?? '';
                                    _finalCostController.text = widget.service.finalCost?.toStringAsFixed(0) ?? '';
                                  });
                                },
                                child: const Text('Batal'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _updateCostAndNotes,
                                child: const Text('Simpan'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ) else ...[
                    _buildInfoRow('Biaya Akhir', widget.service.finalCost != null ? 'Rp ${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(widget.service.finalCost)}' : '-'),
                    _buildInfoRow('Catatan Admin', widget.service.notes ?? '-'),
                  ],
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Riwayat Layanan',
              children: [
                _buildTimelineTile(
                  'Dibuat',
                  widget.service.createdAt,
                  Icons.add_task,
                  Colors.grey,
                  isFirst: true,
                ),
                if (widget.service.startedAt != null)
                  _buildTimelineTile(
                    'Mulai Dalam Proses',
                    widget.service.startedAt!,
                    Icons.build,
                    Colors.blue,
                  ),
                if (widget.service.completedAt != null)
                  _buildTimelineTile(
                    'Selesai',
                    widget.service.completedAt!,
                    Icons.check_circle,
                    Colors.green,
                  ),
                // Tambahkan status lain di sini jika diperlukan
              ],
            ),
            const SizedBox(height: 16),
            if (widget.service.images.isNotEmpty)
              _buildInfoCard(
                title: 'Foto Terlampir',
                children: [
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.service.images.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.service.images[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Card(
      margin: EdgeInsets.zero,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTile(String title, DateTime date, IconData icon, Color color, {bool isFirst = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(icon, color: color, size: 24),
              if (!isFirst)
                Container(
                  width: 2,
                  height: 40,
                  color: Colors.grey[300],
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  DateFormat('dd MMMM yyyy, HH:mm').format(date),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 