import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../auth/models/task_model.dart';

class TaskService {
  final String base_url = dotenv.env['API_BASE_URL'] ?? '';

  Future<List<TaskModel>> get_tasks_by_course(int courseId) async {
    try {
      final response = await http.get(Uri.parse('$base_url/tasks?course_id=$courseId'));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => TaskModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load tasks');
      }
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 800));
      return [
        TaskModel(
          id: 101,
          userId: 1,
          courseId: courseId,
          title: 'Assignment 1: lorem ipsum dolor sit amet.',
          description: 'lorem ipsum dolor sit amet .',
          deadlineDate: '2026-10-25',
          deadlineTime: '23:59',
          status: 'pending',
          isPriority: true,
        ),
        TaskModel(
          id: 102,
          userId: 1,
          courseId: courseId,
          title: 'lorem ipsum dolor sit amet.',
          description: 'lorem ipsum dolor sit amet.',
          deadlineDate: '2026-11-01',
          deadlineTime: '10:00',
          status: 'pending',
          isPriority: false,
        )
      ];
    }
  }

  Future<List<TaskModel>> get_all_tasks(int userId) async {
    try {
      final response = await http.get(Uri.parse('$base_url/tasks?user_id=$userId'));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => TaskModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load all tasks');
      }
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 800));
      return [
        TaskModel(
          id: 101,
          userId: userId,
          courseId: 1,
          title: 'Assignment 1: lorem ipsum dolor sit amet.',
          description: 'Review the latest metrics and compile the slide deck.',
          deadlineDate: DateTime.now().subtract(const Duration(days: 1)).toString().split(' ')[0],
          deadlineTime: '17:00',
          status: 'pending',
          isPriority: true,
        ),
        TaskModel(
          id: 102,
          userId: userId,
          courseId: 2,
          title: 'lorem ipsum dolor sit amet.',
          description: 'Check new color palettes and typography rules.',
          deadlineDate: DateTime.now().toString().split(' ')[0],
          deadlineTime: '23:59',
          status: 'pending',
          isPriority: true,
        ),
        TaskModel(
          id: 103,
          userId: userId,
          courseId: 3,
          title: 'Sync with Engineering Lead',
          description: 'Discuss backend architecture for the new module.',
          deadlineDate: DateTime.now().add(const Duration(days: 1)).toString().split(' ')[0],
          deadlineTime: '10:00',
          status: 'pending',
          isPriority: false,
        ),
        TaskModel(
          id: 104,
          userId: userId,
          courseId: 1,
          title: 'Draft User Persona (Done)',
          description: 'Create initial personas for the upcoming UX research phase.',
          deadlineDate: '2026-04-20',
          deadlineTime: '14:00',
          status: 'done',
          isPriority: false,
        ),
      ];
    }
  }

  Future<TaskModel> create_task(Map<String, dynamic> taskData) async {
    try {
      final response = await http.post(
        Uri.parse('$base_url/tasks'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(taskData),
      );

      if (response.statusCode == 201) {
        return TaskModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create task');
      }
    } catch (e) {
      await Future.delayed(const Duration(seconds: 2));
      return TaskModel(
        id: DateTime.now().millisecondsSinceEpoch,
        userId: taskData['user_id'],
        courseId: taskData['course_id'],
        title: taskData['title'],
        description: taskData['description'],
        deadlineDate: taskData['deadline_date'],
        deadlineTime: taskData['deadline_time'],
        status: taskData['status'],
        isPriority: taskData['is_priority'] ?? false,
      );
    }
  }

  Future<TaskModel> update_task(int taskId, Map<String, dynamic> taskData) async {
    try {
      final response = await http.put(
        Uri.parse('$base_url/tasks/$taskId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(taskData),
      );

      if (response.statusCode == 200) {
        return TaskModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update task');
      }
    } catch (e) {
      await Future.delayed(const Duration(seconds: 2));
      return TaskModel(
        id: taskId,
        userId: taskData['user_id'],
        courseId: taskData['course_id'],
        title: taskData['title'],
        description: taskData['description'],
        deadlineDate: taskData['deadline_date'],
        deadlineTime: taskData['deadline_time'],
        status: taskData['status'],
        isPriority: taskData['is_priority'] ?? false,
      );
    }
  }

  Future<void> delete_task(int taskId) async {
    try {
      final response = await http.delete(Uri.parse('$base_url/tasks/$taskId'));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete task');
      }
    } catch (e) {
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}