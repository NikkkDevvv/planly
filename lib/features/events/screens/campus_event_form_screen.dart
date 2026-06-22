import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/campus_event_model.dart';
import '../bloc/campus_events_bloc.dart';
import '../bloc/campus_events_event.dart';
import '../bloc/campus_events_state.dart';

class CampusEventFormScreen extends StatefulWidget {
  final CampusEventModel? presetEvent;

  const CampusEventFormScreen({super.key, this.presetEvent});

  @override
  State<CampusEventFormScreen> createState() => _CampusEventFormScreenState();
}

class _CampusEventFormScreenState extends State<CampusEventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _locationController;
  late TextEditingController _organizerController;
  
  String _selectedCategory = 'seminar';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 30);
  String _selectedColorHex = '#6366F1'; // Default Indigo
  bool _isImportant = false;

  final List<Map<String, String>> _categories = const [
    {'value': 'seminar', 'label': 'Seminar'},
    {'value': 'webinar', 'label': 'Webinar'},
    {'value': 'workshop', 'label': 'Workshop'},
    {'value': 'study_club', 'label': 'Study Club'},
    {'value': 'ukm', 'label': 'UKM'},
    {'value': 'rapat_himpunan', 'label': 'Rapat Himpunan'},
    {'value': 'lomba', 'label': 'Lomba / Kompetisi'},
    {'value': 'lainnya', 'label': 'Lainnya'},
  ];

  final Map<String, String> _categoryColors = const {
    'seminar': '#6366F1',       // Indigo
    'webinar': '#06B6D4',       // Cyan
    'workshop': '#F59E0B',      // Amber
    'study_club': '#10B981',    // Emerald
    'ukm': '#8B5CF6',           // Purple
    'rapat_himpunan': '#EF4444', // Red
    'lomba': '#EC4899',         // Pink
    'lainnya': '#6B7280',       // Gray
  };

  @override
  void initState() {
    super.initState();
    final event = widget.presetEvent;
    
    _nameController = TextEditingController(text: event?.eventName ?? '');
    _descController = TextEditingController(text: event?.description ?? '');
    _locationController = TextEditingController(text: event?.location ?? '');
    _organizerController = TextEditingController(text: event?.organizer ?? '');
    
    if (event != null) {
      _selectedCategory = event.category;
      _isImportant = event.isImportant;
      _selectedColorHex = event.colorHex ?? _categoryColors[event.category] ?? '#6366F1';
      
      try {
        _selectedDate = DateTime.parse(event.eventDate);
      } catch (_) {}
      
      try {
        final startParts = event.startTime.split(':');
        _startTime = TimeOfDay(
          hour: int.parse(startParts[0]),
          minute: int.parse(startParts[1]),
        );
      } catch (_) {}
      
      try {
        final endParts = event.endTime.split(':');
        _endTime = TimeOfDay(
          hour: int.parse(endParts[0]),
          minute: int.parse(endParts[1]),
        );
      } catch (_) {}
    } else {
      _selectedColorHex = _categoryColors[_selectedCategory] ?? '#6366F1';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _organizerController.dispose();
    super.dispose();
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final hour = tod.hour.toString().padLeft(2, '0');
    final minute = tod.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (time != null) {
      setState(() {
        if (isStart) {
          _startTime = time;
        } else {
          _endTime = time;
        }
      });
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final startTimeStr = _formatTimeOfDay(_startTime);
    final endTimeStr = _formatTimeOfDay(_endTime);

    final event = CampusEventModel(
      id: widget.presetEvent?.id ?? 0,
      userId: widget.presetEvent?.userId ?? 0,
      eventName: _nameController.text.trim(),
      category: _selectedCategory,
      description: _descController.text.trim(),
      eventDate: formattedDate,
      startTime: startTimeStr,
      endTime: endTimeStr,
      location: _locationController.text.trim(),
      organizer: _organizerController.text.trim(),
      colorHex: _selectedColorHex,
      isImportant: _isImportant,
    );

    if (widget.presetEvent == null) {
      context.read<CampusEventsBloc>().add(AddCampusEvent(event));
    } else {
      context.read<CampusEventsBloc>().add(UpdateCampusEvent(widget.presetEvent!.id, event));
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.presetEvent != null;
    
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Edit Kegiatan Kampus' : 'Tambah Kegiatan Kampus',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textLightPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Inputs Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineLight.withOpacity(0.7)),
                ),
                child: Column(
                  children: [
                    // Event Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Kegiatan / Acara',
                        hintText: 'Misal: Rapat Himpunan Makrab',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama kegiatan wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Kategori Acara',
                      ),
                      items: _categories.map((cat) {
                        final val = cat['value']!;
                        final label = cat['label']!;
                        final colorHex = _categoryColors[val] ?? '#6366F1';
                        final color = Color(int.parse('FF${colorHex.replaceAll('#', '')}', radix: 16));

                        return DropdownMenuItem<String>(
                          value: val,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(label),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCategory = val;
                            _selectedColorHex = _categoryColors[val] ?? '#6366F1';
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi Acara (Opsional)',
                        hintText: 'Tulis detail kegiatan perkumpulan atau materi penting...',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Date & Time Selectors Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineLight.withOpacity(0.7)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Waktu Pelaksanaan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textLightPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Date picker row
                    InkWell(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.outlineLight),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate),
                              style: const TextStyle(fontSize: 14, color: AppColors.textLightPrimary),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_drop_down, color: AppColors.secondary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Time pickers row
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickTime(true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.outlineLight),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Mulai',
                                    style: TextStyle(fontSize: 10, color: AppColors.secondary),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 16, color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatTimeOfDay(_startTime),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textLightPrimary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickTime(false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.outlineLight),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Selesai',
                                    style: TextStyle(fontSize: 10, color: AppColors.secondary),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 16, color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatTimeOfDay(_endTime),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textLightPrimary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Location & Organizer Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineLight.withOpacity(0.7)),
                ),
                child: Column(
                  children: [
                    // Location
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Tempat / Lokasi Acara',
                        hintText: 'Misal: Ruang Seminar 1 / Link Zoom',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Tempat acara wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Organizer
                    TextFormField(
                      controller: _organizerController,
                      decoration: const InputDecoration(
                        labelText: 'Penyelenggara / Organizer',
                        hintText: 'Misal: Himpunan Mahasiswa Teknik',
                        prefixIcon: Icon(Icons.corporate_fare_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Penyelenggara wajib diisi';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Additional Settings Card (Important switch)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineLight.withOpacity(0.7)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Tandai Sebagai Penting',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textLightPrimary,
                          ),
                        ),
                        Text(
                          'Event akan ditandai dengan bintang emas',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textLightSecondary,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isImportant,
                      onChanged: (val) {
                        setState(() {
                          _isImportant = val;
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isEdit ? 'Simpan Perubahan' : 'Tambah Kegiatan',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
