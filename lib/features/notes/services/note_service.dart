import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../auth/models/note_model.dart';

class NoteService {
  final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000/api';

  Future<List<NoteModel>> getAllNotes(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notes?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => NoteModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load notes');
      }
    } catch (e) {
      // Mockup Data sebagai Fallback jika API belum menyala
      await Future.delayed(const Duration(milliseconds: 800));
      return [
        NoteModel(
          id: 1,
          userId: userId,
          courseId: 1, // Misal ID course Advanced Physics
          title: 'Quantum Entanglement Basics',
          content:
              'The fundamental concept relies on two particles interacting such that the quantum state of each particle cannot be described independently of the state of the other(s), even when the particles are separated by a large distance...',
        ),
        NoteModel(
          id: 2,
          userId: userId,
          courseId: 2, // Misal ID course Design History
          title: 'Bauhaus Movement',
          content:
              'Form follows function. The integration of art, craft, and technology. Walter Gropius founded it in Weimar in 1919. Minimalist, geometric, and functional design principles.',
        ),
        NoteModel(
          id: 3,
          userId: userId,
          courseId: null, // Tanpa course (General)
          title: 'Agile Methodologies',
          content:
              'Scrum framework: Sprints, Daily Standups, Sprint Review, Retrospective. Emphasis on iterative progress and adaptability.',
        ),
      ];
    }
  }

  Future<NoteModel> createNote(Map<String, dynamic> noteData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(noteData),
      );

      if (response.statusCode == 201) {
        return NoteModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create note');
      }
    } catch (e) {
      await Future.delayed(const Duration(seconds: 1));
      return NoteModel(
        id: DateTime.now().millisecondsSinceEpoch,
        userId: noteData['user_id'],
        courseId: noteData['course_id'],
        title: noteData['title'],
        content: noteData['content'],
      );
    }
  }

  Future<NoteModel> updateNote(
    int noteId,
    Map<String, dynamic> noteData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notes/$noteId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(noteData),
      );

      if (response.statusCode == 200) {
        return NoteModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update note');
      }
    } catch (e) {
      await Future.delayed(const Duration(seconds: 1));
      return NoteModel(
        id: noteId,
        userId: noteData['user_id'],
        courseId: noteData['course_id'],
        title: noteData['title'],
        content: noteData['content'],
      );
    }
  }

  Future<void> deleteNote(int noteId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/notes/$noteId'));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete note');
      }
    } catch (e) {
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}
