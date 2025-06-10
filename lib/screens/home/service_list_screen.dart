import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider.dart';
import '../../models/service_model.dart';
import 'service_detail_screen.dart';

class ServiceListScreen extends StatelessWidget {
  const ServiceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ServiceListContent();
  }
}

class ServiceListContent extends StatefulWidget {
  const ServiceListContent({super.key});

  @override
  State<ServiceListContent> createState() => _ServiceListContentState();
}

class _ServiceListContentState extends State<ServiceListContent> {
  String _selectedStatus = 'all';

  String _getStatusText(String status) {
    switch (status) {
      case 'all':
        return 'Semua Status';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Layanan'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Status',
            onSelected: (String status) {
              setState(() {
                _selectedStatus = status;
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.all_inbox, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Semua Status'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'pending',
                child: Row(
                  children: [
                    Icon(Icons.hourglass_empty, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Menunggu'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'in_progress',
                child: Row(
                  children: [
                    Icon(Icons.build, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Dalam Proses'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'completed',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Selesai'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'cancelled',
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Dibatalkan'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedStatus != 'all')
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.grey[100],
              child: Row(
                children: [
                  Icon(
                    _selectedStatus == 'pending'
                        ? Icons.hourglass_empty
                        : _selectedStatus == 'in_progress'
                            ? Icons.build
                            : _selectedStatus == 'completed'
                                ? Icons.check_circle
                                : Icons.cancel,
                    color: _selectedStatus == 'pending'
                        ? Colors.orange
                        : _selectedStatus == 'in_progress'
                            ? Colors.blue
                            : _selectedStatus == 'completed'
                                ? Colors.green
                                : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filter: ${_getStatusText(_selectedStatus)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedStatus = 'all';
                      });
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _buildServiceList(),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceList() {
    final authProvider = Provider.of<AuthProvider>(context);
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isAdministrator = user.role == 'admin';
    final serviceStream = isAdministrator 
        ? serviceProvider.getAllServices()
        : serviceProvider.getUserServices(user.id);

    return StreamBuilder<List<ServiceModel>>(
      stream: serviceStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final services = snapshot.data ?? [];
        if (services.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inbox, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Tidak ada data service',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final filteredServices = _selectedStatus == 'all'
            ? services
            : services.where((service) => service.status == _selectedStatus).toList();

        if (filteredServices.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.filter_list, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Tidak ada service dengan status ini',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: filteredServices.length,
          itemBuilder: (context, index) {
            final service = filteredServices[index];
            return ServiceCard(service: service);
          },
        );
      },
    );
  }
}

class ServiceCard extends StatelessWidget {
  final ServiceModel service;

  const ServiceCard({
    super.key,
    required this.service,
  });

  Color _getStatusColor(String status) {
    switch (status) {
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

  String _getStatusText(String status) {
    switch (status) {
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceDetailScreen(service: service),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      service.userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(service.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(service.status),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getStatusText(service.status),
                      style: TextStyle(
                        color: _getStatusColor(service.status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${service.laptopBrand} ${service.laptopModel}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                service.problem,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 