import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/campus_event_model.dart';
import '../bloc/campus_events_bloc.dart';
import '../bloc/campus_events_event.dart';
import '../bloc/campus_events_state.dart';
import '../../navigation/screens/main_layout.dart';
import 'campus_event_form_screen.dart';
import '../widgets/event_card.dart';

class CampusEventsScreen extends StatefulWidget {
  const CampusEventsScreen({super.key});

  @override
  State<CampusEventsScreen> createState() => _CampusEventsScreenState();
}

class _CampusEventsScreenState extends State<CampusEventsScreen> {
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  final List<Map<String, String>> _categories = const [
    {'value': 'Semua', 'label': 'Semua'},
    {'value': 'seminar', 'label': 'Seminar'},
    {'value': 'webinar', 'label': 'Webinar'},
    {'value': 'workshop', 'label': 'Workshop'},
    {'value': 'study_club', 'label': 'Study Club'},
    {'value': 'ukm', 'label': 'UKM'},
    {'value': 'rapat_himpunan', 'label': 'Rapat'},
    {'value': 'lomba', 'label': 'Lomba'},
    {'value': 'lainnya', 'label': 'Lainnya'},
  ];

  @override
  void initState() {
    super.initState();
    context.read<CampusEventsBloc>().add(FetchCampusEvents());
  }

  Future<void> _handleDelete(CampusEventModel event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kegiatan'),
        content: Text('Apakah Anda yakin ingin menghapus "${event.eventName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      context.read<CampusEventsBloc>().add(DeleteCampusEvent(event.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                onPressed: () => Navigator.pop(context),
              )
            : Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.primary),
                  onPressed: () => context
                      .findAncestorStateOfType<MainLayoutState>()
                      ?.openDrawer(),
                ),
              ),
        title: const Text(
          'Kegiatan Kampus',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textLightPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.bgLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineLight),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Cari kegiatan...',
                  hintStyle: TextStyle(color: AppColors.textLightSecondary, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: AppColors.secondary, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          // Horizontal Categories Filter Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat['value'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(cat['label']!),
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = cat['value']!;
                          });
                        },
                        selectedColor: AppColors.primary.withValues(alpha: 0.15),
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.primary : AppColors.textLightSecondary,
                        ),
                        backgroundColor: AppColors.bgLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected 
                                ? AppColors.primary.withValues(alpha: 0.3) 
                                : AppColors.outlineLight,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // Main events list content
          Expanded(
            child: BlocBuilder<CampusEventsBloc, CampusEventsState>(
              builder: (context, state) {
                if (state is CampusEventsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                } else if (state is CampusEventsError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Gagal memuat kegiatan:\n${state.message}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.error),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<CampusEventsBloc>().add(FetchCampusEvents());
                            },
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (state is CampusEventsLoaded) {
                  // Filter events by selected category and search query
                  final filteredEvents = state.events.where((e) {
                    bool matchCategory = _selectedCategory == 'Semua' || e.category.toLowerCase() == _selectedCategory.toLowerCase();
                    bool matchSearch = e.eventName.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                                       (e.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
                    return matchCategory && matchSearch;
                  }).toList();

                  if (filteredEvents.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy_rounded,
                            size: 72,
                            color: AppColors.secondary.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Belum Ada Kegiatan Kampus',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textLightPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedCategory == 'Semua'
                                ? 'Tambahkan agenda non-kuliah pertamamu!'
                                : 'Tidak ada kegiatan dengan kategori ini.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textLightSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<CampusEventsBloc>().add(FetchCampusEvents());
                    },
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      itemCount: filteredEvents.length,
                      itemBuilder: (context, index) {
                        final event = filteredEvents[index];
                        return EventCard(
                          event: event,
                          onDelete: () => _handleDelete(event),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CampusEventFormScreen(),
            ),
          ).then((_) {
            context.read<CampusEventsBloc>().add(FetchCampusEvents());
          });
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
