import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/service_model.dart';

class ServiceLaptopService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'services';

  // Membuat layanan baru (dipanggil oleh admin)
  Future<ServiceModel> createService({
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
      final docRef = _firestore.collection(_collection).doc();
      final now = DateTime.now();

      final service = ServiceModel(
        id: docRef.id,
        userId: userId,
        userEmail: userEmail,
        userName: userName,
        laptopBrand: laptopBrand,
        laptopModel: laptopModel,
        problem: problem,
        status: 'pending',
        estimatedCost: estimatedCost,
        images: images,
        createdAt: now,
        updatedAt: now,
        notes: notes,
      );

      await docRef.set(service.toMap());
      return service;
    } catch (e) {
      debugPrint('Error creating service: $e');
      rethrow;
    }
  }

  // Mendapatkan semua layanan (untuk admin)
  Stream<List<ServiceModel>> getAllServices() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ServiceModel.fromMap(doc.data()))
          .toList();
    });
  }

  // Mendapatkan layanan berdasarkan userId (untuk pengguna)
  Stream<List<ServiceModel>> getUserServices(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ServiceModel.fromMap(doc.data()))
          .toList();
    });
  }

  // Mendapatkan layanan berdasarkan ID
  Future<ServiceModel?> getServiceById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return ServiceModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting service: $e');
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
      final updates = <String, dynamic>{
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (finalCost != null) {
        updates['finalCost'] = finalCost;
      }

      if (notes != null) {
        updates['notes'] = notes;
      }

      if (status == 'in_progress') {
        updates['startedAt'] = DateTime.now().toIso8601String();
      } else if (status == 'completed') {
        updates['completedAt'] = DateTime.now().toIso8601String();
      }

      await _firestore.collection(_collection).doc(id).update(updates);
    } catch (e) {
      debugPrint('Error updating service status: $e');
      rethrow;
    }
  }

  // Menghapus layanan
  Future<void> deleteService(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting service: $e');
      rethrow;
    }
  }
} 