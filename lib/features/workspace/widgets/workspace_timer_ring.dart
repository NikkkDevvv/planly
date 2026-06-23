import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class WorkspaceTimerRing extends StatelessWidget {
  final String displayText;
  final double? progress;
  final bool isRunning;
  final VoidCallback onPlayPause;
  final VoidCallback onReset;

  const WorkspaceTimerRing({
    super.key,
    required this.displayText,
    required this.progress,
    required this.isRunning,
    required this.onPlayPause,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circular progress Indicator
          SizedBox(
            width: 200,
            height: 200,
            child: progress == null
                ? const CircularProgressIndicator(
                    strokeWidth: 10,
                    color: AppColors.primary,
                    backgroundColor: AppColors.bgLight,
                  )
                : CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    color: AppColors.primary,
                    backgroundColor: AppColors.bgLight,
                    strokeCap: StrokeCap.round,
                  ),
          ),
          // Clock overlay text and controls
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayText,
                style: const TextStyle(
                  fontSize: 32,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLightPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      isRunning ? Icons.pause_circle_filled : Icons.play_circle_filled,
                      size: 38,
                      color: AppColors.primary,
                    ),
                    onPressed: onPlayPause,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.replay_circle_filled,
                      size: 38,
                      color: AppColors.secondary,
                    ),
                    onPressed: onReset,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
