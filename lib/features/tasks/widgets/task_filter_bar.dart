import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/course_model.dart';

class TaskFilterBar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final int? selectedCourseId;
  final ValueChanged<int?> onCourseChanged;
  final List<CourseModel> courses;

  const TaskFilterBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.selectedCourseId,
    required this.onCourseChanged,
    required this.courses,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                onChanged: onSearchChanged,
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
                value: selectedCourseId,
                icon: const Icon(Icons.filter_list, size: 20, color: AppColors.primary),
                style: const TextStyle(color: AppColors.textLightPrimary, fontSize: 14),
                onChanged: onCourseChanged,
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
    );
  }
}
