class UserModel {
  final int id;
  final String name;
  final String email;
  final String? nim;
  final String? major;
  final int? semester;
  final String? profile_photo_url;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.nim,
    this.major,
    this.semester,
    this.profile_photo_url,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      nim: json['nim'],
      major: json['major'],
      semester: json['semester'],
      profile_photo_url: json['profile_photo_url'],
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
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      nim: nim ?? this.nim,
      major: major ?? this.major,
      semester: semester ?? this.semester,
      profile_photo_url: profile_photo_url ?? this.profile_photo_url,
    );
  }
}