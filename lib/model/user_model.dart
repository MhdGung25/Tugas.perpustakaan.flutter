class UserModel {
  final String? accessToken;
  final String? tokenType;
  final UserData? user;

  UserModel({this.accessToken, this.tokenType, this.user});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      user: json['user'] != null ? UserData.fromJson(json['user']) : null,
    );
  }
}

class UserData {
  final int? idUser;
  final String? username;
  final String? email;
  final String? namaLengkap;
  final int? level;

  UserData({
    this.idUser,
    this.username,
    this.email,
    this.namaLengkap,
    this.level,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      idUser: json['id_user'] ?? json['id'],
      username: json['username'],
      email: json['email'],
      namaLengkap: json['nama_lengkap'],
      level:
          json['level'] is int
              ? json['level']
              : int.tryParse('${json['level']}'),
    );
  }
}
