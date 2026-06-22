class UserModel {
  final int id;
  final String name; 
  final String email; 
  final String? nim; 
  final String? major; 
  final int? semester; 
  final String? profile_photo_url;
  final double? gpaCurrent;
  final double? gpaTarget;
  final int? targetStudyHours;
  final String? address;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.nim,
    this.major,
    this.semester,
    this.profile_photo_url,
    this.gpaCurrent,
    this.gpaTarget,
    this.targetStudyHours,
    this.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0, 
      name: json['name'] ?? 'Guest User', 
      email: json['email'] ?? '-',
      nim: json['nim']?.toString(), 
      major: json['major'],
      semester: json['semester'] is int
          ? json['semester']
          : int.tryParse(json['semester']?.toString() ?? ''),
      profile_photo_url: json['profile_photo_url'] ?? json['foto'],
      gpaCurrent: json['gpa_current'] != null ? double.tryParse(json['gpa_current'].toString()) : null,
      gpaTarget: json['gpa_target'] != null ? double.tryParse(json['gpa_target'].toString()) : null,
      targetStudyHours: json['target_study_hours'] is int
          ? json['target_study_hours']
          : int.tryParse(json['target_study_hours']?.toString() ?? ''),
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'nim': nim,
      'major': major,
      'semester': semester,
      'profile_photo_url': profile_photo_url,
      'gpa_current': gpaCurrent,
      'gpa_target': gpaTarget,
      'target_study_hours': targetStudyHours,
      'address': address,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? nim,
    String? major,
    int? semester,
    String? profile_photo_url,
    double? gpaCurrent,
    double? gpaTarget,
    int? targetStudyHours,
    String? address,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      nim: nim ?? this.nim,
      major: major ?? this.major,
      semester: semester ?? this.semester,
      profile_photo_url: profile_photo_url ?? this.profile_photo_url,
      gpaCurrent: gpaCurrent ?? this.gpaCurrent,
      gpaTarget: gpaTarget ?? this.gpaTarget,
      targetStudyHours: targetStudyHours ?? this.targetStudyHours,
      address: address ?? this.address,
    );
  }
}
