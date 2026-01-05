import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

class CloudinaryUploader {
  static Future<String> uploadImage(
    dynamic image, {
    required String cloudName,
    required String uploadPreset,
    required String folder,
  }) async {
    MultipartFile multipartFile;

    if (kIsWeb && image is Uint8List) {
      // Web: Use bytes directly
      multipartFile = MultipartFile.fromBytes(
        image,
        filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
        contentType: MediaType('image', 'jpeg'),
      );
    } else if (!kIsWeb && image is File) {
      // Mobile: Use file path
      multipartFile = await MultipartFile.fromFile(
        image.path,
        filename: path.basename(image.path),
      );
    } else {
      throw Exception('Unsupported image type for platform');
    }

    final formData = FormData.fromMap({
      'upload_preset': uploadPreset,
      'folder': folder,
      'file': multipartFile,
    });

    final dio = Dio();
    final url = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';
    final resp = await dio.post(url, data: formData);
    if (resp.statusCode == 200) {
      return resp.data['secure_url'] as String;
    } else {
      throw Exception(
        resp.data['error']?['message'] ?? 'Cloudinary upload failed',
      );
    }
  }
}
