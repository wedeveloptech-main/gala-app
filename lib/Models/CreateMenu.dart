import 'dart:convert';

CreateMenu createMenuFromJson(String str) => CreateMenu.fromJson(json.decode(str));

String createMenuToJson(CreateMenu data) => json.encode(data.toJson());

class CreateMenu {
  CreateMenu({
    required this.ignore,
    required this.code,
    required this.message,
    required this.data,
  });

  int ignore;
  int code;
  String message;
  List<Datum> data;

  factory CreateMenu.fromJson(Map<String, dynamic> json) => CreateMenu(
    ignore: json["ignore"],
    code: json["code"],
    message: json["message"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "ignore": ignore,
    "code": code,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  Datum({
    required this.id,
    required this.name,
  });

  String id;
  String name;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}