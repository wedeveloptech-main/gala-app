import 'dart:convert';

AddMenuData addMenuDataFromJson(String str) => AddMenuData.fromJson(json.decode(str));

String addMenuDataToJson(AddMenuData data) => json.encode(data.toJson());

class AddMenuData {
  AddMenuData({
    required this.ignore,
    required this.code,
    required this.message,
    required this.data,
  });

  int ignore;
  int code;
  String message;
  String data;

  factory AddMenuData.fromJson(Map<String, dynamic> json) => AddMenuData(
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
