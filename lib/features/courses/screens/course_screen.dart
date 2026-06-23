import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import 'add_course_screen.dart';
import '../../../data/models/course_model.dart';
import '../bloc/courses_bloc.dart';
import '../bloc/courses_event.dart';
import '../bloc/courses_state.dart';
import '../../navigation/screens/main_layout.dart';
import '../widgets/course_card.dart';

class CoursesScreens extends StatefulWidget {
  const CoursesScreens({super.key});

  @override
  State<CoursesScreens> createState() => _CoursesScreensState();
}

class _CoursesScreensState extends State<CoursesScreens> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<CoursesBloc>().add(FetchCourses());
  }

  int _calculateTotalSKS(List<CourseModel> courses) {
    return courses.fold(0, (sum, item) => sum + item.credits);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Daftar Mata Kuliah',
          style: TextStyle(
            color: AppColors.textLightPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: BlocBuilder<CoursesBloc, CoursesState>(
        builder: (context, state) {
          if (state is CoursesLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          } else if (state is CoursesError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Gagal memuat mata kuliah: ${state.message}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            );
          } else if (state is CoursesLoaded) {
            final allCourses = state.courses;
            final courses = allCourses.where((c) {
              return c.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                     c.course_code.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();
            final totalSKS = _calculateTotalSKS(courses);

            return RefreshIndicator(
              onRefresh: () async {
                context.read<CoursesBloc>().add(FetchCourses());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
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
                            hintText: 'Cari mata kuliah...',
                            hintStyle: TextStyle(color: AppColors.textLightSecondary, fontSize: 14),
                            prefixIcon: Icon(Icons.search, color: AppColors.secondary, size: 20),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
                      child: Text(
                        '$totalSKS SKS Terdaftar • ${courses.length} Mata Kuliah',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textLightSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (courses.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100),
                          child: Column(
                            children: [
                              Icon(
                                Icons.book_outlined,
                                size: 64,
                                color: AppColors.secondary.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Belum ada mata kuliah.\nKetuk + untuk menambahkan.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.textLightSecondary),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: courses.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: CourseCard(course: courses[index]),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCourseScreen()),
          ).then((_) {
            context.read<CoursesBloc>().add(FetchCourses());
          });
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}