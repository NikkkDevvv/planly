import '../datasources/remote/campus_event_remote_ds.dart';
import '../models/campus_event_model.dart';

class CampusEventRepository {
  final CampusEventRemoteDataSource _remoteDataSource = CampusEventRemoteDataSource();

  Future<List<CampusEventModel>> getEvents() async {
    final response = await _remoteDataSource.getEvents();
    if (response.statusCode == 200) {
      final List<dynamic> list = response.data['data'];
      return list.map((item) => CampusEventModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load campus events');
    }
  }

  Future<CampusEventModel> createEvent(CampusEventModel event) async {
    final response = await _remoteDataSource.createEvent(event.toJson());
    if (response.statusCode == 201 || response.statusCode == 200) {
      return CampusEventModel.fromJson(response.data['data']);
    } else {
      throw Exception('Failed to create campus event');
    }
  }

  Future<CampusEventModel> updateEvent(int id, CampusEventModel event) async {
    final response = await _remoteDataSource.updateEvent(id, event.toJson());
    if (response.statusCode == 200) {
      return CampusEventModel.fromJson(response.data['data']);
    } else {
      throw Exception('Failed to update campus event');
    }
  }

  Future<void> deleteEvent(int id) async {
    final response = await _remoteDataSource.deleteEvent(id);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete campus event');
    }
  }
}
