import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/note_model.dart';
import '../../../data/models/course_model.dart';
import '../../courses/services/course_service.dart';
import '../services/note_service.dart';

class EditNoteScreen extends StatefulWidget {
  final NoteModel note;

  const EditNoteScreen({super.key, required this.note});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  final NoteService _noteService = NoteService();
  final CourseService _courseService = CourseService();

  bool _isLoading = false;
  int? _selectedCourseId;
  List<CourseModel> _courses = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);

    // Set nilai awal dropdown sesuai dengan data catatan saat ini
    _selectedCourseId = widget.note.course_id;

    _loadCourses();
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

  Future<void> _updateNote() async {
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
      'course_id': _selectedCourseId, // Menggunakan nilai dari dropdown
      'title': _titleController.text.trim(),
      'content': _contentController.text.trim(),
    };

    try {
      await _noteService.update_note(widget.note.id, noteData);
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Note',
          style: TextStyle(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _updateNote,
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.outlineVariant.withOpacity(0.3),
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Note Title',
                hintStyle: TextStyle(
                  color: AppColors.outline.withOpacity(0.7),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(),
            ),
            TextField(
              controller: _contentController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
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
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
