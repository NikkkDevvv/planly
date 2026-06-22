import '../datasources/remote/schedule_remote_ds.dart';
import '../models/schedule_model.dart';

class ScheduleRepository {
  final ScheduleRemoteDataSource _remoteDataSource = ScheduleRemoteDataSource();

  Future<List<ScheduleModel>> getReschedules() async {
    final response = await _remoteDataSource.getReschedules();
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data is List ? response.data : [];
      return data.map((json) => ScheduleModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reschedules');
    }
  }

  Future<ScheduleModel> createReschedule(ScheduleModel reschedule) async {
    final response = await _remoteDataSource.createReschedule(reschedule.toJson());
    if (response.statusCode == 201 || response.statusCode == 200) {
      return ScheduleModel.fromJson(response.data);
    } else {
      throw Exception('Failed to create reschedule');
    }
  }

  Future<void> deleteReschedule(int courseId, String originalDate) async {
    final response = await _remoteDataSource.deleteReschedule(
      courseId: courseId,
      originalDate: originalDate,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to restore normal schedule');
    }
  }
}
