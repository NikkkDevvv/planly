import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../courses/screens/course_screen.dart';
import '../../events/screens/campus_events_screen.dart';

class ProfileMenu extends StatelessWidget {
  final VoidCallback onEditProfile;

  const ProfileMenu({
    super.key,
    required this.onEditProfile,
  });

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textLightPrimary,
        ),
      ),
      trailing: trailing ??
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.secondary,
            size: 20,
          ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.outlineLight.withValues(alpha: 0.7)),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.edit_note_rounded,
            title: 'Edit Detail Profil',
            onTap: onEditProfile,
          ),
          const Divider(height: 1, color: AppColors.outlineLight),
          _buildMenuItem(
            icon: Icons.book_outlined,
            title: 'Daftar Mata Kuliah',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CoursesScreens(),
                ),
              );
            },
          ),
          const Divider(height: 1, color: AppColors.outlineLight),
          _buildMenuItem(
            icon: Icons.event_note_rounded,
            title: 'Kegiatan Kampus (Events)',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CampusEventsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
