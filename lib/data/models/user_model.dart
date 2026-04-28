class UserModel {
  final int id;
  final String name; // ← Tampil di profile
  final String email; // ← Tampil di profile
  final String? nim; // ← Tampil di profile
  final String? major; // ← Tampil di profile
  final int? semester; // ← Tampil di profile
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
      id: json['id'] ?? 0, // Fallback ke 0 jika id null
      name: json['name'] ?? 'Guest User', // Fallback jika nama null
      email: json['email'] ?? '-',
      nim: json['nim']?.toString(), // Pastikan dikonversi ke string
      major: json['major'],
      semester: json['semester'] is int
          ? json['semester']
          : int.tryParse(json['semester']?.toString() ?? ''),
      profile_photo_url: json['profile_photo_url'] ?? json['foto'],
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
