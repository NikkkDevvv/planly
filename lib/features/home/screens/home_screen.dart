import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HomeScreens extends StatelessWidget {
  const HomeScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          const Text(
            "Today's Schedule",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Thursday, October 26',
            style: TextStyle(fontSize: 16, color: AppColors.secondary),
          ),
          const SizedBox(height: 32),

          // Timeline Container
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildTimelineItem(
                time: "09:00 AM - 10:30 AM",
                title: "Advanced Algorithms",
                room: "Room 402, Science Building",
                lecturer: "Dr. Alan Turing",
                status: "In Progress",
                isFirst: true,
                isActive: true,
              ),
              _buildTimelineItem(
                time: "11:00 AM - 12:30 PM",
                title: "Database Systems",
                room: "Lab 2, Tech Hub",
                lecturer: "Prof. Grace Hopper",
                isLast: false,
              ),
              _buildBreakItem(
                time: "12:30 PM - 02:00 PM",
                title: "Lunch Break",
              ),
              _buildTimelineItem(
                time: "02:00 PM - 04:00 PM",
                title: "UI/UX Design Studio",
                room: "Design Lab A",
                lecturer: "Don Norman",
                isLast: true,
              ),
            ],
          ),

          // Quick Tasks Section (Bento Style)
          const SizedBox(height: 48),
          const Text(
            "Quick Tasks",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildBentoCard(
                  color: const Color(0xFFE2DFFF), // primary-fixed
                  icon: Icons.assignment_turned_in,
                  iconColor: AppColors.primary,
                  value: "3",
                  label: "Pending",
                  isNumber: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildBentoCard(
                  color: AppColors.surfaceContainerHigh,
                  icon: Icons.menu_book,
                  iconColor: AppColors.secondary,
                  value: "Read Chapter 4 before Algorithms",
                  label: "",
                  isNumber: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String time,
    required String title,
    required String room,
    required String lecturer,
    String? status,
    bool isFirst = false,
    bool isLast = false,
    bool isActive = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        children: [
          // Timeline Line & Dot
          SizedBox(
            width: 30,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (!isLast)
                  const VerticalDivider(
                    thickness: 1,
                    color: AppColors.outlineVariant,
                  ),
                Positioned(
                  top: 20,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.outlineVariant,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.outlineVariant,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (status != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  status,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildIconText(Icons.location_on_outlined, room),
                        const SizedBox(height: 4),
                        _buildIconText(Icons.person_outline, lecturer),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakItem({required String time, required String title}) {
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const VerticalDivider(
                  thickness: 1,
                  color: AppColors.outlineVariant,
                ),
                Positioned(
                  top: 20,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD0E1FB),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F3FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.restaurant,
                          size: 18,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.secondary),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 13, color: AppColors.secondary),
        ),
      ],
    );
  }

  Widget _buildBentoCard({
    required Color color,
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required bool isNumber,
  }) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: iconColor),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isNumber ? 28 : 14,
                    fontWeight: isNumber ? FontWeight.bold : FontWeight.w500,
                    color: AppColors.onSurface,
                  ),
                ),
                if (label.isNotEmpty)
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
