import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/schedule_model.dart';
import '../../courses/bloc/courses_bloc.dart';
import '../../courses/bloc/courses_state.dart';
import '../bloc/schedules_bloc.dart';
import '../bloc/schedules_event.dart';
import '../bloc/schedules_state.dart';

class ScheduleFormScreen extends StatefulWidget {
  final CourseModel? presetCourse;
  final DateTime? presetDate;

  const ScheduleFormScreen({
    super.key,
    this.presetCourse,
    this.presetDate,
  });

  @override
  State<ScheduleFormScreen> createState() => _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends State<ScheduleFormScreen> {
  CourseModel? _selectedCourse;
  bool _isCanceled = false;
  DateTime? _originalDate;
  DateTime? _newDate;
  TimeOfDay? _newStartTime;
  TimeOfDay? _newEndTime;
  final TextEditingController _noteController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCourse = widget.presetCourse;
    _originalDate = widget.presetDate;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isOriginal) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        if (isOriginal) {
          _originalDate = picked;
        } else {
          _newDate = picked;
        }
      });
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _newStartTime = picked;
        } else {
          _newEndTime = picked;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _submitForm() async {
    if (_selectedCourse == null || _originalDate == null || _noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan lengkapi semua kolom wajib')),
      );
      return;
    }

    if (!_isCanceled) {
      if (_newDate == null || _newStartTime == null || _newEndTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan lengkapi tanggal dan jam pengganti')),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    final reschedule = ScheduleModel(
      courseId: _selectedCourse!.id,
      originalDate: _formatDate(_originalDate!),
      isCanceled: _isCanceled,
      newDate: _isCanceled ? null : _formatDate(_newDate!),
      newStartTime: _isCanceled ? null : _formatTime(_newStartTime!),
      newEndTime: _isCanceled ? null : _formatTime(_newEndTime!),
      note: _noteController.text.trim(),
    );

    context.read<SchedulesBloc>().add(AddReschedule(reschedule));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Buat Jadwal Pengganti / Batal', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<SchedulesBloc, SchedulesState>(
        listener: (context, state) {
          if (_isLoading) {
            if (state is SchedulesLoaded) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Penjadwalan ulang berhasil disimpan'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
              Navigator.pop(context, true);
            } else if (state is SchedulesError) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal menyimpan: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
                  if (_selectedCourse != null) {
                    final matched = courses.where((c) => c.id == _selectedCourse!.id).toList();
                    if (matched.isNotEmpty) {
                      _selectedCourse = matched.first;
                    }
                  }
                }
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineLight),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<CourseModel>(
                      isExpanded: true,
                      hint: const Text('Pilih Mata Kuliah'),
                      value: _selectedCourse,
                      items: courses.map((course) {
                        return DropdownMenuItem(value: course, child: Text(course.name));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedCourse = val),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            
            _buildLabel('Tipe Penyesuaian'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Pindah Jadwal')),
                    selected: !_isCanceled,
                    onSelected: (val) => setState(() => _isCanceled = !val),
                    selectedColor: AppColors.primaryContainer,
                    labelStyle: TextStyle(
                      color: !_isCanceled ? AppColors.primary : AppColors.textLightSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Batal Kuliah')),
                    selected: _isCanceled,
                    onSelected: (val) => setState(() => _isCanceled = val),
                    selectedColor: AppColors.errorContainer,
                    labelStyle: TextStyle(
                      color: _isCanceled ? AppColors.error : AppColors.textLightSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildLabel('Tanggal Kuliah Asli'),
            const SizedBox(height: 8),
            _buildTile(
              _originalDate == null ? 'Pilih Tanggal' : DateFormat('dd MMMM yyyy').format(_originalDate!),
              Icons.calendar_month,
              () => _pickDate(true),
            ),
            
            if (!_isCanceled) ...[
              const SizedBox(height: 24),
              _buildLabel('Tanggal Jadwal Pengganti'),
              const SizedBox(height: 8),
              _buildTile(
                _newDate == null ? 'Pilih Tanggal Baru' : DateFormat('dd MMMM yyyy').format(_newDate!),
                Icons.calendar_today,
                () => _pickDate(false),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Jam Mulai Baru'),
                        const SizedBox(height: 8),
                        _buildTile(
                          _newStartTime == null ? '--:--' : _formatTime(_newStartTime!),
                          Icons.access_time,
                          () => _pickTime(true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Jam Selesai Baru'),
                        const SizedBox(height: 8),
                        _buildTile(
                          _newEndTime == null ? '--:--' : _formatTime(_newEndTime!),
                          Icons.access_time,
                          () => _pickTime(false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 24),
            _buildLabel('Alasan / Catatan'),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Masukkan keterangan (misal: Dosen dinas luar kota)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.outlineLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.outlineLight),
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            CustomButton(
              text: _isLoading ? 'Menyimpan...' : 'Konfirmasi Perubahan',
              onPressed: _isLoading ? null : _submitForm,
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildLabel(String text) => Text(
    text,
    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textLightPrimary),
  );

  Widget _buildTile(String text, IconData icon, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          Icon(icon, size: 20, color: AppColors.secondary),
        ],
      ),
    ),
  );
}