import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/assignment_repository.dart';
import 'tasks_event.dart';
import 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final AssignmentRepository _assignmentRepository = AssignmentRepository();

  TasksBloc() : super(TasksInitial()) {
    on<FetchTasks>(_onFetchTasks);
    on<AddTask>(_onAddTask);
    on<FinishTask>(_onFinishTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
  }

  Future<void> _onFetchTasks(FetchTasks event, Emitter<TasksState> emit) async {
    emit(TasksLoading());
    try {
      final tasks = await _assignmentRepository.getTasks();
      emit(TasksLoaded(tasks));
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TasksState> emit) async {
    try {
      await _assignmentRepository.createTask(event.task);
      add(FetchTasks());
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  Future<void> _onFinishTask(FinishTask event, Emitter<TasksState> emit) async {
    try {
      await _assignmentRepository.finishTask(event.id);
      add(FetchTasks());
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TasksState> emit) async {
    try {
      await _assignmentRepository.updateTask(event.id, event.task);
      add(FetchTasks());
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TasksState> emit) async {
    try {
      await _assignmentRepository.deleteTask(event.id);
      add(FetchTasks());
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }
}
