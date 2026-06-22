import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/course_model.dart';
import '../bloc/courses_bloc.dart';
import '../bloc/courses_event.dart';

class EditCourseScreen extends StatefulWidget {
  final CourseModel course;

  const EditCourseScreen({super.key, required this.course});

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  
  late TextEditingController _code_controller;
  late TextEditingController _name_controller;
  late TextEditingController _credits_controller;
  late TextEditingController _room_controller;
  late TextEditingController _lecturer_controller;

  DateTime? _selected_date;
  TimeOfDay? _start_time;
  TimeOfDay? _end_time;
  bool _is_loading = false;

  final List<String> _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    _code_controller = TextEditingController(text: widget.course.course_code);
    _name_controller = TextEditingController(text: widget.course.name);
    _credits_controller = TextEditingController(text: widget.course.credits.toString());
    _room_controller = TextEditingController(text: widget.course.room);
    _lecturer_controller = TextEditingController(text: widget.course.lecturer);

    _start_time = _parse_time_string(widget.course.start_time);
    _end_time = _parse_time_string(widget.course.end_time);
    _selected_date = _get_next_date_from_day(widget.course.day_of_week);
  }

  @override
  void dispose() {
    _code_controller.dispose();
    _name_controller.dispose();
    _credits_controller.dispose();
    _room_controller.dispose();
    _lecturer_controller.dispose();
    super.dispose();
  }

  TimeOfDay _parse_time_string(String time_string) {
    final parts = time_string.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  DateTime _get_next_date_from_day(String day_name) {
    final days = {
      'monday': 1, 'tuesday': 2, 'wednesday': 3, 'thursday': 4,
      'friday': 5, 'saturday': 6, 'sunday': 7
    };
    int target = days[day_name.toLowerCase()] ?? 1;
    DateTime now = DateTime.now();
    int current = now.weekday;
    int diff = target - current;
    
    if (diff < 0) {
      diff += 7;
    }
    return now.add(Duration(days: diff));
  }

  String _format_time(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pick_date() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selected_date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selected_date = picked;
      });
    }
  }

  Future<void> _pick_time(bool is_start) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: is_start ? (_start_time ?? TimeOfDay.now()) : (_end_time ?? TimeOfDay.now()),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
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

  void _update_course() {
    if (_code_controller.text.isEmpty ||
        _name_controller.text.isEmpty ||
        _credits_controller.text.isEmpty ||
        _room_controller.text.isEmpty ||
        _lecturer_controller.text.isEmpty ||
        _selected_date == null ||
        _start_time == null ||
        _end_time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final String day_of_week = _weekdays[_selected_date!.weekday - 1];

    final updatedCourse = CourseModel(
      id: widget.course.id,
      user_id: widget.course.user_id,
      course_code: _code_controller.text.trim(),
      name: _name_controller.text.trim(),
      credits: int.parse(_credits_controller.text.trim()),
      lecturer: _lecturer_controller.text.trim(),
      room: _room_controller.text.trim(),
      day_of_week: day_of_week,
      start_time: _format_time(_start_time!),
      end_time: _format_time(_end_time!),
      color_hex: widget.course.color_hex,
    );

    context.read<CoursesBloc>().add(UpdateCourse(updatedCourse));

    if (mounted) {
      Navigator.pop(context, true);
    }
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
          'Edit Course',
          style: TextStyle(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
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
            const Text(
              'Update details for your class schedule.',
              style: TextStyle(fontSize: 16, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.outlineVariant.withOpacity(0.5),
                ),
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
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _build_label('Code'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _code_controller,
                              decoration: _input_decoration('#01'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _build_label('Course Name'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _name_controller,
                              decoration: _input_decoration('e.g. Data Mining'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _build_label('Credits / SKS'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _credits_controller,
                              keyboardType: TextInputType.number,
                              decoration: _input_decoration('3'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _build_label('Room / Location'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _room_controller,
                              decoration: _input_decoration('e.g. Lab AI'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _build_label('Lecturer Name'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _lecturer_controller,
                    decoration: _input_decoration('e.g. Dr. Jane Smith'),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  const Text(
                    'Date & Time',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.outlineVariant.withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _build_label('Date'),
                        const SizedBox(height: 8),
                        TextField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: _selected_date == null
                                ? ''
                                : "${_selected_date!.day}/${_selected_date!.month}/${_selected_date!.year}",
                          ),
                          decoration: _input_decoration('Select Date').copyWith(
                            suffixIcon: const Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: AppColors.outline,
                            ),
                          ),
                          onTap: _pick_date,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _build_label('Start Time'),
                                  const SizedBox(height: 8),
                                  TextField(
                                    readOnly: true,
                                    controller: TextEditingController(
                                      text: _start_time != null ? _format_time(_start_time!) : '',
                                    ),
                                    decoration: _input_decoration('Time').copyWith(
                                      suffixIcon: const Icon(
                                        Icons.schedule,
                                        size: 18,
                                        color: AppColors.outline,
                                      ),
                                    ),
                                    onTap: () => _pick_time(true),
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
                                  TextField(
                                    readOnly: true,
                                    controller: TextEditingController(
                                      text: _end_time != null ? _format_time(_end_time!) : '',
                                    ),
                                    decoration: _input_decoration('Time').copyWith(
                                      suffixIcon: const Icon(
                                        Icons.schedule,
                                        size: 18,
                                        color: AppColors.outline,
                                      ),
                                    ),
                                    onTap: () => _pick_time(false),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _is_loading ? null : () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _is_loading ? null : _update_course,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _is_loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _build_label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurfaceVariant,
        ),
      );

  InputDecoration _input_decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColors.outline.withOpacity(0.7),
        fontSize: 14,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.outlineVariant), // Pakai borderSide
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5), // Pakai borderSide
      ),
    );
  }
}