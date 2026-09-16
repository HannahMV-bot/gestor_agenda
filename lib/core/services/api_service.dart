import 'dart:convert';

import 'package:http/http.dart' as http;

import 'session_service.dart';

class ApiService {
  final SessionService _sessionService = SessionService();

  Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse(url),
      headers: await _headers(),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String url,
    Map<String, dynamic> body,
  ) async {
    final response = await http.put(
      Uri.parse(url),
      headers: await _headers(),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Future<List<dynamic>> getList(
    String url,
  ) async {
    final response = await http.get(
      Uri.parse(url),
      headers: await _headers(),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data;
      }

      throw Exception(
        'La respuesta del servidor no es una lista.',
      );
    }

    _throwServerError(response);
  }

  Future<Map<String, dynamic>> get(
    String url,
  ) async {
    final response = await http.get(
      Uri.parse(url),
      headers: await _headers(),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(
    String url,
  ) async {
    final response = await http.delete(
      Uri.parse(url),
      headers: await _headers(),
    );

    return _handleResponse(response);
  }

  Future<Map<String, String>> _headers() async {
    final token = await _sessionService.getToken();

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Map<String, dynamic> _handleResponse(
    http.Response response,
  ) {
    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }

      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        return data;
      }

      return {
        'data': data,
      };
    }

    _throwServerError(response);
  }

  Never _throwServerError(
    http.Response response,
  ) {
    String message =
        'Ocurrió un error en el servidor.';

    try {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        final detail = data['detail'];

        if (detail != null) {
          message = detail.toString();
        }
      }
    } catch (_) {
      if (response.body.isNotEmpty) {
        message = response.body;
      }
    }

    throw Exception(
      '$message (${response.statusCode})',
    );
  }
}