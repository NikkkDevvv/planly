import '../../../data/models/note_model.dart';

abstract class NotesEvent {}

class FetchNotes extends NotesEvent {}

class AddNote extends NotesEvent {
  final NoteModel note;
  AddNote(this.note);
}

class UpdateNote extends NotesEvent {
  final int id;
  final NoteModel note;
  UpdateNote({required this.id, required this.note});
}

class DeleteNote extends NotesEvent {
  final int id;
  DeleteNote(this.id);
}
