import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/task_model.dart';
import '../bloc/tasks_bloc.dart';
import '../bloc/tasks_event.dart';
import 'edit_task_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  bool _is_loading = false;

  bool _is_overdue(String date_str) {
    if (widget.task.is_finished) return false;
    try {
      DateTime deadline_date = DateTime.parse(date_str);
      DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      return deadline_date.isBefore(today);
    } catch (e) {
      return false;
    }
  }

  String _format_date_time(String date_str, String time_str) {
    try {
      DateTime d = DateTime.parse(date_str);
      const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[d.month]} ${d.day}, ${d.year} - $time_str';
    } catch (e) {
      return '$date_str - $time_str';
    }
  }

  void _delete_task() {
    context.read<TasksBloc>().add(DeleteTask(widget.task.id));
    Navigator.pop(context, true);
  }

  void _complete_task() {
    context.read<TasksBloc>().add(FinishTask(widget.task.id));
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final bool is_done = widget.task.is_finished;
    final bool is_overdue = _is_overdue(widget.task.deadline_date);

    Color status_color = AppColors.primary;
    Color status_bg_color = AppColors.primaryContainer;
    String status_text = 'Pending';

    if (is_done) {
      status_color = Colors.green;
      status_bg_color = Colors.green.withOpacity(0.2);
      status_text = 'Completed';
    } else if (is_overdue) {
      status_color = const Color(0xFFBA1A1A);
      status_bg_color = const Color(0xFFFFDAD6);
      status_text = 'Overdue';
    } else if (widget.task.is_priority) {
      status_text = 'High Priority';
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Task Detail',
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary),
            onPressed: _is_loading
                ? null
                : () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditTaskScreen(task: widget.task)),
                    );
                    if (result == true && mounted) Navigator.pop(context, true);
                  },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Color(0xFFBA1A1A)),
            onPressed: _is_loading
                ? null
                : () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Task'),
                        content: const Text('Are you sure?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _delete_task();
                            },
                            child: const Text('Delete', style: TextStyle(color: Color(0xFFBA1A1A))),
                          ),
                        ],
                      ),
                    );
                  },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.outlineVariant.withOpacity(0.3), height: 1.0),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: status_bg_color, borderRadius: BorderRadius.circular(16)),
                  child: Text(
                    status_text,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: status_color),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.task.title,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: is_done ? AppColors.onSurfaceVariant : AppColors.onSurface,
                    decoration: is_done ? TextDecoration.lineThrough : null,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.task.course_id != null ? 'Course ID: ${widget.task.course_id}' : 'General Task',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: status_color.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('DEADLINE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                          const SizedBox(height: 4),
                          Text(
                            _format_date_time(widget.task.deadline_date, widget.task.deadline_time),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: status_color),
                          ),
                        ],
                      ),
                      Icon(Icons.calendar_today, color: status_color, size: 24),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(
                  widget.task.description?.isNotEmpty == true ? widget.task.description! : 'No description.',
                  style: const TextStyle(fontSize: 16, color: AppColors.onSurfaceVariant, height: 1.5),
                ),
              ],
            ),
          ),
          if (_is_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.outlineVariant.withOpacity(0.3))),
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: (is_done || _is_loading) ? null : _complete_task,
            style: ElevatedButton.styleFrom(
              backgroundColor: is_done ? Colors.grey.withOpacity(0.2) : AppColors.primaryContainer,
              foregroundColor: is_done ? Colors.grey : AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            icon: Icon(is_done ? Icons.check : Icons.check_circle),
            label: Text(is_done ? 'Task Completed' : 'Complete Task', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}