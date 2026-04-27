import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/home/screens/home_screen.dart';
import '../../../features/schedules/screens/schedule_screen.dart';
import '../../../features/courses/screens/course_screen.dart';
import '../../../features/notes/screens/note_screen.dart';
import '../../../features/profile/screens/profile_screen.dart';
import '../../../features/tasks/screens/task_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // Daftar urutan halaman yang akan ditampilkan
  final List<Widget> _screens = const [
    HomeScreens(),
    ScheduleScreens(),
    TasksScreens(),
    CoursesScreens(),
    NotesScreens(),
    ProfileScreens(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      // Top App Bar
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 24,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.secondaryContainer,
              child: Icon(Icons.person, size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            const Text(
              'Planly',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
              color: AppColors.primary,
            ),
            padding: const EdgeInsets.only(right: 24),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.outlineVariant.withOpacity(0.3),
            height: 1.0,
          ),
        ),
      ),
      // Main Content Canvas
      body: IndexedStack(index: _selectedIndex, children: _screens),
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: AppColors.primaryContainer.withOpacity(0.2),
              labelTextStyle: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  );
                }
                return const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                );
              }),
            ),
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              backgroundColor: Colors.white,
              elevation: 0,
              height: 70,
              // Penambahan destinasi menjadi 6 menu
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined, color: Colors.grey),
                  selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
                  label: 'TODAY',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined, color: Colors.grey),
                  selectedIcon: Icon(
                    Icons.calendar_month,
                    color: AppColors.primary,
                  ),
                  label: 'CALENDAR',
                ),
                NavigationDestination(
                  icon: Icon(Icons.checklist_outlined, color: Colors.grey),
                  selectedIcon: Icon(Icons.checklist, color: AppColors.primary),
                  label: 'TASKS',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_book_outlined, color: Colors.grey),
                  selectedIcon: Icon(Icons.menu_book, color: AppColors.primary),
                  label: 'COURSES',
                ),
                NavigationDestination(
                  icon: Icon(Icons.description_outlined, color: Colors.grey),
                  selectedIcon: Icon(
                    Icons.description,
                    color: AppColors.primary,
                  ),
                  label: 'NOTES',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline, color: Colors.grey),
                  selectedIcon: Icon(Icons.person, color: AppColors.primary),
                  label: 'PROFILE',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
