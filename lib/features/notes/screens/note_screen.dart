import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class NotesScreens extends StatelessWidget {
  const NotesScreens({super.key});

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
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  hintStyle: TextStyle(color: AppColors.outline, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: AppColors.outline),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Note Card 1 (Important)
            _buildNoteCard(
              tag: 'Advanced Physics 301',
              date: 'Oct 24',
              title: 'Quantum Entanglement Basics',
              content:
                  'The fundamental concept relies on two particles interacting such that the quantum state of each particle cannot be described independently of the state of the other(s), even when the particles are separated by a large distance...',
              footer: Row(
                children: [
                  _buildFooterIconText(Icons.attachment, '2 files'),
                  const SizedBox(width: 16),
                  _buildFooterIconText(Icons.label, 'Midterm'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Note Card 2
            _buildNoteCard(
              tag: 'Design History',
              tagBgColor: AppColors.secondaryContainer,
              tagTextColor: const Color(0xFF54647A), // on-secondary-container
              date: 'Oct 22',
              title: 'Bauhaus Movement',
              content:
                  'Form follows function. The integration of art, craft, and technology. Walter Gropius founded it in Weimar in 1919. Minimalist, geometric, and functional design principles.',
            ),
            const SizedBox(height: 16),

            // Note Card 3 (Review Needed)
            _buildNoteCard(
              tag: 'Computer Science',
              date: 'Oct 20',
              title: 'Data Structures: Trees',
              content:
                  'Binary Search Trees (BST), AVL Trees, Red-Black Trees. Important to balance them for O(log n) search time. Need to review the re-balancing logic for AVL insertions.',
              footer: _buildFooterIconText(
                Icons.priority_high,
                'Review needed',
                color: const Color(0xFFBA1A1A),
              ),
            ),
            const SizedBox(height: 16),

            // Note Card 4
            _buildNoteCard(
              tag: 'Literature',
              date: 'Oct 18',
              title: 'Modernist Poetry',
              content:
                  'T.S. Eliot - The Waste Land. Fragmentation, allusion, multiple voices. Departure from traditional forms.',
            ),
            const SizedBox(height: 16),

            // Note Card 5
            _buildNoteCard(
              tag: 'Project Management',
              date: 'Oct 15',
              title: 'Agile Methodologies',
              content:
                  'Scrum framework: Sprints, Daily Standups, Sprint Review, Retrospective. Roles: Scrum Master, Product Owner, Development Team. Emphasis on iterative progress and adaptability.',
            ),
          ],
        ),
      ),
      // Floating Action Button
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton(
          onPressed: () {
            // TODO: Aksi untuk menambah catatan baru
          },
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }

  // Widget pembantu untuk merender Kartu Catatan
  Widget _buildNoteCard({
    required String tag,
    Color tagBgColor = AppColors.surfaceContainerHigh,
    Color tagTextColor = AppColors.onSurface,
    required String date,
    required String title,
    required String content,
    Widget? footer,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: tagBgColor,
                  borderRadius: BorderRadius.circular(16),
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
              Text(
                date,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.secondary,
              height: 1.5,
            ),
          ),
          if (footer != null) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            footer,
          ],
        ],
      ),
    );
  }

  // Widget pembantu untuk merender teks dan ikon di area footer catatan
  Widget _buildFooterIconText(
    IconData icon,
    String text, {
    Color color = AppColors.secondary,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
