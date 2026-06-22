import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/note_model.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../bloc/notes_state.dart';
import '../../navigation/screens/main_layout.dart';
import 'add_note_screen.dart';
import 'note_detail_screen.dart';


class NotesScreens extends StatefulWidget {
  const NotesScreens({super.key});

  @override
  State<NotesScreens> createState() => _NotesScreensState();
}

class _NotesScreensState extends State<NotesScreens> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<NotesBloc>().add(FetchNotes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.primary),
            onPressed: () => context.findAncestorStateOfType<MainLayoutState>()?.openDrawer(),
          ),
        ),
        title: const Text('Catatan Belajar', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
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
                  hintText: 'Cari catatan...',
                  hintStyle: TextStyle(color: AppColors.secondary, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: AppColors.secondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Notes Staggered Grid Content
          Expanded(
            child: BlocBuilder<NotesBloc, NotesState>(
              builder: (context, state) {
                if (state is NotesLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                } else if (state is NotesError) {
                  return Center(
                    child: Text('Gagal memuat catatan: ${state.message}', style: const TextStyle(color: AppColors.error)),
                  );
                } else if (state is NotesLoaded) {
                  final notes = state.notes;

                  final filteredNotes = notes.where((note) {
                    final titleLower = note.title.toLowerCase();
                    final contentLower = note.content.toLowerCase();
                    final searchLower = _searchQuery.toLowerCase();
                    return titleLower.contains(searchLower) || contentLower.contains(searchLower);
                  }).toList();

                  if (filteredNotes.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada catatan ditemukan', style: TextStyle(color: AppColors.secondary)),
                    );
                  }

                  // Split notes into two columns for Staggered Grid (Masonry)
                  final col1Notes = <NoteModel>[];
                  final col2Notes = <NoteModel>[];
                  for (int i = 0; i < filteredNotes.length; i++) {
                    if (i % 2 == 0) {
                      col1Notes.add(filteredNotes[i]);
                    } else {
                      col2Notes.add(filteredNotes[i]);
                    }
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<NotesBloc>().add(FetchNotes());
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 96),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Column 1
                          Expanded(
                            child: Column(
                              children: col1Notes.map((note) => _buildNoteCard(note)).toList(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Column 2
                          Expanded(
                            child: Column(
                              children: col2Notes.map((note) => _buildNoteCard(note)).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNoteScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildNoteCard(NoteModel note) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NoteDetailScreen(note: note)),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        note.courseName ?? 'Umum',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                note.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLightPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                note.content,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textLightSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
