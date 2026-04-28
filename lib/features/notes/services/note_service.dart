import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/note_model.dart';

class NoteService {
  final String base_url = dotenv.env['API_BASE_URL'] ?? '';

  // Mengambil token otorisasi
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('auth_token') ?? '';

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<NoteModel>> get_notes() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$base_url/notes'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => NoteModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load notes: ${response.statusCode}');
    }
  }

  Future<NoteModel> create_note(Map<String, dynamic> note_data) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$base_url/notes'),
      headers: headers,
      body: jsonEncode(note_data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return NoteModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create note: ${response.body}');
    }
  }

  Future<NoteModel> update_note(
    int note_id,
    Map<String, dynamic> note_data,
  ) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$base_url/notes/$note_id'),
      headers: headers,
      body: jsonEncode(note_data),
    );

    if (response.statusCode == 200) {
      return NoteModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update note: ${response.body}');
    }
  }

  Future<bool> delete_note(int note_id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$base_url/notes/$note_id'),
      headers: headers,
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }
}
