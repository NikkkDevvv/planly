import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/note_model.dart';
import '../../courses/bloc/courses_bloc.dart';
import '../../courses/bloc/courses_state.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  int? _selectedCourseId;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan isi catatan tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final note = NoteModel(
      id: 0,
      user_id: 1,
      course_id: _selectedCourseId,
      title: title,
      content: content,
    );

    context.read<NotesBloc>().add(AddNote(note));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan berhasil ditambahkan')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Buat Catatan Baru', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Mata Kuliah'),
            const SizedBox(height: 8),
            BlocBuilder<CoursesBloc, CoursesState>(
              builder: (context, state) {
                List<CourseModel> courses = [];
                if (state is CoursesLoaded) {
                  courses = state.courses;
                }
                return DropdownButtonFormField<int?>(
                  decoration: _inputDecoration('Pilih mata kuliah (opsional)'),
                  value: _selectedCourseId,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Umum / Personal')),
                    ...courses.map((course) {
                      return DropdownMenuItem(value: course.id, child: Text(course.name));
                    }).toList(),
                  ],
                  onChanged: (value) => setState(() => _selectedCourseId = value),
                );
              },
            ),
            const SizedBox(height: 20),
            
            _buildLabel('Judul Catatan'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: _inputDecoration('Masukkan judul catatan'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            _buildLabel(r'Isi Catatan (Dukung Markdown & LaTeX $$)'),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 12,
              minLines: 6,
              keyboardType: TextInputType.multiline,
              decoration: _inputDecoration('Tulis catatan Anda di sini...'),
            ),
            const SizedBox(height: 32),

            CustomButton(
              text: _isLoading ? 'Menyimpan...' : 'Simpan Catatan',
              onPressed: _isLoading ? null : _saveNote,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textLightPrimary),
      );

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.secondary, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.outlineLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
