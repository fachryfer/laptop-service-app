enum ServiceStatus {
  pending('Menunggu Konfirmasi'),
  inProgress('Dalam Proses'),
  readyForPickup('Siap Diambil'),
  completed('Selesai'),
  cancelled('Dibatalkan');

  final String label;
  const ServiceStatus(this.label);
}

class Service {
  final String id;
  final String userId;
  final String laptopBrand;
  final String laptopModel;
  final String problemDescription;
  final String? notes;
  final double? estimatedCost;
  final double? finalCost;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? rating;
  final String? comment;

  Service({
    required this.id,
    required this.userId,
    required this.laptopBrand,
    required this.laptopModel,
    required this.problemDescription,
    this.notes,
    this.estimatedCost,
    this.finalCost,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.rating,
    this.comment,
  });

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      laptopBrand: map['laptopBrand'] ?? '',
      laptopModel: map['laptopModel'] ?? '',
      problemDescription: map['problemDescription'] ?? '',
      notes: map['notes'],
      estimatedCost: map['estimatedCost']?.toDouble(),
      finalCost: map['finalCost']?.toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      rating: map['rating']?.toDouble(),
      comment: map['comment'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'laptopBrand': laptopBrand,
      'laptopModel': laptopModel,
      'problemDescription': problemDescription,
      'notes': notes,
      'estimatedCost': estimatedCost,
      'finalCost': finalCost,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'rating': rating,
      'comment': comment,
    };
  }

  Service copyWith({
    String? id,
    String? userId,
    String? laptopBrand,
    String? laptopModel,
    String? problemDescription,
    String? notes,
    double? estimatedCost,
    double? finalCost,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? rating,
    String? comment,
  }) {
    return Service(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      laptopBrand: laptopBrand ?? this.laptopBrand,
      laptopModel: laptopModel ?? this.laptopModel,
      problemDescription: problemDescription ?? this.problemDescription,
      notes: notes ?? this.notes,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      finalCost: finalCost ?? this.finalCost,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
    );
  }
} 