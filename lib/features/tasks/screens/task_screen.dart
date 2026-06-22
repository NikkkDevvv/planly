import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/course_model.dart';
import '../../courses/bloc/courses_bloc.dart';
import '../../courses/bloc/courses_state.dart';
import '../bloc/tasks_bloc.dart';
import '../bloc/tasks_event.dart';
import '../bloc/tasks_state.dart';
import '../../navigation/screens/main_layout.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';

class TasksScreens extends StatefulWidget {
  const TasksScreens({super.key});

  @override
  State<TasksScreens> createState() => _TasksScreensState();
}

class _TasksScreensState extends State<TasksScreens> {
  String _searchQuery = '';
  int? _selectedCourseId;

  @override
  void initState() {
    super.initState();
    context.read<TasksBloc>().add(FetchTasks());
  }

  String _getCourseName(List<CourseModel> courses, int? id) {
    if (id == null) return 'Umum / Personal';
    final course = courses.firstWhere(
      (c) => c.id == id,
      orElse: () => CourseModel(
        id: 0,
        user_id: 0,
        course_code: '',
        name: 'Tidak Diketahui',
        credits: 0,
        lecturer: '',
        room: '',
        day_of_week: '',
        start_time: '',
        end_time: '',
        color_hex: '#64748B',
      ),
    );
    return course.name;
  }

  String _formatDeadline(String dateStr, String timeStr) {
    try {
      DateTime dt = DateTime.parse("$dateStr $timeStr");
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime targetDate = DateTime(dt.year, dt.month, dt.day);

      String timePart = DateFormat('HH:mm').format(dt);
      
      if (targetDate == today) return "Hari Ini, $timePart";
      if (targetDate == today.subtract(const Duration(days: 1))) return "Kemarin, $timePart";
      if (targetDate == today.add(const Duration(days: 1))) return "Besok, $timePart";
      
      return "${DateFormat('EEEE, d MMM', 'id_ID').format(dt)}, $timePart";
    } catch (e) {
      return "$dateStr, $timeStr";
    }
  }

  bool _checkOverdue(String dateStr) {
    try {
      DateTime dt = DateTime.parse(dateStr);
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
        backgroundColor: AppColors.bgLight,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.primary),
              onPressed: () => context.findAncestorStateOfType<MainLayoutState>()?.openDrawer(),
            ),
          ),
          title: const Text(
            'Tugas Kuliah',
            style: TextStyle(
              color: AppColors.textLightPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [Tab(text: 'Belum Selesai'), Tab(text: 'Selesai')],
          ),
        ),
        body: BlocBuilder<CoursesBloc, CoursesState>(
          builder: (context, coursesState) {
            List<CourseModel> courses = [];
            if (coursesState is CoursesLoaded) {
              courses = coursesState.courses;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search and Filter Bar
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.bgLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.outlineLight),
                          ),
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: 'Cari tugas...',
                              hintStyle: TextStyle(color: AppColors.textLightSecondary, fontSize: 14),
                              prefixIcon: Icon(Icons.search, color: AppColors.secondary, size: 20),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.bgLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outlineLight),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int?>(
                            value: _selectedCourseId,
                            icon: const Icon(Icons.filter_list, size: 20, color: AppColors.primary),
                            style: const TextStyle(color: AppColors.textLightPrimary, fontSize: 14),
                            onChanged: (int? newValue) {
                              setState(() {
                                _selectedCourseId = newValue;
                              });
                            },
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('Semua Mata Kuliah'),
                              ),
                              const DropdownMenuItem<int?>(
                                value: 0,
                                child: Text('Umum / Personal'),
                              ),
                              ...courses.map((course) {
                                return DropdownMenuItem<int?>(
                                  value: course.id,
                                  child: Text(
                                    course.name.length > 15 ? '${course.name.substring(0, 15)}...' : course.name,
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: BlocBuilder<TasksBloc, TasksState>(
                    builder: (context, state) {
                      if (state is TasksLoading) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                      } else if (state is TasksError) {
                        return Center(child: Text('Gagal memuat tugas: ${state.message}'));
                      } else if (state is TasksLoaded) {
                        // Apply filters
                        var filteredTasks = state.tasks.where((t) {
                          bool matchSearch = t.title.toLowerCase().contains(_searchQuery.toLowerCase());
                          bool matchCourse = true;
                          if (_selectedCourseId != null) {
                            if (_selectedCourseId == 0) {
                              matchCourse = t.course_id == null;
                            } else {
                              matchCourse = t.course_id == _selectedCourseId;
                            }
                          }
                          return matchSearch && matchCourse;
                        }).toList();

                        final pending = filteredTasks.where((t) => !t.is_finished).toList();
                        final done = filteredTasks.where((t) => t.is_finished).toList();

                        return TabBarView(
                          children: [
                            _buildTaskList(pending, courses),
                            _buildTaskList(done, courses),
                          ],
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddTaskScreen()),
            );
          },
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }

  Widget _buildTaskList(List<TaskModel> tasks, List<CourseModel> courses) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text("Tidak ada tugas ditemukan", style: TextStyle(color: AppColors.secondary)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task, courses);
      },
    );
  }

  Widget _buildTaskCard(TaskModel task, List<CourseModel> courses) {
    bool isOverdue = _checkOverdue(task.deadline_date) && !task.is_finished;
    Color timeColor = isOverdue ? AppColors.error : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineLight),
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
            );
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
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) {
                      if (val == true) {
                        context.read<TasksBloc>().add(FinishTask(task.id));
                      }
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
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textLightPrimary,
                                decoration: task.is_finished ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                          if (isOverdue)
                            _buildBadge("Terlambat", AppColors.errorContainer, AppColors.error)
                          else if (task.priority == 'high' && !task.is_finished)
                            _buildBadge("Prioritas Tinggi", AppColors.primaryContainer, AppColors.primary),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getCourseName(courses, task.course_id),
                        style: const TextStyle(color: AppColors.secondary, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: timeColor),
                          const SizedBox(width: 6),
                          Text(
                            _formatDeadline(task.deadline_date, task.deadline_time),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: timeColor,
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

  Widget _buildBadge(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        text, 
        style: TextStyle(color: textColor, fontSize: 9, fontWeight: FontWeight.bold)
      ),
    );
  }
}