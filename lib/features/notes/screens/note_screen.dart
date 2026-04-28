import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/note_model.dart';
import '../services/note_service.dart';
import 'add_note_screen.dart';
import 'note_detail_screen.dart';

class NotesScreens extends StatefulWidget {
  const NotesScreens({super.key});

  @override
  State<NotesScreens> createState() => _NotesScreensState();
}

class _NotesScreensState extends State<NotesScreens> {
  final NoteService _noteService = NoteService();
  late Future<List<NoteModel>> _futureNotes;

  // Variabel untuk menyimpan kata kunci pencarian
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _futureNotes = _noteService.get_notes();
  }

  void _refreshNotes() {
    setState(() {
      _futureNotes = _noteService.get_notes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Padding(
        padding: const EdgeInsets.only(top: 48, left: 24, right: 24),
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
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: const InputDecoration(
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

            // Menampilkan List Catatan
            Expanded(
              child: FutureBuilder<List<NoteModel>>(
                future: _futureNotes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: AppColors.secondary),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No notes available. Create one!',
                        style: TextStyle(color: AppColors.secondary),
                      ),
                    );
                  }

                  final notes = snapshot.data!;

                  // Menyaring daftar catatan berdasarkan pencarian (Case Insensitive)
                  final filteredNotes = notes.where((note) {
                    final titleLower = note.title.toLowerCase();
                    final contentLower = note.content.toLowerCase();
                    final searchLower = _searchQuery.toLowerCase();

                    return titleLower.contains(searchLower) ||
                        contentLower.contains(searchLower);
                  }).toList();

                  // Jika hasil pencarian kosong
                  if (filteredNotes.isEmpty) {
                    return const Center(
                      child: Text(
                        'No notes match your search.',
                        style: TextStyle(color: AppColors.secondary),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      _refreshNotes();
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 96),
                      itemCount: filteredNotes.length,
                      itemBuilder: (context, index) {
                        final note = filteredNotes[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildNoteCard(
                            context,
                            note: note,
                            tag: note.course_id != null
                                ? 'Course ID: ${note.course_id}'
                                : 'General',
                            date: 'Recent',
                            title: note.title,
                            content: note.content,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddNoteScreen()),
            ).then((_) => _refreshNotes());
          },
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }

  Widget _buildNoteCard(
    BuildContext context, {
    required NoteModel note,
    required String tag,
    Color tagBgColor = AppColors.surfaceContainerHigh,
    Color tagTextColor = AppColors.onSurface,
    required String date,
    required String title,
    required String content,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NoteDetailScreen(note: note)),
        ).then((_) => _refreshNotes());
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
          ],
        ),
      ),
    );
  }
}
