import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../courses/bloc/courses_bloc.dart';
import '../../courses/bloc/courses_event.dart';
import '../../courses/bloc/courses_state.dart';
import '../../notes/bloc/notes_bloc.dart';
import '../../notes/bloc/notes_event.dart';
import '../../../data/models/note_model.dart';
import '../../tasks/bloc/tasks_bloc.dart';
import '../../tasks/bloc/tasks_event.dart';
import '../../tasks/bloc/tasks_state.dart';
import '../../../data/models/task_model.dart';
import '../../home/bloc/pomodoro_bloc.dart';
import '../../navigation/screens/main_layout.dart';
import '../../../data/models/course_model.dart';
import '../widgets/workspace_timer_ring.dart';
import '../widgets/workspace_ambient_sound.dart';

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  // Mode selection: 'pomodoro' or 'lecture'
  String _workspaceMode = 'pomodoro';

  // Ambient sound selector
  String _selectedSound = 'none';
  bool _isAudioMuted = false;

  // Pomodoro mode local states
  int? _pomodoroTaskId;
  int _completedPomodoroCount = 0;

  // Lecture mode stopwatch states
  Timer? _lectureTimer;
  int _lectureTimeInSeconds = 0;
  bool _isLectureRunning = false;
  int? _activeLectureCourseId;
  final TextEditingController _noteContentController = TextEditingController();
  final List<Map<String, dynamic>> _localTasks = [];

  // Temporary task adder inputs
  final TextEditingController _newTaskTitleController = TextEditingController();
  DateTime? _newTaskDeadline;

  @override
  void initState() {
    super.initState();
    context.read<CoursesBloc>().add(FetchCourses());
    context.read<TasksBloc>().add(FetchTasks());
  }

  @override
  void dispose() {
    _lectureTimer?.cancel();
    _noteContentController.dispose();
    _newTaskTitleController.dispose();
    super.dispose();
  }

  void _startPauseLecture() {
    if (_activeLectureCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih mata kuliah terlebih dahulu!')),
      );
      return;
    }

    if (_isLectureRunning) {
      _lectureTimer?.cancel();
      setState(() {
        _isLectureRunning = false;
      });
    } else {
      setState(() {
        _isLectureRunning = true;
      });
      _lectureTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _lectureTimeInSeconds++;
        });
      });
    }
  }

  void _resetLecture() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Kuliah Live'),
        content: const Text('Batalkan dan atur ulang sesi kuliah live ini? Catatan dan tugas baru Anda tidak akan disimpan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              _lectureTimer?.cancel();
              setState(() {
                _lectureTimeInSeconds = 0;
                _isLectureRunning = false;
                _activeLectureCourseId = null;
                _noteContentController.clear();
                _localTasks.clear();
              });
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _addLocalTask() {
    final title = _newTaskTitleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul tugas tidak boleh kosong!')),
      );
      return;
    }

    if (_newTaskDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih batas waktu!')),
      );
      return;
    }

    setState(() {
      _localTasks.add({
        'title': title,
        'deadline': DateFormat('yyyy-MM-dd').format(_newTaskDeadline!),
      });
      _newTaskTitleController.clear();
      _newTaskDeadline = null;
    });
  }

  void _removeLocalTask(int index) {
    setState(() {
      _localTasks.removeAt(index);
    });
  }

  void _finishLecture(List<CourseModel> courses) {
    if (_activeLectureCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih mata kuliah terlebih dahulu.')),
      );
      return;
    }

    final selectedCourse = courses.firstWhere((c) => c.id == _activeLectureCourseId);
    final todayStr = DateFormat('d MMMM yyyy', 'id_ID').format(DateTime.now());
    final durationMin = _lectureTimeInSeconds ~/ 60;

    // Compose markdown content
    String fullContent = '## Catatan Kuliah: ${selectedCourse.name}\n'
        '* **Tanggal**: $todayStr\n'
        '* **Durasi Kuliah**: $durationMin menit\n\n'
        '### Rangkuman Materi Perkuliahan:\n'
        '${_noteContentController.text.trim().isEmpty ? "*(Tidak ada catatan materi ditulis)*" : _noteContentController.text.trim()}\n';

    if (_localTasks.isNotEmpty) {
      fullContent += '\n### Tugas & PR Baru dari Kuliah Ini:\n' +
          _localTasks.asMap().entries.map((e) => '${e.key + 1}. **${e.value['title']}** (Batas Waktu: ${e.value['deadline']})').join('\n');
    }

    // 1. Save Note via NotesBloc
    context.read<NotesBloc>().add(AddNote(NoteModel(
          id: 0,
          user_id: 1,
          title: 'Catatan Kuliah: ${selectedCourse.name} ($todayStr)',
          content: fullContent,
        )));

    // 2. Save Tasks via TasksBloc
    for (final task in _localTasks) {
      context.read<TasksBloc>().add(AddTask(TaskModel(
            id: 0,
            user_id: 1,
            course_id: selectedCourse.id,
            course_code: selectedCourse.course_code,
            course_name: selectedCourse.name,
            title: task['title'],
            description: 'Ditambahkan otomatis dari Sesi Kuliah Live: ${selectedCourse.name}',
            deadline_date: task['deadline'],
            deadline_time: '23:59:00',
            is_finished: false,
            priority: 'medium',
          )));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan kuliah dan daftar tugas baru berhasil disimpan!')),
    );

    // Stop and Reset state
    _lectureTimer?.cancel();
    setState(() {
      _lectureTimeInSeconds = 0;
      _isLectureRunning = false;
      _activeLectureCourseId = null;
      _noteContentController.clear();
      _localTasks.clear();
    });

    // Auto-navigate to Notes tab (index 4 in IndexedStack)
    context.findAncestorStateOfType<MainLayoutState>()?.setSelectedIndex(4);
  }

  String _formatLectureDuration(int totalSeconds) {
    final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.primary),
            onPressed: () => context.findAncestorStateOfType<MainLayoutState>()?.openDrawer(),
          ),
        ),
        title: const Text(
          'Ruang Belajar',
          style: TextStyle(
            color: AppColors.textLightPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: BlocBuilder<CoursesBloc, CoursesState>(
        builder: (context, coursesState) {
          return BlocBuilder<TasksBloc, TasksState>(
            builder: (context, tasksState) {
              List<CourseModel> courses = [];
              if (coursesState is CoursesLoaded) {
                courses = coursesState.courses;
              }

              List<TaskModel> tasks = [];
              if (tasksState is TasksLoaded) {
                tasks = tasksState.tasks.where((t) => !t.is_finished).toList();
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Description & Mode Switcher
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Dasbor Produktivitas',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textLightPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Fokus Pomodoro & mencatat perkuliahan.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textLightSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Mode Switcher
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.outlineLight),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (_isLectureRunning) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Silakan jeda atau selesaikan timer kuliah aktif Anda sebelum berpindah mode.')),
                                    );
                                    return;
                                  }
                                  setState(() {
                                    _workspaceMode = 'pomodoro';
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _workspaceMode == 'pomodoro' ? AppColors.primary : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Pomodoro',
                                    style: TextStyle(
                                      color: _workspaceMode == 'pomodoro' ? Colors.white : AppColors.textLightSecondary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _workspaceMode = 'lecture';
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _workspaceMode == 'lecture' ? AppColors.primary : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Kuliah Live',
                                    style: TextStyle(
                                      color: _workspaceMode == 'lecture' ? Colors.white : AppColors.textLightSecondary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Main Timer Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.outlineLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.01),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Status & Ambient sound selector row
                          SizedBox(
                            width: double.infinity,
                            child: Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                // Session Tag
                                _workspaceMode == 'pomodoro'
                                    ? BlocBuilder<PomodoroBloc, PomodoroState>(
                                        builder: (context, state) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: state.isBreak ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              state.isBreak ? '☕ ISTIRAHAT' : '🔥 SESI FOKUS',
                                              style: TextStyle(
                                                color: state.isBreak ? Colors.green : Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryContainer,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Text(
                                          '🎓 KULIAH LIVE',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),

                                // Ambient Sounds Button
                                WorkspaceAmbientSound(
                                  selectedSound: _selectedSound,
                                  isAudioMuted: _isAudioMuted,
                                  onSoundChanged: (newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedSound = newValue;
                                      });
                                    }
                                  },
                                  onMuteToggled: () {
                                    setState(() {
                                      _isAudioMuted = !_isAudioMuted;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Circular Progress Clock
                          _workspaceMode == 'pomodoro'
                              ? BlocBuilder<PomodoroBloc, PomodoroState>(
                                  builder: (context, state) {
                                    final double maxSeconds = state.isBreak ? 300.0 : 1500.0;
                                    final double progress = state.remainingSeconds / maxSeconds;

                                    return WorkspaceTimerRing(
                                      displayText: state.formattedTime,
                                      progress: progress,
                                      isRunning: state.isRunning,
                                      onPlayPause: () {
                                        if (state.isRunning) {
                                          context.read<PomodoroBloc>().add(PauseTimer());
                                        } else {
                                          context.read<PomodoroBloc>().add(StartTimer());
                                        }
                                      },
                                      onReset: () {
                                        context.read<PomodoroBloc>().add(ResetTimer());
                                      },
                                    );
                                  },
                                )
                              : WorkspaceTimerRing(
                                  displayText: _formatLectureDuration(_lectureTimeInSeconds),
                                  progress: _isLectureRunning ? null : 1.0,
                                  isRunning: _isLectureRunning,
                                  onPlayPause: _startPauseLecture,
                                  onReset: _resetLecture,
                                ),
                          const SizedBox(height: 20),

                          // Bottom inputs of Timer Card (Task select for Pomodoro, Course select for Lecture)
                          _workspaceMode == 'pomodoro'
                              ? _buildPomodoroTaskAndSiklusSection(tasks)
                              : _buildLectureCourseSelector(courses),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Lecture Notes and Tasks Panel
                    if (_workspaceMode == 'lecture') ...[
                      // Lecture Notes Editor
                      const Text(
                        'Catatan Perkuliahan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textLightPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.outlineLight),
                        ),
                        child: TextField(
                          controller: _noteContentController,
                          maxLines: 8,
                          style: const TextStyle(fontSize: 13, height: 1.4),
                          decoration: const InputDecoration(
                            hintText: 'Tulis ringkasan penjelasan dosen atau catatan materi kuliah di sini (format markdown didukung)...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Temporary tasks list
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Tugas Baru dari Kuliah Ini',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textLightPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.outlineLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Task Creator inputs
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: _newTaskTitleController,
                                  style: const TextStyle(fontSize: 13),
                                  decoration: const InputDecoration(
                                    hintText: 'Nama tugas / PR...',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () async {
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now().add(const Duration(days: 1)),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.now().add(const Duration(days: 365)),
                                        );
                                        if (picked != null) {
                                          setState(() {
                                            _newTaskDeadline = picked;
                                          });
                                        }
                                      },
                                      icon: const Icon(Icons.calendar_today, size: 14),
                                      label: Text(
                                        _newTaskDeadline == null
                                            ? 'Pilih Deadline'
                                            : DateFormat('dd/MM/yyyy').format(_newTaskDeadline!),
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: _addLocalTask,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Tambah', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // List of added local tasks
                            if (_localTasks.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Text(
                                  'Belum ada tugas dicatat.',
                                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textLightSecondary),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _localTasks.length,
                                itemBuilder: (context, index) {
                                  final t = _localTasks[index];
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                    title: Text(t['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    subtitle: Text('Batas waktu: ${t['deadline']}', style: const TextStyle(fontSize: 11)),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: AppColors.error, size: 18),
                                      onPressed: () => _removeLocalTask(index),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Finish session button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                           onPressed: () => _finishLecture(courses),
                          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                          label: const Text(
                            'Selesaikan Perkuliahan & Simpan Catatan',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPomodoroTaskAndSiklusSection(List<TaskModel> tasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        const Text(
          'TUGAS AKTIF SAAT INI',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.bgLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<int>(
            value: _pomodoroTaskId,
            hint: const Text('Pilih tugas untuk difokuskan...', style: TextStyle(fontSize: 12)),
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            onChanged: (int? newValue) {
              setState(() {
                _pomodoroTaskId = newValue;
              });
            },
            items: [
              const DropdownMenuItem<int>(
                value: null,
                child: Text('Bebas / Belajar Mandiri (Tanpa Tugas)', style: TextStyle(fontSize: 12)),
              ),
              ...tasks.map((task) {
                return DropdownMenuItem<int>(
                  value: task.id,
                  child: Text(task.title, style: const TextStyle(fontSize: 12)),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Siklus Selesai:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textLightSecondary),
            ),
            Row(
              children: [
                ...List.generate(
                  4,
                  (index) => Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Icon(
                      Icons.local_fire_department,
                      size: 18,
                      color: index < _completedPomodoroCount ? AppColors.primary : AppColors.secondary.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _completedPomodoroCount = (_completedPomodoroCount + 1) % 5;
                    });
                  },
                  child: const Icon(Icons.add_circle_outline, size: 18, color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLectureCourseSelector(List<CourseModel> courses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        const Text(
          'MATA KULIAH KULIAH AKTIF',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.bgLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<int>(
            value: _activeLectureCourseId,
            hint: const Text('Pilih mata kuliah yang Anda ikuti...', style: TextStyle(fontSize: 12)),
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            onChanged: (int? newValue) {
              setState(() {
                _activeLectureCourseId = newValue;
              });
            },
            items: courses.map((course) {
              return DropdownMenuItem<int>(
                value: course.id,
                child: Text('${course.course_code} - ${course.name}', style: const TextStyle(fontSize: 12)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
