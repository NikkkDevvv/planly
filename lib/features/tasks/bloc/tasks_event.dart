import '../../../data/models/task_model.dart';

abstract class TasksEvent {}

class FetchTasks extends TasksEvent {}

class AddTask extends TasksEvent {
  final TaskModel task;
  AddTask(this.task);
}

class FinishTask extends TasksEvent {
  final int id;
  FinishTask(this.id);
}

class UpdateTask extends TasksEvent {
  final int id;
  final TaskModel task;
  UpdateTask({required this.id, required this.task});
}

class DeleteTask extends TasksEvent {
  final int id;
  DeleteTask(this.id);
}
