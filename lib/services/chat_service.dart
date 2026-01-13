import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/api_error.dart';
import '../utils/constants.dart';

/// Service untuk interaksi dengan RAG Chatbot
/// Menangani komunikasi dengan backend chat API tanpa menyimpan ke database
class ChatService {
  final ApiService _apiService = ApiService();

  /// Kirim pertanyaan ke RAG chatbot dan dapatkan jawaban
  /// Respons bersifat temporary dan tidak disimpan ke database
  Future<Map<String, dynamic>> sendQuery(String query) async {
    try {
      // Validasi input
      if (query.trim().isEmpty) {
        throw ApiError(
          code: 'EMPTY_QUERY',
          message: 'Pertanyaan tidak boleh kosong',
        );
      }

      final response = await _apiService.post(
        ApiConstants.chat,
        data: {'query': query},
      );

      final data = _apiService.unwrap(response);

      if (data is Map<String, dynamic> && data['answer'] != null) {
        return {
          'query': data['query'] ?? query,
          'answer': data['answer'],
          'status': 'success',
        };
      }

      throw ApiError(
        code: 'INVALID_RESPONSE',
        message: 'Format respons tidak valid dari server',
      );
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError.fromException(Exception(e));
    }
  }

  /// Rebuild RAG index (untuk admin/maintenance)
  Future<void> rebuildIndex() async {
    try {
      final response = await _apiService.post(ApiConstants.chatRebuild);

      if (response.statusCode != 200) {
        throw ApiError(
          code: 'REBUILD_FAILED',
          message: 'Gagal memperbarui index',
        );
      }
    } on ApiError {
      rethrow;
    } catch (e) {
      throw ApiError.fromException(e as Exception);
    }
  }
}
