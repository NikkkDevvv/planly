import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
// import '../../home/screens/home_screens.dart'; // Akan digunakan di langkah selanjutnya

// Placeholder sementara untuk halaman selain Home
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, color: AppColors.onSurfaceVariant),
      ),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    PlaceholderScreen(
      title: 'Home Screen (Timeline)',
    ), // Nanti diganti HomeScreens()
    PlaceholderScreen(title: 'Calendar Screen'),
    PlaceholderScreen(title: 'Tasks Screen'),
    PlaceholderScreen(title: 'Notes Screen'),
    PlaceholderScreen(title: 'Profile Screen'),
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
                fontWeight: FontWeight.w900, // font-black di Tailwind
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
              indicatorColor: AppColors.primaryContainer.withOpacity(
                0.2,
              ), // bg-indigo-50/50
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
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.calendar_today_outlined, color: Colors.grey),
                  selectedIcon: Icon(
                    Icons.calendar_today,
                    color: AppColors.primary,
                  ),
                  label: 'TODAY',
                ),
                NavigationDestination(
                  icon: Icon(Icons.event_note_outlined, color: Colors.grey),
                  selectedIcon: Icon(
                    Icons.event_note,
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
