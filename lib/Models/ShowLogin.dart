import 'dart:convert';

ShowLogin showLoginFromJson(String str) => ShowLogin.fromJson(json.decode(str));

String showLoginToJson(ShowLogin data) => json.encode(data.toJson());

class ShowLogin {
  ShowLogin({
    required this.code,
    required this.message,
    required this.data,
  });

  int code;
  String message;
  Data data;

  factory ShowLogin.fromJson(Map<String, dynamic> json) => ShowLogin(
    code: json["code"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  Data();

  factory Data.fromJson(Map<String, dynamic> json) => Data(
  );

  Map<String, dynamic> toJson() => {
  };
}
