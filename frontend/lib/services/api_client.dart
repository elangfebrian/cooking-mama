import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Error dari REST API. [message] sudah berbahasa Indonesia dari server dan
/// aman ditampilkan ke pengguna (mis. lewat SnackBar).
class ApiException implements Exception {
  ApiException(this.statusCode, this.message);

  /// 0 = tidak bisa terhubung ke server (offline / backend mati / timeout).
  final int statusCode;
  final String message;

  bool get isUnauthorized => statusCode == 401;
  bool get isNetworkError => statusCode == 0;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Klien HTTP tunggal untuk backend Cooking Mama.
///
/// Base URL (urutan prioritas):
///  1. `--dart-define=API_BASE_URL=http://192.168.1.10:3000/api` (HP fisik)
///  2. Android emulator -> http://10.0.2.2:3000/api
///  3. Web / iOS Simulator / desktop -> http://localhost:3000/api
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static const String _envBase = String.fromEnvironment('API_BASE_URL');
  static const Duration _timeout = Duration(seconds: 10);
  static const String _offlineMessage =
      'Tidak dapat terhubung ke server. Periksa koneksi atau pastikan backend berjalan.';

  static String get baseUrl {
    if (_envBase.isNotEmpty) return _envBase.replaceAll(RegExp(r'/+$'), '');
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  /// JWT dari /auth/login. Diisi dan dikosongkan oleh AppState.
  String? token;

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        if (token != null && token!.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  /// Semua method mengembalikan isi field `data` dari respons server.
  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _send('GET', path, query: query);
  Future<dynamic> post(String path, [Object? body]) =>
      _send('POST', path, body: body);
  Future<dynamic> put(String path, [Object? body]) =>
      _send('PUT', path, body: body);
  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
  }) {
    final req = http.Request(method, _uri(path, query))..headers.addAll(_headers);
    if (body != null) {
      req.headers['Content-Type'] = 'application/json; charset=utf-8';
      req.body = jsonEncode(body);
    }
    return _execute(req.send);
  }

  /// Unggah foto (path lokal dari kamera/galeri) -> mengembalikan URL foto.
  Future<String> uploadImage(String filePath) async {
    final req = http.MultipartRequest('POST', _uri('/uploads/image'))
      ..headers.addAll(_headers);
    req.files.add(await http.MultipartFile.fromPath('photo', filePath));
    final data = await _execute(req.send);
    return (data as Map<String, dynamic>)['url'] as String;
  }

  Future<dynamic> _execute(Future<http.StreamedResponse> Function() send) async {
    try {
      final streamed = await send().timeout(_timeout);
      final res = await http.Response.fromStream(streamed);
      return _parse(res);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException(0, _offlineMessage);
    } catch (_) {
      // SocketException / ClientException / XMLHttpRequest error (CORS, server mati)
      throw ApiException(0, _offlineMessage);
    }
  }

  dynamic _parse(http.Response res) {
    Map<String, dynamic>? body;
    try {
      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      if (decoded is Map<String, dynamic>) body = decoded;
    } catch (_) {
      // Bukan JSON; ditangani di bawah.
    }

    final ok = res.statusCode >= 200 && res.statusCode < 300;
    if (ok && body != null && body['success'] == true) return body['data'];

    final err = body?['error'];
    String message = 'Terjadi kesalahan (${res.statusCode})';
    if (err is Map<String, dynamic>) {
      message = (err['message'] ?? message).toString();
      final details = err['details'];
      // Untuk 422, tampilkan pesan field pertama agar lebih spesifik.
      if (details is List && details.isNotEmpty && details.first is Map) {
        message = ((details.first as Map)['message'] ?? message).toString();
      }
    }
    throw ApiException(res.statusCode, message);
  }
}
