import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/note_repository.dart';
import 'notes_event.dart';
import 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NoteRepository _noteRepository = NoteRepository();

  NotesBloc() : super(NotesInitial()) {
    on<FetchNotes>(_onFetchNotes);
    on<AddNote>(_onAddNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
  }

  Future<void> _onFetchNotes(FetchNotes event, Emitter<NotesState> emit) async {
    emit(NotesLoading());
    try {
      final notes = await _noteRepository.getNotes();
      emit(NotesLoaded(notes));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onAddNote(AddNote event, Emitter<NotesState> emit) async {
    try {
      await _noteRepository.createNote(event.note);
      add(FetchNotes());
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onUpdateNote(UpdateNote event, Emitter<NotesState> emit) async {
    try {
      await _noteRepository.updateNote(event.id, event.note);
      add(FetchNotes());
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onDeleteNote(DeleteNote event, Emitter<NotesState> emit) async {
    try {
      await _noteRepository.deleteNote(event.id);
      add(FetchNotes());
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }
}
