import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/course_model.dart';
import '../../courses/services/course_service.dart';
import '../services/task_service.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';

class TasksScreens extends StatefulWidget {
  const TasksScreens({super.key});

  @override
  State<TasksScreens> createState() => _TasksScreensState();
}

class _TasksScreensState extends State<TasksScreens> {
  final TaskService _task_service = TaskService();
  final CourseService _course_service = CourseService();
  
  late Future<List<TaskModel>> _future_tasks;
  List<CourseModel> _courses = [];

  @override
  void initState() {
    super.initState();
    _refresh_data();
  }

  void _refresh_data() {
    setState(() {
      _future_tasks = _task_service.get_all_tasks();
      _load_courses();
    });
  }

  Future<void> _load_courses() async {
    try {
      final courses = await _course_service.get_courses();
      setState(() => _courses = courses);
    } catch (e) {
      debugPrint("Error loading courses: $e");
    }
  }

  String _get_course_name(int? id) {
    if (id == null) return 'General / Personal';
    final course = _courses.firstWhere(
      (c) => c.id == id, 
      orElse: () => CourseModel(id: 0, user_id: 0, course_code: '', name: 'Unknown', credits: 0, lecturer: '', room: '', day_of_week: '', start_time: '', end_time: '', color_hex: '')
    );
    return course.name;
  }

  String _format_deadline(String date_str, String time_str) {
    try {
      DateTime dt = DateTime.parse("$date_str $time_str");
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime target_date = DateTime(dt.year, dt.month, dt.day);

      String time_part = DateFormat('h:mm a').format(dt);
      
      if (target_date == today) return "Today, $time_part";
      if (target_date == today.subtract(const Duration(days: 1))) return "Yesterday, $time_part";
      if (target_date == today.add(const Duration(days: 1))) return "Tomorrow, $time_part";
      
      return "${DateFormat('EEE, MMM d').format(dt)}, $time_part";
    } catch (e) {
      return "$date_str, $time_str";
    }
  }

  bool _check_overdue(String date_str) {
    try {
      DateTime dt = DateTime.parse(date_str);
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      return dt.isBefore(today);
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                'My Tasks',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
            ),
            const TabBar(
              indicatorColor: Color(0xFF6366F1),
              indicatorWeight: 3,
              labelColor: Color(0xFF6366F1),
              unselectedLabelColor: Colors.grey,
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
              tabs: [Tab(text: 'Pending'), Tab(text: 'Done')],
            ),
            Expanded(
              child: FutureBuilder<List<TaskModel>>(
                future: _future_tasks,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final all_tasks = snapshot.data ?? [];
                  final pending = all_tasks.where((t) => !t.is_finished).toList();
                  final done = all_tasks.where((t) => t.is_finished).toList();

                  return TabBarView(
                    children: [
                      _build_task_list(pending),
                      _build_task_list(done),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF6366F1),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onPressed: () async {
            final result = await Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const AddTaskScreen())
            );
            if (result == true) _refresh_data();
          },
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _build_task_list(List<TaskModel> tasks) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text("No tasks found", style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _build_task_card(task);
      },
    );
  }

  Widget _build_task_card(TaskModel task) {
    bool is_overdue = _check_overdue(task.deadline_date) && !task.is_finished;
    Color time_color = is_overdue ? const Color(0xFFEF4444) : const Color(0xFF6366F1);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
            );
            if (result == true) _refresh_data();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: task.is_finished,
                    activeColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) async {
                      await _task_service.finish_task(task.id);
                      _refresh_data();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                                decoration: task.is_finished ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                          if (is_overdue) _build_badge("Overdue", const Color(0xFFFEE2E2), const Color(0xFFEF4444)),
                          if (task.is_priority && !is_overdue && !task.is_finished) 
                            _build_badge("High Priority", const Color(0xFFEEF2FF), const Color(0xFF6366F1)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _get_course_name(task.course_id),
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: time_color),
                          const SizedBox(width: 6),
                          Text(
                            _format_deadline(task.deadline_date, task.deadline_time),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: time_color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _build_badge(String text, Color bg, Color text_color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(
        text, 
        style: TextStyle(color: text_color, fontSize: 10, fontWeight: FontWeight.bold)
      ),
    );
  }
}