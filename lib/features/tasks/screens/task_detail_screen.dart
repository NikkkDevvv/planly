import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/models/task_model.dart';
import '../services/task_service.dart';
import 'edit_task_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final TaskService _taskService = TaskService();
  bool _isLoading = false;

  bool _isOverdue(String dateStr) {
    if (widget.task.status.toLowerCase() == 'done') return false;
    try {
      DateTime deadlineDate = DateTime.parse(dateStr);
      DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      return deadlineDate.isBefore(today);
    } catch (e) {
      return false;
    }
  }

  String _formatDateTime(String dateStr, String timeStr) {
    try {
      DateTime d = DateTime.parse(dateStr);
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[d.month]} ${d.day}, ${d.year} - $timeStr';
    } catch (e) {
      return '$dateStr - $timeStr';
    }
  }

  Future<void> _deleteTask() async {
    setState(() => _isLoading = true);
    try {
      await _taskService.delete_task(widget.task.id);
      if (mounted) {
        Navigator.pop(context, true); // Kembali ke list dan bawa nilai true untuk refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _completeTask() async {
    setState(() => _isLoading = true);
    try {
      final Map<String, dynamic> updatedData = {
        'user_id': widget.task.user_id,
        'course_id': widget.task.course_id,
        'title': widget.task.title,
        'description': widget.task.description,
        'deadline_date': widget.task.deadline_date,
        'deadline_time': widget.task.deadline_time,
        'status': 'done', // Ubah status menjadi done
        'is_priority': widget.task.is_priority,
      };

      await _taskService.update_task(widget.task.id, updatedData);
      
      if (mounted) {
        Navigator.pop(context, true); // Kembali ke list dan bawa nilai true untuk refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDone = widget.task.status.toLowerCase() == 'done';
    final bool isOverdue = _isOverdue(widget.task.deadline_date);
    
    Color statusColor = AppColors.primary;
    Color statusBgColor = AppColors.primaryContainer;
    String statusText = 'Pending';

    if (isDone) {
      statusColor = Colors.green;
      statusBgColor = Colors.green.withOpacity(0.2);
      statusText = 'Completed';
    } else if (isOverdue) {
      statusColor = const Color(0xFFBA1A1A);
      statusBgColor = const Color(0xFFFFDAD6);
      statusText = 'Overdue';
    } else if (widget.task.is_priority) {
      statusText = 'High Priority';
    } else {
      statusColor = AppColors.onSurfaceVariant;
      statusBgColor = AppColors.surfaceContainerHigh;
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
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditTaskScreen(task: widget.task)),
              );
              if (result == true && mounted) {
                Navigator.pop(context, true); // Refresh layar sebelumnya
              }
            },
            child: const Text(
              'Edit',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: _isLoading ? null : () {
              // Tampilkan dialog konfirmasi sebelum menghapus
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Task'),
                  content: const Text('Are you sure you want to delete this task?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteTask();
                      },
                      child: const Text('Delete', style: TextStyle(color: Color(0xFFBA1A1A))),
                    ),
                  ],
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Color(0xFFBA1A1A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.outlineVariant.withOpacity(0.3),
            height: 1.0,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              top: 24,
              bottom: 96,
              left: 24,
              right: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.task.title,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDone ? AppColors.onSurfaceVariant : AppColors.onSurface,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.task.course_id != null ? 'Course ID: ${widget.task.course_id}' : 'General Task',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: statusColor.withOpacity(0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DEADLINE DATE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDateTime(widget.task.deadline_date, widget.task.deadline_time),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.calendar_today,
                        color: statusColor,
                        size: 28,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.outlineVariant.withOpacity(0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.task.description?.isNotEmpty == true ? widget.task.description! : 'No description provided.',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: Border(
            top: BorderSide(color: AppColors.outlineVariant.withOpacity(0.3)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (isDone || _isLoading) ? null : _completeTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDone ? Colors.grey.withOpacity(0.2) : AppColors.primaryContainer.withOpacity(0.3),
                foregroundColor: isDone ? Colors.grey : AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(isDone ? Icons.check : Icons.check_circle, size: 24),
              label: Text(
                isDone ? 'Task Completed' : 'Complete Task',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}