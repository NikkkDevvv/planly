import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_toast.dart';
import '../bloc/attendance_bloc.dart';

class AttendanceCheckinScreen extends StatefulWidget {
  final int courseId;
  final String courseCode;
  final String courseName;

  const AttendanceCheckinScreen({
    super.key,
    required this.courseId,
    required this.courseCode,
    required this.courseName,
  });

  @override
  State<AttendanceCheckinScreen> createState() => _AttendanceCheckinScreenState();
}

class _AttendanceCheckinScreenState extends State<AttendanceCheckinScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _hasCameraError = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera error: $e');
      if (mounted) {
        setState(() {
          _hasCameraError = true;
        });
      }
    }
  }

  Future<void> _takePhotoAndCheckIn() async {
    setState(() => _isVerifying = true);

    String base64Image = 'data:image/jpeg;base64,/9j/4AAQSkZJRg==';

    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final XFile file = await _cameraController!.takePicture();
        final bytes = await file.readAsBytes();
        base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      } catch (e) {
        debugPrint('Error taking picture during check-in: $e');
      }
    }

    if (mounted) {
      context.read<AttendanceBloc>().add(CheckInRequested(
        courseId: widget.courseId,
        courseCode: widget.courseCode,
        courseName: widget.courseName,
        targetLatitude: -7.4244,
        targetLongitude: 109.2301,
        base64Image: base64Image,
      ));
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: BlocListener<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceSuccess) {
            AppToast.showSuccess(context, 'Presensi berhasil dikirim dan diverifikasi!');
            Navigator.pop(context, true);
          } else if (state is AttendanceError) {
            setState(() {
              _isVerifying = false;
            });
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Presensi Gagal'),
                content: Text(state.message),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    child: const Text('Tutup'),
                  ),
                ],
              ),
            );
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // Top cancel bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Pemindaian Presensi',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Scanner Frame
              Center(
                child: SizedBox(
                  width: 280,
                  height: 280,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Circular Camera Box
                      Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 3),
                        ),
                        child: ClipOval(
                          child: _isCameraInitialized && !_hasCameraError
                            ? FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: 260,
                                  height: 260 * _cameraController!.value.aspectRatio,
                                  child: CameraPreview(_cameraController!),
                                ),
                              )
                            : Container(
                                  color: AppColors.surfaceDark,
                                  child: const Icon(
                                    Icons.face,
                                    size: 120,
                                    color: AppColors.primary,
                                  ),
                                ),
                        ),
                      ),
                      
                      // L-Shape Corner Brackets
                      _buildCornerBrackets(),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Camera controls / Submit button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24),
                child: Column(
                  children: [
                    if (_isVerifying) ...[
                      const CircularProgressIndicator(color: AppColors.primary),
                      const SizedBox(height: 16),
                      const Text(
                        'Memverifikasi Lokasi & Mengirim Presensi...',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      const Text(
                        'Posisikan wajah Anda di depan kamera dan tekan tombol untuk presensi.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isCameraInitialized && !_hasCameraError ? _takePhotoAndCheckIn : null,
                        icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                        label: const Text(
                          'Kirim Presensi (Ambil Foto)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCornerBrackets() {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: _bracketSegment(top: true, left: true),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: _bracketSegment(top: true, left: false),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: _bracketSegment(top: false, left: true),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: _bracketSegment(top: false, left: false),
          ),
        ],
      ),
    );
  }

  Widget _bracketSegment({required bool top, required bool left}) {
    const double size = 24.0;
    const double thickness = 4.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            top: top ? 0 : null,
            bottom: !top ? 0 : null,
            left: 0,
            right: 0,
            child: Container(height: thickness, color: Colors.greenAccent),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: left ? 0 : null,
            right: !left ? 0 : null,
            child: Container(width: thickness, color: Colors.greenAccent),
          ),
        ],
      ),
    );
  }
}
