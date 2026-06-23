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
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';
import '../widgets/profile_info_section.dart';
import '../widgets/profile_menu.dart';

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
                    ProfileHeader(
                      user: user,
                      onPickAvatar: () => _pickAvatar(user),
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
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: AppColors.outlineLight.withValues(alpha: 0.7)),
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
                          ProfileStats(user: user),
                          const SizedBox(height: 20),
                          ProfileInfoSection(user: user),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Menu Options Card
                    ProfileMenu(
                      onEditProfile: () => _editFields(user),
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
}
