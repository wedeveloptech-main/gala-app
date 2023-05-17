import 'dart:convert';

SelectedCreateMenu selectedCreateMenuFromJson(String str) => SelectedCreateMenu.fromJson(json.decode(str));

String selectedCreateMenuToJson(SelectedCreateMenu data) => json.encode(data.toJson());

class SelectedCreateMenu {
  int ignore;
  int code;
  String message;
  List<Datum1> data;

  SelectedCreateMenu({
    required this.ignore,
    required this.code,
    required this.message,
    required this.data,
  });

  factory SelectedCreateMenu.fromJson(Map<String, dynamic> json) => SelectedCreateMenu(
    ignore: json["ignore"],
    code: json["code"],
    message: json["message"],
    data: List<Datum1>.from(json["data"].map((x) => Datum1.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "ignore": ignore,
    "code": code,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum1 {
  String id;
  String name;
  String isselected;

  Datum1({
    required this.id,
    required this.name,
    required this.isselected,
  });

  factory Datum1.fromJson(Map<String, dynamic> json) => Datum1(
    id: json["id"],
    name: json["name"],
    isselected: json["isselected"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "isselected": isselected,
  };
}
