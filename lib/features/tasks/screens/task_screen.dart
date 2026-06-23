import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../widgets/task_card.dart';
import '../widgets/task_filter_bar.dart';

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
        return TaskCard(
          task: tasks[index],
          courses: courses,
        );
      },
    );
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
                TaskFilterBar(
                  searchQuery: _searchQuery,
                  onSearchChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  selectedCourseId: _selectedCourseId,
                  onCourseChanged: (newValue) {
                    setState(() {
                      _selectedCourseId = newValue;
                    });
                  },
                  courses: courses,
                ),

                // Tab Bar View content
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
            ).then((_) {
              context.read<TasksBloc>().add(FetchTasks());
            });
          },
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }
}