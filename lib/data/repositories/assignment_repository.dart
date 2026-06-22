import '../datasources/remote/assignment_remote_ds.dart';
import '../models/task_model.dart';

class AssignmentRepository {
  final AssignmentRemoteDataSource _remoteDataSource = AssignmentRemoteDataSource();

  Future<List<TaskModel>> getTasks() async {
    final response = await _remoteDataSource.getTasks();
    if (response.statusCode == 200) {
      final List<dynamic> list = response.data;
      return list.map((item) => TaskModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<TaskModel> createTask(TaskModel task) async {
    final response = await _remoteDataSource.createTask(task.toJson());
    if (response.statusCode == 201 || response.statusCode == 200) {
      return TaskModel.fromJson(response.data);
    } else {
      throw Exception('Failed to create task');
    }
  }

  Future<void> finishTask(int id) async {
    final response = await _remoteDataSource.finishTask(id);
    if (response.statusCode != 200) {
      throw Exception('Failed to update task status');
    }
  }

  Future<TaskModel> updateTask(int id, TaskModel task) async {
    final response = await _remoteDataSource.updateTask(id, task.toJson());
    if (response.statusCode == 200) {
      return TaskModel.fromJson(response.data);
    } else {
      throw Exception('Failed to update task');
    }
  }

  Future<void> deleteTask(int id) async {
    final response = await _remoteDataSource.deleteTask(id);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete task');
    }
  }
}
