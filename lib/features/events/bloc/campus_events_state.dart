import '../../../data/models/campus_event_model.dart';

abstract class CampusEventsState {}

class CampusEventsInitial extends CampusEventsState {}

class CampusEventsLoading extends CampusEventsState {}

class CampusEventsLoaded extends CampusEventsState {
  final List<CampusEventModel> events;
  CampusEventsLoaded(this.events);
}

class CampusEventsError extends CampusEventsState {
  final String message;
  CampusEventsError(this.message);
}
