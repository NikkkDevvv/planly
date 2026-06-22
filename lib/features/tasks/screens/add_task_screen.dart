import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/task_model.dart';
import '../../courses/bloc/courses_bloc.dart';
import '../../courses/bloc/courses_state.dart';
import '../bloc/tasks_bloc.dart';
import '../bloc/tasks_event.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  int? _selectedCourseId;
  String _selectedPriority = 'medium';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  
  List<Map<String, dynamic>> _attachments = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _pickAttachment() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final int sizeInBytes = await file.length();
        
        // 1.5MB validation check
        if (sizeInBytes > 1.5 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('File terlampau besar. Maksimum ukuran file 1.5MB.')),
            );
          }
          return;
        }

        final bytes = await file.readAsBytes();
        final String base64Data = base64Encode(bytes);
        final String fileName = result.files.single.name;
        final String extension = result.files.single.extension ?? 'bin';

        setState(() {
          _attachments.add({
            'name': fileName,
            'type': extension,
            'size': sizeInBytes,
            'data_url': 'data:application/octet-stream;base64,$base64Data',
          });
        });
      }
    } catch (e) {
      debugPrint("File picking error: $e");
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String _formatTime(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00";
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan isi judul, tanggal, dan jam tenggat waktu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final task = TaskModel(
      id: 0,
      user_id: 1,
      course_id: _selectedCourseId,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      deadline_date: _formatDate(_selectedDate!),
      deadline_time: _formatTime(_selectedTime!),
      is_finished: false,
      priority: _selectedPriority,
      attachments: _attachments,
    );

    context.read<TasksBloc>().add(AddTask(task));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tugas berhasil ditambahkan')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Buat Tugas Baru', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Judul Tugas'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    decoration: _inputDecoration('Contoh: Tugas Implementasi Graf DFS'),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildLabel('Mata Kuliah'),
                  const SizedBox(height: 8),
                  BlocBuilder<CoursesBloc, CoursesState>(
                    builder: (context, state) {
                      List<CourseModel> courses = [];
                      if (state is CoursesLoaded) {
                        courses = state.courses;
                      }
                      return DropdownButtonFormField<int?>(
                        decoration: _inputDecoration('Pilih kategori mata kuliah'),
                        isExpanded: true,
                        value: _selectedCourseId,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Umum / Personal'),
                          ),
                          ...courses.map((course) {
                            return DropdownMenuItem(
                              value: course.id,
                              child: Text(course.name),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) => setState(() => _selectedCourseId = value),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  _buildLabel('Deskripsi'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: _inputDecoration('Tulis detail pengerjaan...'),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildLabel('Prioritas'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration('Pilih tingkat prioritas'),
                    value: _selectedPriority,
                    items: const [
                      DropdownMenuItem(value: 'low', child: Text('Rendah')),
                      DropdownMenuItem(value: 'medium', child: Text('Sedang')),
                      DropdownMenuItem(value: 'high', child: Text('Tinggi')),
                    ],
                    onChanged: (value) => setState(() => _selectedPriority = value ?? 'medium'),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildLabel('Tenggat Waktu'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: _selectedDate == null
                                ? ''
                                : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                          ),
                          decoration: _inputDecoration('Tanggal').copyWith(
                            prefixIcon: const Icon(Icons.calendar_today, size: 18, color: AppColors.secondary),
                          ),
                          onTap: _pickDate,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: _selectedTime == null ? '' : _selectedTime!.format(context),
                          ),
                          decoration: _inputDecoration('Jam').copyWith(
                            prefixIcon: const Icon(Icons.schedule, size: 18, color: AppColors.secondary),
                          ),
                          onTap: _pickTime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  _buildLabel('Lampiran Berkas (Maksimal 1.5MB)'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _pickAttachment,
                        icon: const Icon(Icons.attach_file, size: 16),
                        label: const Text('Pilih Berkas'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                  if (_attachments.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _attachments.length,
                      itemBuilder: (context, idx) {
                        final att = _attachments[idx];
                        final kbSize = (att['size'] / 1024).toStringAsFixed(1);
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.insert_drive_file, color: AppColors.primary),
                          title: Text(att['name'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          subtitle: Text('$kbSize KB', style: const TextStyle(fontSize: 11)),
                          trailing: IconButton(
                            icon: const Icon(Icons.cancel, color: AppColors.error, size: 18),
                            onPressed: () {
                              setState(() {
                                _attachments.removeAt(idx);
                              });
                            },
                          ),
                        );
                      },
                    )
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: _isLoading ? 'Menyimpan...' : 'Simpan Tugas',
              onPressed: _isLoading ? null : _saveTask,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textLightPrimary,
        ),
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