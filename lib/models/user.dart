class UserModel {
  // final String id;
  final String username;
  // final String email;
  // final String alamat;
  // final String hp;

  UserModel({
    //required this.id,
    required this.username,
    // required this.email,
    // required this.alamat,
    // required this.hp,
  });
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(username: map['username'] ?? '');
  }
}
