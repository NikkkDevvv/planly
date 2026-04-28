import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/models/task_model.dart';
import '../services/task_service.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';

class TasksScreens extends StatefulWidget {
  const TasksScreens({super.key});

  @override
  State<TasksScreens> createState() => _TasksScreensState();
}

class _TasksScreensState extends State<TasksScreens> {
  final TaskService _taskService = TaskService();
  late Future<List<TaskModel>> _futureTasks;

  @override
  void initState() {
    super.initState();
    _futureTasks = _taskService.get_all_tasks();
  }

  String _formatTimeDisplay(String dateStr, String timeStr) {
    try {
      DateTime deadlineDate = DateTime.parse(dateStr);
      DateTime today = DateTime.now();
      DateTime tomorrow = today.add(const Duration(days: 1));
      DateTime yesterday = today.subtract(const Duration(days: 1));

      bool isToday = deadlineDate.year == today.year && deadlineDate.month == today.month && deadlineDate.day == today.day;
      bool isTomorrow = deadlineDate.year == tomorrow.year && deadlineDate.month == tomorrow.month && deadlineDate.day == tomorrow.day;
      bool isYesterday = deadlineDate.year == yesterday.year && deadlineDate.month == yesterday.month && deadlineDate.day == yesterday.day;

      if (isToday) return 'Today, $timeStr';
      if (isTomorrow) return 'Tomorrow, $timeStr';
      if (isYesterday) return 'Yesterday, $timeStr';

      const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[deadlineDate.month]} ${deadlineDate.day}, $timeStr';
    } catch (e) {
      return '$dateStr $timeStr';
    }
  }

  bool _isOverdue(String dateStr) {
    try {
      DateTime deadlineDate = DateTime.parse(dateStr);
      DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      return deadlineDate.isBefore(today);
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(
                top: 48,
                left: 24,
                right: 24,
                bottom: 16,
              ),
              child: Text(
                'My Tasks',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            const TabBar(
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.onSurfaceVariant,
              indicatorWeight: 3,
              tabs: [
                Tab(text: 'Pending'),
                Tab(text: 'Done'),
              ],
            ),
            Expanded(
              child: FutureBuilder<List<TaskModel>>(
                future: _futureTasks,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No tasks available'));
                  }

                  final allTasks = snapshot.data!;
                  final pendingTasks = allTasks.where((t) => t.status.toLowerCase() != 'done').toList();
                  final doneTasks = allTasks.where((t) => t.status.toLowerCase() == 'done').toList();

                  return TabBarView(
                    children: [
                      ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: pendingTasks.length,
                        itemBuilder: (context, index) {
                          final task = pendingTasks[index];
                          bool isOverdue = _isOverdue(task.deadline_date);
                          
                          String? statusLabel;
                          if (isOverdue) {
                            statusLabel = 'Overdue';
                          } else if (task.is_priority) {
                            statusLabel = 'High Priority';
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _buildTaskCard(
                              context,
                              task: task,
                              title: task.title,
                              category: 'Course ID: ${task.course_id ?? 'General'}',
                              time: _formatTimeDisplay(task.deadline_date, task.deadline_time),
                              statusLabel: statusLabel,
                              isOverdue: isOverdue,
                              isPriority: task.is_priority,
                              isDone: false,
                            ),
                          );
                        },
                      ),
                      ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: doneTasks.length,
                        itemBuilder: (context, index) {
                          final task = doneTasks[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _buildTaskCard(
                              context,
                              task: task,
                              title: task.title,
                              category: 'Course ID: ${task.course_id ?? 'General'}',
                              time: _formatTimeDisplay(task.deadline_date, task.deadline_time),
                              isDone: true,
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddTaskScreen()),
              );
            },
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context, {
    required TaskModel task,
    required String title,
    required String category,
    required String time,
    String? statusLabel,
    bool isOverdue = false,
    bool isPriority = false,
    bool isDone = false,
  }) {
    Color timeIconColor = isOverdue
        ? const Color(0xFFBA1A1A)
        : (isPriority ? AppColors.primary : AppColors.onSurfaceVariant);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isDone ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isDone ? AppColors.primary : AppColors.outline,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDone
                                ? AppColors.onSurfaceVariant
                                : AppColors.onSurface,
                            decoration: isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      if (statusLabel != null && !isDone)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isOverdue
                                ? const Color(0xFFFFDAD6)
                                : AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isOverdue
                                  ? const Color(0xFFBA1A1A)
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: isDone
                            ? AppColors.onSurfaceVariant
                            : timeIconColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDone
                              ? AppColors.onSurfaceVariant
                              : timeIconColor,
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
    );
  }
}
