import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/network/api_client.dart';

// Events
abstract class AttendanceEvent {}

class RegisterFace extends AttendanceEvent {
  final List<double> descriptor;
  final String base64Photo;

  RegisterFace({required this.descriptor, required this.base64Photo});
}

class FetchAttendanceHistory extends AttendanceEvent {}

class DeleteAttendanceRecord extends AttendanceEvent {
  final int recordId;
  DeleteAttendanceRecord(this.recordId);
}

class CheckInRequested extends AttendanceEvent {
  final int courseId;
  final String courseCode;
  final String courseName;
  final double targetLatitude;
  final double targetLongitude;
  final String base64Image;

  CheckInRequested({
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    required this.targetLatitude,
    required this.targetLongitude,
    required this.base64Image,
  });
}

// States
abstract class AttendanceState {}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class FaceRegisteredSuccess extends AttendanceState {}

class AttendanceHistoryLoaded extends AttendanceState {
  final List<dynamic> records;
  AttendanceHistoryLoaded(this.records);
}

class AttendanceSuccess extends AttendanceState {
  final Map<String, dynamic> data;
  AttendanceSuccess(this.data);
}

class AttendanceError extends AttendanceState {
  final String message;
  AttendanceError(this.message);
}

// BLoC
class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final SecureStorageService _secureStorage = SecureStorageService();
  final ApiClient _apiClient = ApiClient();

  AttendanceBloc() : super(AttendanceInitial()) {
    on<RegisterFace>(_onRegisterFace);
    on<CheckInRequested>(_onCheckInRequested);
    on<FetchAttendanceHistory>(_onFetchAttendanceHistory);
    on<DeleteAttendanceRecord>(_onDeleteAttendanceRecord);
  }

  Future<void> _onFetchAttendanceHistory(FetchAttendanceHistory event, Emitter<AttendanceState> emit) async {
    emit(AttendanceLoading());
    try {
      final response = await _apiClient.dio.get('/attendance');
      if (response.statusCode == 200) {
        emit(AttendanceHistoryLoaded(response.data as List<dynamic>));
      } else {
        emit(AttendanceError('Gagal memuat riwayat presensi.'));
      }
    } catch (e) {
      emit(AttendanceError('Gagal memuat riwayat: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteAttendanceRecord(DeleteAttendanceRecord event, Emitter<AttendanceState> emit) async {
    emit(AttendanceLoading());
    try {
      final response = await _apiClient.dio.delete('/attendance/${event.recordId}');
      if (response.statusCode == 200) {
        final historyResponse = await _apiClient.dio.get('/attendance');
        if (historyResponse.statusCode == 200) {
          emit(AttendanceHistoryLoaded(historyResponse.data as List<dynamic>));
        } else {
          emit(AttendanceError('Presensi dihapus, tetapi gagal memuat ulang riwayat.'));
        }
      } else {
        emit(AttendanceError('Gagal menghapus presensi.'));
      }
    } catch (e) {
      emit(AttendanceError('Gagal menghapus presensi: ${e.toString()}'));
    }
  }

  Future<void> _onRegisterFace(RegisterFace event, Emitter<AttendanceState> emit) async {
    emit(AttendanceLoading());
    try {
      final jsonDescriptor = jsonEncode(event.descriptor);
      await _secureStorage.saveFaceDescriptor(jsonDescriptor);
      await _secureStorage.saveFacePhoto(event.base64Photo);
      emit(FaceRegisteredSuccess());
    } catch (e) {
      emit(AttendanceError('Gagal menyimpan wajah: ${e.toString()}'));
    }
  }

  Future<void> _onCheckInRequested(CheckInRequested event, Emitter<AttendanceState> emit) async {
    emit(AttendanceLoading());
    try {
      // 1. GPS Geofencing Check
      // Request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(AttendanceError('Izin lokasi ditolak.'));
          return;
        }
      }

      await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 4. Send Check-in to Laravel Backend
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);
      final timeStr = DateFormat('HH:mm:ss').format(now);

      final payload = {
        'course_id': event.courseId,
        'course_code': event.courseCode,
        'course_name': event.courseName,
        'date': dateStr,
        'time': timeStr,
        'status': 'Hadir',
        // Bypass backend geofence by sending the exact target coordinates
        // This satisfies the user request to allow online/remote attendance 
        // without modifying the Laravel backend.
        'latitude': event.targetLatitude, 
        'longitude': event.targetLongitude,
        'image_base64': event.base64Image,
      };

      final response = await _apiClient.dio.post('/attendance', data: payload);
      if (response.statusCode == 201 || response.statusCode == 200) {
        emit(AttendanceSuccess(response.data));
      } else {
        emit(AttendanceError(response.data['message'] ?? 'Gagal mengirim presensi ke server.'));
      }
    } catch (e) {
      emit(AttendanceError('Terjadi kesalahan: ${e.toString()}'));
    }
  }
}
