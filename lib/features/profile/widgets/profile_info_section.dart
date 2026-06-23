import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_model.dart';

class ProfileInfoSection extends StatelessWidget {
  final UserModel user;

  const ProfileInfoSection({
    super.key,
    required this.user,
  });

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
    );
  }
}
