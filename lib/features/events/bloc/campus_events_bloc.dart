import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/campus_event_repository.dart';
import 'campus_events_event.dart';
import 'campus_events_state.dart';

class CampusEventsBloc extends Bloc<CampusEventsEvent, CampusEventsState> {
  final CampusEventRepository _repository = CampusEventRepository();

  CampusEventsBloc() : super(CampusEventsInitial()) {
    on<FetchCampusEvents>(_onFetchCampusEvents);
    on<AddCampusEvent>(_onAddCampusEvent);
    on<UpdateCampusEvent>(_onUpdateCampusEvent);
    on<DeleteCampusEvent>(_onDeleteCampusEvent);
  }

  Future<void> _onFetchCampusEvents(
    FetchCampusEvents event,
    Emitter<CampusEventsState> emit,
  ) async {
    emit(CampusEventsLoading());
    try {
      final events = await _repository.getEvents();
      emit(CampusEventsLoaded(events));
    } catch (e) {
      emit(CampusEventsError(e.toString()));
    }
  }

  Future<void> _onAddCampusEvent(
    AddCampusEvent event,
    Emitter<CampusEventsState> emit,
  ) async {
    try {
      await _repository.createEvent(event.event);
      add(FetchCampusEvents());
    } catch (e) {
      emit(CampusEventsError(e.toString()));
    }
  }

  Future<void> _onUpdateCampusEvent(
    UpdateCampusEvent event,
    Emitter<CampusEventsState> emit,
  ) async {
    try {
      await _repository.updateEvent(event.id, event.event);
      add(FetchCampusEvents());
    } catch (e) {
      emit(CampusEventsError(e.toString()));
    }
  }

  Future<void> _onDeleteCampusEvent(
    DeleteCampusEvent event,
    Emitter<CampusEventsState> emit,
  ) async {
    try {
      await _repository.deleteEvent(event.id);
      add(FetchCampusEvents());
    } catch (e) {
      emit(CampusEventsError(e.toString()));
    }
  }
}
