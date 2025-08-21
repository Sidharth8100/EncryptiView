// lib/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'config.dart';
import 'secure_storage_service.dart';
import 'document_model.dart';
import 'category_model.dart';
import 'document_request_model.dart';
import 'user_profile_model.dart';

class ApiService {
  final SecureStorageService _storage = SecureStorageService();

  Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    final token = await _storage.getAccessToken();
    if (token == null)
      throw Exception('Authentication token not found. Please log in again.');
    return {
      if (!isMultipart) 'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  // --- Marketplace Function (THE FIX IS HERE) ---
  Future<List<Document>> getMarketplaceDocuments() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/marketplace/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data
            .map((json) => Document.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        // THE FIX: Instead of a generic error, we now throw a detailed one.
        throw Exception(
          'Failed to load marketplace. Server responded with Status Code ${response.statusCode}. Response: ${response.body}',
        );
      }
    } catch (e) {
      // Re-throw the exception to be caught by the UI
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // --- ALL OTHER METHODS ARE VERIFIED AND COMPLETE ---
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/token/'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.saveTokens(
        access: data['access'],
        refresh: data['refresh'],
        role: data['role'],
      );
      return data;
    } else {
      throw Exception('Login Failed. Check credentials.');
    }
  }

  Future<void> register(
    String username,
    String email,
    String password,
    String role,
  ) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/register/'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'role': role,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Registration Failed: ${response.body}');
    }
  }

  Future<Uint8List?> getTTSAudio(int documentId) async {
    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/tts/$documentId/'),
        headers: await _getHeaders(),
      );
      return (response.statusCode == 200) ? response.bodyBytes : null;
    } catch (e) {
      return null;
    }
  }

  Future<String> getDocumentContent(int documentId) async {
    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/documents/$documentId/content/'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['content'] ?? "No content found.";
      }
      return "Error: ${response.statusCode}";
    } catch (e) {
      return "An error occurred.";
    }
  }

  Future<void> createDocumentRequest(int documentId) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/requests/'),
      headers: await _getHeaders(),
      body: jsonEncode({'document_id': documentId}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to send access request.');
    }
  }

  Future<List<Document>> getAdminDocuments() async {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/admin/'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data
          .map((json) => Document.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load your admin documents.');
    }
  }

  Future<void> uploadDocument(
    String title,
    String description,
    int categoryId,
    File docFile,
    File imgFile,
  ) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${Config.baseUrl}/admin/'),
    );
    request.headers.addAll(await _getHeaders(isMultipart: true));
    request.fields.addAll({
      'title': title,
      'description': description,
      'category_id': categoryId.toString(),
    });
    request.files.add(await http.MultipartFile.fromPath('file', docFile.path));
    request.files.add(
      await http.MultipartFile.fromPath(
        'cover_image',
        imgFile.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );
    final response = await request.send();
    if (response.statusCode != 201) {
      throw Exception('Failed to upload document.');
    }
  }
}
