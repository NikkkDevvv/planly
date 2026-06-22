import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../navigation/screens/main_layout.dart';

import '../../courses/screens/course_screen.dart';
import '../../events/screens/campus_events_screen.dart';

class ProfileScreens extends StatefulWidget {
  const ProfileScreens({super.key});

  @override
  State<ProfileScreens> createState() => _ProfileScreensState();
}

class _ProfileScreensState extends State<ProfileScreens> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(FetchProfile());
  }

  /// Compress image bytes using built-in Flutter ui engine (target width 300px)
  Future<Uint8List> _compressImage(Uint8List bytes, {int targetWidth = 300}) async {
    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: targetWidth,
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// Helper to return correct ImageProvider supporting base64 strings and network URLs
  ImageProvider? _getProfileImageProvider(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('data:image') && url.contains('base64,')) {
      try {
        final base64String = url.split('base64,').last;
        return MemoryImage(base64Decode(base64String));
      } catch (e) {
        debugPrint('Error decoding base64 image: $e');
        return null;
      }
    }
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return NetworkImage(url);
    }
    // Attempt raw base64 string decoding
    try {
      return MemoryImage(base64Decode(url));
    } catch (e) {
      return null;
    }
  }

  Future<void> _pickAvatar(UserModel user) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final bytes = await file.readAsBytes();
        
        // Compress image to avoid large base64 payload database errors (500 Error)
        final compressedBytes = await _compressImage(bytes);
        final String base64Data = base64Encode(compressedBytes);
        final String dataUrl = 'data:image/png;base64,$base64Data';

        final updatedUser = user.copyWith(profile_photo_url: dataUrl);
        if (mounted) {
          context.read<ProfileBloc>().add(UpdateProfile(updatedUser));
        }
      }
    } catch (e) {
      debugPrint('Error picking avatar: $e');
    }
  }

  Future<void> _editFields(UserModel user) async {
    final nameController = TextEditingController(text: user.name);
    final nimController = TextEditingController(text: user.nim);
    final majorController = TextEditingController(text: user.major);
    final semesterController = TextEditingController(
      text: user.semester?.toString() ?? '1',
    );
    final gpaCurrentController = TextEditingController(
      text: user.gpaCurrent?.toString() ?? '',
    );
    final gpaTargetController = TextEditingController(
      text: user.gpaTarget?.toString() ?? '',
    );
    final hoursController = TextEditingController(
      text: user.targetStudyHours?.toString() ?? '',
    );
    final addressController = TextEditingController(text: user.address ?? '');

    final bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Detail Profil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
              ),
              TextField(
                controller: nimController,
                decoration: const InputDecoration(labelText: 'NIM'),
              ),
              TextField(
                controller: majorController,
                decoration: const InputDecoration(labelText: 'Jurusan'),
              ),
              TextField(
                controller: semesterController,
                decoration: const InputDecoration(labelText: 'Semester'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: gpaCurrentController,
                decoration: const InputDecoration(labelText: 'IPK Saat Ini'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: gpaTargetController,
                decoration: const InputDecoration(labelText: 'IPK Target'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: hoursController,
                decoration: const InputDecoration(
                  labelText: 'Target Jam Belajar/Hari',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Alamat'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Simpan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final updatedUser = user.copyWith(
        name: nameController.text.trim(),
        nim: nimController.text.trim(),
        major: majorController.text.trim(),
        semester: int.tryParse(semesterController.text),
        gpaCurrent: double.tryParse(gpaCurrentController.text),
        gpaTarget: double.tryParse(gpaTargetController.text),
        targetStudyHours: int.tryParse(hoursController.text),
        address: addressController.text.trim(),
      );
      if (mounted) {
        context.read<ProfileBloc>().add(UpdateProfile(updatedUser));
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari Planly?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Keluar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      context.read<AuthBloc>().add(LogoutRequested());
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
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.primary),
            onPressed: () => context
                .findAncestorStateOfType<MainLayoutState>()
                ?.openDrawer(),
          ),
        ),
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textLightPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            onPressed: _handleLogout,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is ProfileError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Gagal memuat profil:\n${state.message}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.error, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProfileBloc>().add(FetchProfile());
                      },
                      child: const Text('Coba Lagi'),
                    )
                  ],
                ),
              ),
            );
          } else if (state is ProfileLoaded) {
            final user = state.user;
            final imageProvider = _getProfileImageProvider(user.profile_photo_url);

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProfileBloc>().add(FetchProfile());
              },
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    // Profile Header card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: AppColors.outlineLight.withOpacity(0.7)),
                      ),
                      child: Column(
                        children: [
                          // Avatar stack
                          GestureDetector(
                            onTap: () => _pickAvatar(user),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primary.withOpacity(0.2),
                                      width: 4,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 46,
                                    backgroundColor: AppColors.secondaryContainer,
                                    backgroundImage: imageProvider,
                                    child: imageProvider == null
                                        ? Text(
                                            user.name.isNotEmpty
                                                ? user.name.substring(0, 1).toUpperCase()
                                                : 'M',
                                            style: const TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                                Positioned(
                                  bottom: 2,
                                  right: 2,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        )
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textLightPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textLightSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Divider(height: 1, color: AppColors.outlineLight),
                          const SizedBox(height: 20),

                          // Academic Stats Row with Elegant Sub-Cards
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'NIM',
                                  user.nim ?? '-',
                                  Icons.badge_outlined,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildStatCard(
                                  'Semester',
                                  user.semester?.toString() ?? '-',
                                  Icons.school_outlined,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildStatCard(
                                  'Prodi',
                                  user.major ?? '-',
                                  Icons.account_tree_outlined,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Academic Progress (GPA Target & Current)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: AppColors.outlineLight.withOpacity(0.7)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Target Akademik',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textLightPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildProgressTile(
                                  'IPK Saat Ini',
                                  user.gpaCurrent?.toStringAsFixed(2) ?? '0.00',
                                  Icons.star_rounded,
                                  AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildProgressTile(
                                  'IPK Target',
                                  user.gpaTarget?.toStringAsFixed(2) ?? '0.00',
                                  Icons.flag_rounded,
                                  AppColors.success,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildDetailRow(
                            icon: Icons.timer_outlined,
                            label: 'Target Jam Belajar/Hari',
                            value: '${user.targetStudyHours ?? 0} Jam',
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Divider(height: 1, color: AppColors.outlineLight),
                          ),
                          _buildDetailRow(
                            icon: Icons.home_outlined,
                            label: 'Alamat Domisili',
                            value: user.address ?? '-',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Menu Options Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: AppColors.outlineLight.withOpacity(0.7)),
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: Icons.edit_note_rounded,
                            title: 'Edit Detail Profil',
                            onTap: () => _editFields(user),
                          ),
                          const Divider(height: 1, color: AppColors.outlineLight),
                          _buildMenuItem(
                            icon: Icons.book_outlined,
                            title: 'Daftar Mata Kuliah',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CoursesScreens(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1, color: AppColors.outlineLight),
                          _buildMenuItem(
                            icon: Icons.event_note_rounded,
                            title: 'Kegiatan Kampus (Events)',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CampusEventsScreen(),
                                ),
                              );
                            },
                          ),

                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary.withOpacity(0.7), size: 16),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textLightSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTile(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLightSecondary,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.secondary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textLightSecondary,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textLightPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textLightPrimary,
        ),
      ),
      trailing:
          trailing ??
          const Icon(Icons.chevron_right_rounded, color: AppColors.secondary, size: 20),
      onTap: onTap,
    );
  }
}
