class CampusEventModel {
  final int id;
  final int userId;
  final String eventName;
  final String category;
  final String? description;
  final String eventDate;
  final String startTime;
  final String endTime;
  final String location;
  final String organizer;
  final String? colorHex;
  final bool isImportant;

  CampusEventModel({
    required this.id,
    required this.userId,
    required this.eventName,
    required this.category,
    this.description,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.organizer,
    this.colorHex,
    required this.isImportant,
  });

  factory CampusEventModel.fromJson(Map<String, dynamic> json) {
    return CampusEventModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      eventName: json['event_name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'],
      eventDate: json['event_date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      location: json['location'] ?? '',
      organizer: json['organizer'] ?? '',
      colorHex: json['color_hex'],
      isImportant: json['is_important'] is bool 
          ? json['is_important'] 
          : (json['is_important'] == 1 || json['is_important'] == '1'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'event_name': eventName,
      'category': category,
      'description': description,
      'event_date': eventDate,
      'start_time': startTime,
      'end_time': endTime,
      'location': location,
      'organizer': organizer,
      'color_hex': colorHex,
      'is_important': isImportant,
    };
  }

  CampusEventModel copyWith({
    int? id,
    int? userId,
    String? eventName,
    String? category,
    String? description,
    String? eventDate,
    String? startTime,
    String? endTime,
    String? location,
    String? organizer,
    String? colorHex,
    bool? isImportant,
  }) {
    return CampusEventModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventName: eventName ?? this.eventName,
      category: category ?? this.category,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      organizer: organizer ?? this.organizer,
      colorHex: colorHex ?? this.colorHex,
      isImportant: isImportant ?? this.isImportant,
    );
  }
}
