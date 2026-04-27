class UserModel {
  final int id;
  final String name;
  final String email;
  final String? nim;
  final String? major;
  final int? semester;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.nim,
    this.major,
    this.semester,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      nim: json['nim'],
      major: json['major'],
      semester: json['semester'],
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
    };
  }
}