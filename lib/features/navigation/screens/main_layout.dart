import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/home/screens/home_screen.dart';
import '../../../features/schedules/screens/schedule_screen.dart';
import '../../../features/tasks/screens/task_screen.dart';
import '../../../features/notes/screens/note_screen.dart';
import '../../../features/profile/screens/profile_screen.dart';
import '../../courses/screens/course_screen.dart';
import '../../attendance/screens/attendance_screen.dart';
import '../../workspace/screens/workspace_screen.dart';

import '../../events/screens/campus_events_screen.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => MainLayoutState();
}

class MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreens(), // 0: Today
    ScheduleScreens(), // 1: Calendar
    TasksScreens(), // 2: Tasks
    CoursesScreens(), // 3: Courses
    NotesScreens(), // 4: Notes
    WorkspaceScreen(), // 5: Workspace
    AttendanceScreen(), // 6: Attendance
    const SizedBox(), // 7: Placeholder for AI Companion
    ProfileScreens(), // 8: Profile
    CampusEventsScreen(), // 9: Campus Events
  ];

  // List of 3 bottom navigation items mapping to stack indices: Today (0), Calendar (1), Profile (8)
  final List<int> _bottomNavIndices = const [0, 1, 8];

  final List<Map<String, dynamic>> _bottomNavItems = const [
    {
      'icon': Icons.dashboard_outlined,
      'activeIcon': Icons.dashboard,
      'label': 'Hari ini',
    },
    {
      'icon': Icons.calendar_month_outlined,
      'activeIcon': Icons.calendar_month,
      'label': 'Kalender',
    },
    {
      'icon': Icons.person_outline,
      'activeIcon': Icons.person,
      'label': 'Profil',
    },
  ];

  // List of all 10 sidebar items (including Kegiatan Kampus at index 9)
  final List<Map<String, dynamic>> _sidebarItems = const [
    {'index': 0, 'icon': Icons.dashboard_outlined, 'label': 'Hari Ini'},
    {
      'index': 1,
      'icon': Icons.calendar_month_outlined,
      'label': 'Kalender Jadwal',
    },
    {'index': 2, 'icon': Icons.checklist_outlined, 'label': 'Daftar Tugas'},
    {'index': 3, 'icon': Icons.book_outlined, 'label': 'Mata Kuliah'},
    {
      'index': 4,
      'icon': Icons.description_outlined,
      'label': 'Catatan Belajar',
    },
    {'index': 9, 'icon': Icons.event_note_outlined, 'label': 'Kegiatan Kampus'},
    {'index': 5, 'icon': Icons.timer_outlined, 'label': 'Ruang Belajar'},
    {
      'index': 6,
      'icon': Icons.camera_alt_outlined,
      'label': 'Absensi Kehadiran',
    },
    // {
    //   'index': 7,
    //   'icon': Icons.support_agent_outlined,
    //   'label': 'Asisten Virtual',
    // },
    {'index': 8, 'icon': Icons.person_outline, 'label': 'Profil Saya'},
  ];

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void setSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  /// Helper to return correct ImageProvider supporting base64 strings and network URLs
  ImageProvider? _getProfileImageProvider(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('data:image') && url.contains('base64,')) {
      try {
        final base64String = url.split('base64,').last;
        return MemoryImage(base64Decode(base64String));
      } catch (e) {
        return null;
      }
    }
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return NetworkImage(url);
    }
    try {
      return MemoryImage(base64Decode(url));
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine which bottom navigation tab is currently selected, if any
    int bottomSelectedIndex = _bottomNavIndices.indexOf(_selectedIndex);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.bgLight,
      // Left Navigation Drawer (Sidebar)
      drawer: Drawer(
        backgroundColor: AppColors.surfaceLight, // Light theme
        child: Column(
          children: [
            // Drawer Header
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                String userName = 'Mahasiswa';
                String userEmail = 'mahasiswa@planly.com';
                ImageProvider? avatarProvider;
                if (state is Authenticated) {
                  userName = state.user.name;
                  userEmail = state.user.email;
                  avatarProvider = _getProfileImageProvider(
                    state.user.profile_photo_url,
                  );
                }
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 50,
                    bottom: 20,
                    left: 24,
                    right: 24,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.outlineLight,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.calendar_today_rounded,
                            color: AppColors.primary,
                            size: 28,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'PLANLY',
                            style: TextStyle(
                              color: AppColors.textLightPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primary,
                        backgroundImage: avatarProvider,
                        child: avatarProvider == null
                            ? const Icon(
                                Icons.person,
                                size: 32,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textLightPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        userEmail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textLightSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Sidebar Menu Items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                itemCount: _sidebarItems.length,
                itemBuilder: (context, index) {
                  final item = _sidebarItems[index];
                  final itemIndex = item['index'] as int;
                  final isSelected = _selectedIndex == itemIndex;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: Icon(
                        item['icon'],
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.secondary,
                        size: 20,
                      ),
                      title: Text(
                        item['label'],
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textLightPrimary,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      onTap: () {
                        setSelectedIndex(itemIndex);
                        Navigator.pop(context); // Close drawer
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Content Canvas (expanded bottom padding for the floating navigation bar height + margin)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 98),
              child: IndexedStack(index: _selectedIndex, children: _screens),
            ),
          ),

          // Premium Floating Capsule Bottom Navigation Bar
          Positioned(
            left: 24,
            right: 24,
            bottom: 20,
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.outlineLight.withOpacity(0.7),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(_bottomNavItems.length, (index) {
                        final isSelected = bottomSelectedIndex == index;
                        final item = _bottomNavItems[index];

                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setSelectedIndex(_bottomNavIndices[index]);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedScale(
                                  scale: isSelected ? 1.15 : 1.0,
                                  duration: const Duration(milliseconds: 150),
                                  curve: Curves.easeInOut,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary.withOpacity(0.08)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      isSelected
                                          ? item['activeIcon']
                                          : item['icon'],
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.secondary,
                                      size: 22,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item['label'],
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
