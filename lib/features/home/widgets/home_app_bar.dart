import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../navigation/screens/main_layout.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String formattedClock;

  const HomeAppBar({
    super.key,
    required this.formattedClock,
  });

  ImageProvider? _getProfileImageProvider(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('data:image') && url.contains('base64,')) {
      try {
        final base64String = url.split('base64,').last;
        return MemoryImage(base64Decode(base64String));
      } catch (e) {
        return null;
      }
    }
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return NetworkImage(url);
    }
    try {
      return MemoryImage(base64Decode(url));
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white.withValues(alpha: 0.9),
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
      titleSpacing: 0,
      title: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          String userName = 'Mahasiswa';
          ImageProvider? avatarProvider;
          if (state is Authenticated) {
            userName = state.user.name.split(' ')[0];
            avatarProvider = _getProfileImageProvider(
              state.user.profile_photo_url,
            );
          }
          return Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryContainer,
                backgroundImage: avatarProvider,
                child: avatarProvider == null
                    ? const Icon(
                        Icons.person,
                        size: 16,
                        color: AppColors.primary,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                'Halo, $userName!',
                style: const TextStyle(
                  color: AppColors.textLightPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 24.0),
          child: Text(
            formattedClock,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
