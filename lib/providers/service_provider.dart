import 'package:flutter/foundation.dart';
import '../models/service_model.dart';
import '../services/service_laptop_service.dart';
import '../services/cloudinary_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceProvider with ChangeNotifier {
  final ServiceLaptopService _service = ServiceLaptopService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ServiceModel> _services = [];
  List<ServiceModel> _userServices = [];
  bool _isLoading = false;
  String? _error;

  List<ServiceModel> get services => _services;
  List<ServiceModel> get userServices => _userServices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _loadServices() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final snapshot = await _firestore.collection('services').get();
      _services = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ServiceModel.fromMap(data);
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Mendapatkan semua layanan (untuk admin)
  Stream<List<ServiceModel>> getAllServices() {
    return _service.getAllServices();
  }

  // Mendapatkan layanan berdasarkan userId (untuk pengguna)
  Stream<List<ServiceModel>> getUserServices(String userId) {
    return _service.getUserServices(userId);
  }

  // Membuat layanan baru (dipanggil oleh admin)
  Future<void> createService({
    required String userId,
    required String userEmail,
    required String userName,
    required String laptopBrand,
    required String laptopModel,
    required String problem,
    required List<String> images,
    double? estimatedCost,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Upload gambar ke Cloudinary
      final uploadedImages = await _cloudinaryService.uploadMultipleImages(images);

      // Buat layanan baru
      await _service.createService(
        userId: userId,
        userEmail: userEmail,
        userName: userName,
        laptopBrand: laptopBrand,
        laptopModel: laptopModel,
        problem: problem,
        images: uploadedImages,
        estimatedCost: estimatedCost,
        notes: notes,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Memperbarui status layanan
  Future<void> updateServiceStatus(
    String id,
    String status, {
    double? finalCost,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.updateServiceStatus(
        id,
        status,
        finalCost: finalCost,
        notes: notes,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Menghapus layanan
  Future<void> deleteService(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.deleteService(id);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateServiceRating(String serviceId, double rating, String comment) async {
    try {
      final serviceRef = _firestore.collection('services').doc(serviceId);
      await serviceRef.update({
        'rating': rating,
        'comment': comment,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await _loadServices();
    } catch (e) {
      rethrow;
    }
  }
} 