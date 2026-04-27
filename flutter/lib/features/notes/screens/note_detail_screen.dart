import 'package:flutter/material.dart';
import 'edit_note_screen.dart';
import '../../../core/theme/app_colors.dart';

class NoteDetailScreen extends StatelessWidget {
  const NoteDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.secondary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditNoteScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Color(0xFFBA1A1A)),
            onPressed: () {
              // TODO: Aksi hapus catatan
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
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
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Advanced Physics 301',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                const Text(
                  'Oct 24, 2026',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Quantum Entanglement Basics',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'The fundamental concept relies on two particles interacting such that the quantum state of each particle cannot be described independently of the state of the other(s), even when the particles are separated by a large distance.\n\nKey formulas derived today involve the tensor product of Hilbert spaces. This property is what Einstein famously called "spooky action at a distance."\n\nMake sure to review the mathematical proofs before the midterm next week, specifically focusing on Bell\'s Theorem.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.onSurfaceVariant,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
