// ============================================================
// api_service.dart
// Satu file service yang cover SEMUA endpoint backend Sentinel
// Taruh di: lib/services/api_service.dart
// ============================================================

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ApiService {
  // Ganti sesuai environment:
  // Android Emulator → http://10.0.2.2:3000
  // HP fisik (WiFi)  → http://192.168.x.x:3000
  static const String baseUrl = 'http://localhost:3000';

  // ─────────────────────────────────────────────
  // Helper: ambil token dari SharedPreferences
  // ─────────────────────────────────────────────
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ─────────────────────────────────────────────
  // Helper: header dengan Bearer token
  // ─────────────────────────────────────────────
  static Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ─────────────────────────────────────────────
  // Helper: parse response — lempar exception jika error
  // ─────────────────────────────────────────────
  static dynamic _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: data['message'] ?? 'Terjadi kesalahan',
    );
  }

  // ════════════════════════════════════════════
  // AUTH
  // ════════════════════════════════════════════

  /// POST /api/auth/register
  /// Body: { full_name, email, password }
  /// Response: { message, user_id }
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'password': password,
      }),
    );
    return _handleResponse(response);
  }

  /// POST /api/auth/login
  /// Body: { email, password }
  /// Response: { message, token, user: { id, full_name, email } }
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = _handleResponse(response);

    // Simpan token & user info otomatis setelah login berhasil
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', data['token']);
    await prefs.setInt('user_id', data['user']['id']);
    await prefs.setString('user_name', data['user']['full_name']);
    await prefs.setString('user_email', data['user']['email']);

    return data;
  }

  /// Logout — hapus token dari SharedPreferences
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
  }

  /// Ambil info user yang sedang login (dari cache lokal)
  static Future<Map<String, dynamic>> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getInt('user_id'),
      'full_name': prefs.getString('user_name') ?? '',
      'email': prefs.getString('user_email') ?? '',
    };
  }

  // ════════════════════════════════════════════
  // ELDERLY (DATA LANSIA)
  // ════════════════════════════════════════════

  /// GET /api/elderly
  /// Response: List<Map> — semua lansia milik user yang login
  /// Field: id, user_id, full_name, age, gender, address,
  ///        health_condition, notes, created_at
  static Future<List<dynamic>> getElderlyList() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/elderly'),
      headers: await _authHeaders(),
    );
    final data = _handleResponse(response);
    return data is List ? data : [];
  }

  /// GET /api/elderly/:id
  /// Response: Map — detail satu lansia
  static Future<Map<String, dynamic>> getElderlyById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/elderly/$id'),
      headers: await _authHeaders(),
    );
    return _handleResponse(response);
  }

  /// POST /api/elderly
  /// Body: { full_name, age, gender, address?, health_condition?, notes? }
  /// Response: { message, id }
  static Future<Map<String, dynamic>> addElderly({
    required String fullName,
    required int age,
    required String gender,
    String? address,
    String? healthCondition,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/elderly'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'full_name': fullName,
        'age': age,
        'gender': gender,
        if (address != null && address.isNotEmpty) 'address': address,
        if (healthCondition != null && healthCondition.isNotEmpty)
          'health_condition': healthCondition,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      }),
    );
    return _handleResponse(response);
  }

  /// PUT /api/elderly/:id
  /// Body: { full_name, age, gender, address, health_condition, notes }
  /// Response: { message }
  static Future<Map<String, dynamic>> updateElderly({
    required int id,
    required String fullName,
    required int age,
    required String gender,
    String? address,
    String? healthCondition,
    String? notes,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/elderly/$id'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'full_name': fullName,
        'age': age,
        'gender': gender,
        'address': address ?? '',
        'health_condition': healthCondition ?? '',
        'notes': notes ?? '',
      }),
    );
    return _handleResponse(response);
  }

  /// DELETE /api/elderly/:id
  /// Response: { message }
  static Future<Map<String, dynamic>> deleteElderly(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/elderly/$id'),
      headers: await _authHeaders(),
    );
    return _handleResponse(response);
  }

  // ════════════════════════════════════════════
  // CAMERAS
  // ════════════════════════════════════════════

  /// GET /api/elderly/:elderlyId/cameras
  /// Response: List<Map>
  /// Field: id, elderly_id, name, location, stream_url, status, last_heartbeat
  static Future<List<dynamic>> getCamerasByElderly(int elderlyId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/elderly/$elderlyId/cameras'),
      headers: await _authHeaders(),
    );
    final data = _handleResponse(response);
    return data is List ? data : [];
  }

  /// POST /api/cameras
  /// Body: { elderly_id, name, location, stream_url? }
  /// Response: { message, id }
  static Future<Map<String, dynamic>> addCamera({
    required int elderlyId,
    required String name,
    required String location,
    String? streamUrl,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/cameras'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'elderly_id': elderlyId,
        'name': name,
        'location': location,
        if (streamUrl != null && streamUrl.isNotEmpty) 'stream_url': streamUrl,
      }),
    );
    return _handleResponse(response);
  }

  /// GET /api/cameras/:id/status-frame
  /// Response: { camera_name, camera_status, last_heartbeat, image_url }
  static Future<Map<String, dynamic>> getCameraStatusFrame(int cameraId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/cameras/$cameraId/status-frame'),
      headers: await _authHeaders(),
    );
    return _handleResponse(response);
  }

  // ════════════════════════════════════════════
  // CAREGIVERS
  // ════════════════════════════════════════════

  /// GET /api/elderly/:elderlyId/caregivers
  /// Response: List<Map>
  /// Field: id, elderly_id, name, phone, email, relationship,
  ///        telegram_chat_id, telegram_username, notify_priority, is_active
  static Future<List<dynamic>> getCaregiversByElderly(int elderlyId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/elderly/$elderlyId/caregivers'),
      headers: await _authHeaders(),
    );
    final data = _handleResponse(response);
    return data is List ? data : [];
  }

  /// POST /api/caregivers
  /// Body: { elderly_id, name, phone?, email?, relationship?,
  ///         telegram_chat_id?, telegram_username?, notify_priority? }
  /// Response: { message, id }
  static Future<Map<String, dynamic>> addCaregiver({
    required int elderlyId,
    required String name,
    String? phone,
    String? email,
    String? relationship,
    String? telegramChatId,
    String? telegramUsername,
    int notifyPriority = 1,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/caregivers'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'elderly_id': elderlyId,
        'name': name,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (email != null && email.isNotEmpty) 'email': email,
        if (relationship != null && relationship.isNotEmpty)
          'relationship': relationship,
        if (telegramChatId != null && telegramChatId.isNotEmpty)
          'telegram_chat_id': telegramChatId,
        if (telegramUsername != null && telegramUsername.isNotEmpty)
          'telegram_username': telegramUsername,
        'notify_priority': notifyPriority,
      }),
    );
    return _handleResponse(response);
  }

  // ════════════════════════════════════════════
  // FALL EVENTS (RIWAYAT KEJADIAN)
  // ════════════════════════════════════════════

  /// GET /api/events
  /// Response: List<Map>
  /// Field: id, elderly_id, camera_id, event_time, snapshot_url,
  ///        confidence_score, status, elderly_name, camera_name, location
  static Future<List<dynamic>> getFallEvents() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/events'),
      headers: await _authHeaders(),
    );
    final data = _handleResponse(response);
    return data is List ? data : [];
  }
}

// ─────────────────────────────────────────────
// Custom Exception untuk error dari API
// ─────────────────────────────────────────────
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';

  /// Cek apakah error ini karena token expired/invalid
  bool get isUnauthorized => statusCode == 401;

  /// Cek apakah data tidak ditemukan
  bool get isNotFound => statusCode == 404;
}