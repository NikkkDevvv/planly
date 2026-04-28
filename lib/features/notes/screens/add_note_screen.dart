import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/course_model.dart'; // Import model course
import '../../courses/services/course_service.dart'; // Import service course
import '../services/note_service.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final NoteService _noteService = NoteService();
  final CourseService _courseService =
      CourseService(); // Inisialisasi CourseService

  bool _isLoading = false;
  int? _selectedCourseId; // Variabel untuk menyimpan course yang dipilih
  List<CourseModel> _courses = []; // List untuk menyimpan data mata kuliah

  @override
  void initState() {
    super.initState();
    _loadCourses(); // Ambil data mata kuliah saat halaman dibuka
  }

  Future<void> _loadCourses() async {
    try {
      final courses = await _courseService.get_courses();
      setState(() {
        _courses = courses;
      });
    } catch (e) {
      debugPrint('Error loading courses: $e');
    }
  }

  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and content cannot be empty!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> noteData = {
      'course_id': _selectedCourseId, // Gunakan ID mata kuliah yang dipilih
      'title': _titleController.text.trim(),
      'content': _contentController.text.trim(),
    };

    try {
      await _noteService.create_note(noteData);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        // ... kode AppBar tetap sama ...
        actions: [
          _isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: CircularProgressIndicator(),
                  ),
                )
              : TextButton(onPressed: _saveNote, child: const Text('Save')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Dropdown untuk memilih Mata Kuliah
            DropdownButtonFormField<int>(
              value: _selectedCourseId,
              hint: const Text('Select Course (Optional)'),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _courses.map((course) {
                return DropdownMenuItem<int>(
                  value: course.id,
                  child: Text(course.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCourseId = value;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Note Title'),
            ),
            const Divider(),
            TextField(
              controller: _contentController,
              maxLines: 1000,
              minLines: 15,
              keyboardType: TextInputType.multiline,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.onSurface,
                height: 1.6,
              ),
              decoration: InputDecoration(
                hintText: 'Start typing your notes here...',
                hintStyle: TextStyle(
                  color: AppColors.outline.withOpacity(0.7),
                  fontSize: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.outlineVariant.withOpacity(0.5),
                  ),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
