import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class WorkspaceAmbientSound extends StatelessWidget {
  final String selectedSound;
  final bool isAudioMuted;
  final ValueChanged<String?> onSoundChanged;
  final VoidCallback onMuteToggled;

  const WorkspaceAmbientSound({
    super.key,
    required this.selectedSound,
    required this.isAudioMuted,
    required this.onSoundChanged,
    required this.onMuteToggled,
  });

  static final List<Map<String, String>> _ambientSounds = const [
    {'id': 'none', 'name': 'Hening (Tanpa Suara)'},
    {'id': 'rain', 'name': 'Rintik Hujan Syahdu (Rain)'},
    {'id': 'lofi', 'name': 'Musik Fokus Lo-Fi (Lofi Synth)'},
    {'id': 'nature', 'name': 'Kebisingan Alam (Nature Wind)'},
    {'id': 'ocean', 'name': 'Deburan Ombak Pantai (Ocean)'},
    {'id': 'fireplace', 'name': 'Perapian Kayu Hangat (Fireplace)'},
    {'id': 'crickets', 'name': 'Jangkrik Malam Pedesaan (Crickets)'},
    {'id': 'cafe', 'name': 'Suasana Kafe Tenang (Coffee Shop)'},
    {'id': 'train', 'name': 'Perjalanan Kereta Malam (Night Train)'}
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButton<String>(
          value: selectedSound,
          elevation: 4,
          style: const TextStyle(color: AppColors.textLightPrimary, fontSize: 12, fontWeight: FontWeight.bold),
          underline: const SizedBox(),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          onChanged: onSoundChanged,
          items: _ambientSounds.map<DropdownMenuItem<String>>((sound) {
            return DropdownMenuItem<String>(
              value: sound['id'],
              child: Text(sound['name']!),
            );
          }).toList(),
        ),
        if (selectedSound != 'none') ...[
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(
              isAudioMuted ? Icons.volume_off : Icons.volume_up,
              color: isAudioMuted ? AppColors.error : AppColors.primary,
              size: 18,
            ),
            onPressed: onMuteToggled,
          ),
        ],
      ],
    );
  }
}
