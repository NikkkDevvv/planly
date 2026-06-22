import '../../../data/models/schedule_model.dart';

abstract class SchedulesEvent {}

class FetchSchedules extends SchedulesEvent {}

class SelectDate extends SchedulesEvent {
  final DateTime selectedDate;
  SelectDate(this.selectedDate);
}

class AddReschedule extends SchedulesEvent {
  final ScheduleModel reschedule;
  AddReschedule(this.reschedule);
}

class RemoveReschedule extends SchedulesEvent {
  final int courseId;
  final String originalDate;
  RemoveReschedule({required this.courseId, required this.originalDate});
}
