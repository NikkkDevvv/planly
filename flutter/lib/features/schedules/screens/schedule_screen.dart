import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ScheduleScreens extends StatelessWidget {
  const ScheduleScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: 24,
          bottom: 96,
          left: 24,
          right: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Picker Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Text(
                  'October',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date Picker Strip (Horizontal Scroll)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildDateItem(day: 'Mon', date: '16', isActive: false),
                  const SizedBox(width: 8),
                  _buildDateItem(day: 'Tue', date: '17', isActive: true),
                  const SizedBox(width: 8),
                  _buildDateItem(day: 'Wed', date: '18', isActive: false),
                  const SizedBox(width: 8),
                  _buildDateItem(day: 'Thu', date: '19', isActive: false),
                  const SizedBox(width: 8),
                  _buildDateItem(day: 'Fri', date: '20', isActive: false),
                  const SizedBox(width: 8),
                  _buildDateItem(day: 'Sat', date: '21', isActive: false),
                  const SizedBox(width: 8),
                  _buildDateItem(day: 'Sun', date: '22', isActive: false),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Schedule List
            _buildScheduleCard(
              tag: 'Core Design',
              tagColor: const Color(0xFFE2DFFF), // primary-fixed
              tagTextColor: const Color(0xFF0F0069),
              title: 'Interaction Design Principles',
              lecturer: 'Prof. Sarah Jenkins',
              time: '09:00 - 10:30 AM',
              location: 'Room 402, Building A',
              accentColor: AppColors.primary,
              isPast: false,
            ),
            const SizedBox(height: 16),

            _buildScheduleCard(
              tag: 'Workshop',
              tagColor: const Color(0xFFD3E4FE), // secondary-fixed
              tagTextColor: const Color(0xFF38485D),
              title: 'Prototyping Lab',
              lecturer: 'David Chen, TA',
              time: '11:00 - 13:00 PM',
              location: 'Design Studio 2',
              accentColor: const Color(0xFFD3E4FE),
              isPast: false,
            ),
            const SizedBox(height: 16),

            _buildScheduleCard(
              tag: 'Elective',
              tagColor: const Color(0xFFDFE3E7), // tertiary-fixed
              tagTextColor: const Color(0xFF171C1F),
              title: 'History of Typography',
              lecturer: 'Dr. Elena Rostova',
              time: '14:30 - 16:00 PM',
              location: 'Lecture Hall B',
              accentColor: const Color(0xFFDFE3E7),
              isPast: true, // Akan memberikan efek opacity redup
            ),
          ],
        ),
      ),
    );
  }

  // Widget pembantu untuk Date Item
  Widget _buildDateItem({
    required String day,
    required String date,
    required bool isActive,
  }) {
    return Container(
      width: 56,
      height: 80,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? null
            : Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? Colors.white.withOpacity(0.9)
                  : AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // Widget pembantu untuk Kartu Jadwal
  Widget _buildScheduleCard({
    required String tag,
    required Color tagColor,
    required Color tagTextColor,
    required String title,
    required String lecturer,
    required String time,
    required String location,
    required Color accentColor,
    required bool isPast,
  }) {
    return Opacity(
      opacity: isPast ? 0.6 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: accentColor, width: 4)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: tagColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: tagTextColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lecturer,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 18,
                            color: AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            time,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 18,
                            color: AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
