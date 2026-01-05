import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/api_error.dart';

/// Service untuk interaksi dengan RAG Chatbot
/// Menangani komunikasi dengan backend chat API tanpa menyimpan ke database
class ChatService {
  final ApiService _apiService = ApiService();

  /// Kirim pertanyaan ke RAG chatbot dan dapatkan jawaban
  /// Respons bersifat temporary dan tidak disimpan ke database
  ///
  /// [query] - Pertanyaan dari user
  ///
  /// Returns Map dengan struktur:
  /// - query: String (pertanyaan yang dikirim)
  /// - answer: String (jawaban dari RAG)
  /// - status: String (success/failed)
  Future<Map<String, dynamic>> sendQuery(String query) async {
    try {
      // Validasi input
      if (query.trim().isEmpty) {
        throw ApiError(
          code: 'EMPTY_QUERY',
          message: 'Pertanyaan tidak boleh kosong',
        );
      }

      // Kirim POST request ke endpoint /api/chat
      final response = await _apiService.post(
        '/api/chat',
        data: {'query': query},
      );

      // Parse response
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;

        // Validasi response structure
        if (data['status'] == 'success' && data['answer'] != null) {
          return {
            'query': data['query'] ?? query,
            'answer': data['answer'],
            'status': 'success',
          };
        } else {
          throw ApiError(
            code: 'INVALID_RESPONSE',
            message: data['error'] ?? 'Format respons tidak valid',
          );
        }
      }

      throw ApiError(
        code: 'INVALID_RESPONSE',
        message: 'Format respons tidak valid dari server',
      );
    } on ApiError {
      rethrow;
    } catch (e) {
      if (e is DioException) {
        throw ApiError.fromException(e as Exception);
      }
      throw ApiError(
        code: 'UNKNOWN_ERROR',
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Rebuild RAG index (untuk admin/maintenance)
  /// Ini akan memperbarui index di server jika ada dataset baru
  Future<void> rebuildIndex() async {
    try {
      final response = await _apiService.post('/api/chat/rebuild');

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
