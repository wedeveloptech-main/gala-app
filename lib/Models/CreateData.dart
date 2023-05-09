import 'dart:convert';

CreateData createDataFromJson(String str) => CreateData.fromJson(json.decode(str));

String createDataToJson(CreateData data) => json.encode(data.toJson());

class CreateData {
  CreateData({
    required this.ignore,
    required this.code,
    required this.message,
    required this.data,
  });

  int ignore;
  int code;
  String message;
  String data;

  factory CreateData.fromJson(Map<String, dynamic> json) => CreateData(
    ignore: json["ignore"],
    code: json["code"],
    message: json["message"],
    data: json["data"],
  );

  Map<String, dynamic> toJson() => {
    "ignore": ignore,
    "code": code,
    "message": message,
    "data": data,
  };
}
