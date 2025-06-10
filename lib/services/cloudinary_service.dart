import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class CloudinaryService {
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    'dmhbguqqa', // Cloud name dari user
    'my_flutter_upload', // Upload preset dari user
    cache: false,
  );

  Future<String> uploadImage(File imageFile) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<List<String>> uploadMultipleImages(List<String> imagePaths) async {
    try {
      final List<CloudinaryResponse> responses = [];
      for (String path in imagePaths) {
        responses.add(await _cloudinary.uploadFile(CloudinaryFile.fromFile(
          path,
          resourceType: CloudinaryResourceType.Image,
        )));
      }
      return responses.map((res) => res.secureUrl).toList();
    } catch (e) {
      debugPrint('Error uploading images: $e');
      rethrow;
    }
  }
} 