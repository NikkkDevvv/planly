import '../datasources/remote/note_remote_ds.dart';
import '../models/note_model.dart';

class NoteRepository {
  final NoteRemoteDataSource _remoteDataSource = NoteRemoteDataSource();

  Future<List<NoteModel>> getNotes() async {
    final response = await _remoteDataSource.getNotes();
    if (response.statusCode == 200) {
      final List<dynamic> list = response.data;
      return list.map((item) => NoteModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load notes');
    }
  }

  Future<NoteModel> createNote(NoteModel note) async {
    final response = await _remoteDataSource.createNote(note.toJson());
    if (response.statusCode == 201 || response.statusCode == 200) {
      return NoteModel.fromJson(response.data);
    } else {
      throw Exception('Failed to create note');
    }
  }

  Future<NoteModel> updateNote(int id, NoteModel note) async {
    final response = await _remoteDataSource.updateNote(id, note.toJson());
    if (response.statusCode == 200) {
      return NoteModel.fromJson(response.data);
    } else {
      throw Exception('Failed to update note');
    }
  }

  Future<void> deleteNote(int id) async {
    final response = await _remoteDataSource.deleteNote(id);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete note');
    }
  }
}
