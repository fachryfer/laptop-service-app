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
  final double? rating;
  final String? comment;

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
    this.rating,
    this.comment,
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
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'notes': notes,
      'rating': rating,
      'comment': comment,
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
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      startedAt: (map['startedAt'] as Timestamp?)?.toDate(),
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
      notes: map['notes'],
      rating: map['rating']?.toDouble(),
      comment: map['comment'],
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
    double? rating,
    String? comment,
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
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
    );
  }
} 