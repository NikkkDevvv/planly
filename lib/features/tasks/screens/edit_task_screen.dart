import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/course_model.dart';
import '../../courses/services/course_service.dart';
import '../services/task_service.dart';

class EditTaskScreen extends StatefulWidget {
  final TaskModel task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final TaskService _task_service = TaskService();
  final CourseService _course_service = CourseService();

  late TextEditingController _title_controller;
  late TextEditingController _desc_controller;

  // PERBAIKAN: Pisahkan controller tanggal dan waktu agar tidak ter-reset
  late TextEditingController _date_controller;
  late TextEditingController _time_controller;

  int? _selected_course_id;
  late bool _is_pending;
  late bool _is_priority;
  DateTime? _selected_date;
  TimeOfDay? _selected_time;

  bool _is_loading = false;
  bool _is_loading_courses = true; // PERBAIKAN: Mencegah layar merah sekilas
  List<CourseModel> _courses = [];

  @override
  void initState() {
    super.initState();
    _title_controller = TextEditingController(text: widget.task.title);
    _desc_controller = TextEditingController(
      text: widget.task.description ?? '',
    );
    _selected_course_id = widget.task.course_id;
    _is_pending = !widget.task.is_finished;
    _is_priority = widget.task.is_priority;

    try {
      _selected_date = DateTime.parse(widget.task.deadline_date);
      final parts = widget.task.deadline_time.split(':');
      _selected_time = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (e) {
      debugPrint("Error parsing date/time: $e");
    }

    // PERBAIKAN: Inisialisasi text pada controller di awal saja
    _date_controller = TextEditingController(
      text: _selected_date == null
          ? ''
          : "${_selected_date!.day}/${_selected_date!.month}/${_selected_date!.year}",
    );
    _time_controller = TextEditingController(
      text: _selected_time == null ? '' : _format_time(_selected_time!),
    );

    _load_courses();
  }

  Future<void> _load_courses() async {
    try {
      final courses = await _course_service.get_courses();
      if (mounted) {
        setState(() {
          _courses = courses;
          _is_loading_courses = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) setState(() => _is_loading_courses = false);
    }
  }

  @override
  void dispose() {
    _title_controller.dispose();
    _desc_controller.dispose();
    _date_controller.dispose();
    _time_controller.dispose();
    super.dispose();
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
        // PERBAIKAN: Update nilai controller saat tanggal dipilih
        _date_controller.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _pick_time() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selected_time ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selected_time = picked;
        // PERBAIKAN: Update nilai controller saat waktu dipilih
        _time_controller.text = _format_time(picked);
      });
    }
  }

  String _format_date(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String _format_time(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _update_task() async {
    if (_title_controller.text.isEmpty ||
        _selected_date == null ||
        _selected_time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill title, date, and time')),
      );
      return;
    }

    setState(() => _is_loading = true);

    try {
      final String deadline_string =
          "${_format_date(_selected_date!)} ${_format_time(_selected_time!)}:00";

      final Map<String, dynamic> task_data = {
        'user_id': widget.task.user_id,
        'course_id': _selected_course_id,
        'task_title': _title_controller.text,
        'description': _desc_controller.text,
        'deadline': deadline_string,
        'is_finished': _is_pending ? 0 : 1,
        'is_priority': _is_priority ? 1 : 0,
      };

      await _task_service.update_task(widget.task.id, task_data);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
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
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Task',
          style: TextStyle(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
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
          children: [
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
                  _build_label('Task Title'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _title_controller,
                    decoration: _input_decoration(
                      'e.g., Complete final project report',
                    ),
                  ),
                  const SizedBox(height: 20),
                  _build_label('Subject / Course'),
                  const SizedBox(height: 8),

                  // PERBAIKAN: Menangani Render Error jika API lambat merespons
                  _is_loading_courses
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(width: 16),
                              Text(
                                'Loading courses...',
                                style: TextStyle(color: AppColors.secondary),
                              ),
                            ],
                          ),
                        )
                      : DropdownButtonFormField<int?>(
                          decoration: _input_decoration(
                            'Select a subject category',
                          ),
                          isExpanded: true,
                          icon: const Icon(
                            Icons.expand_more,
                            color: AppColors.outline,
                          ),
                          value:
                              (_selected_course_id == null ||
                                  _courses.any(
                                    (c) => c.id == _selected_course_id,
                                  ))
                              ? _selected_course_id
                              : null,
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('General / Personal'),
                            ),
                            ..._courses.map((course) {
                              return DropdownMenuItem(
                                value: course.id,
                                child: Text(course.name),
                              );
                            }).toList(),
                          ],
                          onChanged: (value) =>
                              setState(() => _selected_course_id = value),
                        ),

                  const SizedBox(height: 20),
                  _build_label('Description'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _desc_controller,
                    maxLines: 3,
                    decoration: _input_decoration('Add additional details...'),
                  ),
                  const SizedBox(height: 20),
                  _build_label('Deadline'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          controller:
                              _date_controller, // Gunakan controller yang dipisah
                          decoration: _input_decoration('Date').copyWith(
                            prefixIcon: const Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: AppColors.outline,
                            ),
                          ),
                          onTap: _pick_date,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          controller:
                              _time_controller, // Gunakan controller yang dipisah
                          decoration: _input_decoration('Time').copyWith(
                            prefixIcon: const Icon(
                              Icons.schedule,
                              size: 20,
                              color: AppColors.outline,
                            ),
                          ),
                          onTap: _pick_time,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _build_label('High Priority Task'),
                      Switch(
                        value: _is_priority,
                        activeColor: AppColors.primary,
                        onChanged: (value) =>
                            setState(() => _is_priority = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _build_label('Status'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.outlineVariant.withOpacity(0.6),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _build_segmented_button('Pending', true),
                        ),
                        Expanded(child: _build_segmented_button('Done', false)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _is_loading ? null : () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _is_loading ? null : _update_task,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  icon: _is_loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.check_circle, size: 18),
                  label: const Text(
                    'Save Changes',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
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
      fillColor: AppColors.surfaceBright,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _build_segmented_button(String text, bool is_pending_button) {
    bool is_active = _is_pending == is_pending_button;
    return GestureDetector(
      onTap: () => setState(() => _is_pending = is_pending_button),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: is_active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: is_active
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
          border: is_active
              ? Border.all(color: AppColors.outlineVariant.withOpacity(0.3))
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: is_active ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
