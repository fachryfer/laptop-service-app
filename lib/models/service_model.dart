import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String id;
  final String userId;
  final String userEmail;
  final String userName;
  final String laptopBrand;
  final String laptopModel;
  final String problem;
  final String status;
  final double? estimatedCost;
  final double? finalCost;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? notes;

  ServiceModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.laptopBrand,
    required this.laptopModel,
    required this.problem,
    required this.status,
    this.estimatedCost,
    this.finalCost,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
    this.startedAt,
    this.completedAt,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'laptopBrand': laptopBrand,
      'laptopModel': laptopModel,
      'problem': problem,
      'status': status,
      'estimatedCost': estimatedCost,
      'finalCost': finalCost,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'notes': notes,
    };
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    debugPrint('ServiceModel.fromMap received data: $map');
    debugPrint('ServiceModel.fromMap received data type: ${map.runtimeType}');
    return ServiceModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userName: map['userName'] ?? '',
      laptopBrand: map['laptopBrand'] ?? '',
      laptopModel: map['laptopModel'] ?? '',
      problem: map['problem'] ?? '',
      status: map['status'] ?? 'pending',
      estimatedCost: (map['estimatedCost'] as num?)?.toDouble(),
      finalCost: (map['finalCost'] as num?)?.toDouble(),
      images: List<String>.from(map['images'] ?? []),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
      startedAt: map['startedAt'] != null
          ? DateTime.parse(map['startedAt'])
          : null,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
      notes: map['notes'],
    );
  }

  ServiceModel copyWith({
    String? id,
    String? userId,
    String? userEmail,
    String? userName,
    String? laptopBrand,
    String? laptopModel,
    String? problem,
    String? status,
    double? estimatedCost,
    double? finalCost,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? notes,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      laptopBrand: laptopBrand ?? this.laptopBrand,
      laptopModel: laptopModel ?? this.laptopModel,
      problem: problem ?? this.problem,
      status: status ?? this.status,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      finalCost: finalCost ?? this.finalCost,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
    );
  }
} 