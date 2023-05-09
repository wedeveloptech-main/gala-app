import 'dart:convert';

LoginData loginDataFromJson(String str) => LoginData.fromJson(json.decode(str));

String loginDataToJson(LoginData data) => json.encode(data.toJson());

class LoginData {
  int ignore;
  int code;
  String message;
  Data data;

  LoginData({
    required this.ignore,
    required this.code,
    required this.message,
    required this.data,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) => LoginData(
    ignore: json["ignore"],
    code: json["code"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "ignore": ignore,
    "code": code,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  int cid;
  String phoneno;
  String salt;
  int password;
  String name;
  int profilestatus;

  Data({
    required this.cid,
    required this.phoneno,
    required this.salt,
    required this.password,
    required this.name,
    required this.profilestatus,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    cid: json["cid"],
    phoneno: json["phoneno"],
    salt: json["salt"],
    password: json["password"],
    name: json["name"],
    profilestatus: json["profilestatus"],
  );

  Map<String, dynamic> toJson() => {
    "cid": cid,
    "phoneno": phoneno,
    "salt": salt,
    "password": password,
    "name": name,
    "profilestatus": profilestatus,
  };
}
