class UserModel {
  final String username;

  UserModel({required this.username});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] as String,
    );
  }
}
