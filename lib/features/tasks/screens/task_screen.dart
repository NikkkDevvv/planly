import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';

class TasksScreens extends StatelessWidget {
  const TasksScreens({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan DefaultTabController untuk fitur swipe antar Tab
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
            // Tab Bar
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
            // Tab Bar View (Bisa di-swipe)
            Expanded(
              child: TabBarView(
                children: [
                  // Halaman 1: Pending Tasks
                  ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _buildTaskCard(
                        context,
                        title: 'Finalize Q3 Marketing Report',
                        category: 'Marketing Strategy',
                        time: 'Yesterday, 5:00 PM',
                        statusLabel: 'Overdue',
                        isOverdue: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTaskCard(
                        context,
                        title: 'Review Design System Updates',
                        category: 'Product Design',
                        time: 'Today, 11:59 PM',
                        statusLabel: 'High Priority',
                        isPriority: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTaskCard(
                        context,
                        title: 'Sync with Engineering Lead',
                        category: 'Sprint Planning',
                        time: 'Tomorrow, 10:00 AM',
                      ),
                    ],
                  ),
                  // Halaman 2: Done Tasks
                  ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _buildTaskCard(
                        context,
                        title: 'Draft User Persona',
                        category: 'UX Research',
                        time: 'Oct 20, 2:00 PM',
                        isDone: true,
                      ),
                    ],
                  ),
                ],
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
    required String title,
    required String category,
    required String time,
    String? statusLabel,
    bool isOverdue = false,
    bool isPriority = false,
    bool isDone = false, // Menandakan task selesai
  }) {
    Color timeIconColor = isOverdue
        ? const Color(0xFFBA1A1A)
        : (isPriority ? AppColors.primary : AppColors.onSurfaceVariant);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TaskDetailScreen()),
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
