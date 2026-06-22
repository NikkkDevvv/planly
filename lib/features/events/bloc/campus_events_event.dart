import '../../../data/models/campus_event_model.dart';

abstract class CampusEventsEvent {}

class FetchCampusEvents extends CampusEventsEvent {}

class AddCampusEvent extends CampusEventsEvent {
  final CampusEventModel event;
  AddCampusEvent(this.event);
}

class UpdateCampusEvent extends CampusEventsEvent {
  final int id;
  final CampusEventModel event;
  UpdateCampusEvent(this.id, this.event);
}

class DeleteCampusEvent extends CampusEventsEvent {
  final int id;
  DeleteCampusEvent(this.id);
}
