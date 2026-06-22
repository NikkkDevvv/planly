import '../../../data/models/note_model.dart';

abstract class NotesState {}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  final List<NoteModel> notes;
  NotesLoaded(this.notes);
}

class NotesError extends NotesState {
  final String message;
  NotesError(this.message);
}
