import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/course_model.dart';
import '../../courses/services/course_service.dart';

class ScheduleFormScreen extends StatefulWidget {
  const ScheduleFormScreen({super.key});

  @override
  State<ScheduleFormScreen> createState() => _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends State<ScheduleFormScreen> {
  final CourseService _courseService = CourseService();
  
  CourseModel? _selected_course;
  String? _selected_day;
  TimeOfDay? _start_time;
  TimeOfDay? _end_time;
  bool _is_loading = false;

  final List<String> _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  Future<void> _pick_time(bool is_start) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (is_start) {
          _start_time = picked;
        } else {
          _end_time = picked;
        }
      });
    }
  }

  String _format_time(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _submit_schedule() async {
    if (_selected_course == null || _selected_day == null || _start_time == null || _end_time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    setState(() => _is_loading = true);

    try {
      final Map<String, dynamic> schedule_data = {
        'course_id': _selected_course!.id,
        'day_of_week': _selected_day,
        'start_time': _format_time(_start_time!),
        'end_time': _format_time(_end_time!),
      };

      print("SENDING SCHEDULE: $schedule_data");
      
      await Future.delayed(const Duration(seconds: 1)); 
      
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _is_loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Add Extra Schedule', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _build_label('Select Course'),
            const SizedBox(height: 8),
            FutureBuilder<List<CourseModel>>(
              future: _courseService.get_courses(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const LinearProgressIndicator();
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<CourseModel>(
                      isExpanded: true,
                      hint: const Text('Choose course'),
                      value: _selected_course,
                      items: snapshot.data!.map((course) {
                        return DropdownMenuItem(value: course, child: Text(course.name));
                      }).toList(),
                      onChanged: (val) => setState(() => _selected_course = val),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            _build_label('Day of Week'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Choose day'),
                  value: _selected_day,
                  items: _weekdays.map((day) {
                    return DropdownMenuItem(value: day, child: Text(day));
                  }).toList(),
                  onChanged: (val) => setState(() => _selected_day = val),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _build_label('Start Time'),
                      const SizedBox(height: 8),
                      _build_time_tile(
                        _start_time == null ? '--:--' : _format_time(_start_time!),
                        () => _pick_time(true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _build_label('End Time'),
                      const SizedBox(height: 8),
                      _build_time_tile(
                        _end_time == null ? '--:--' : _format_time(_end_time!),
                        () => _pick_time(false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _is_loading ? null : _submit_schedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _is_loading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('Confirm Schedule', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _build_label(String text) => Text(
    text,
    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant),
  );

  Widget _build_time_tile(String text, VoidCallback on_tap) => InkWell(
    onTap: on_tap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const Icon(Icons.access_time, size: 20, color: AppColors.secondary),
        ],
      ),
    ),
  );
}