import 'dart:convert';

SelectedCreateMenu selectedCreateMenuFromJson(String str) => SelectedCreateMenu.fromJson(json.decode(str));

String selectedCreateMenuToJson(SelectedCreateMenu data) => json.encode(data.toJson());

class SelectedCreateMenu {
  int ignore;
  int code;
  String message;
  List<Datum> data;

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
  String id;
  String name;
  String isselected;

  Datum({
    required this.id,
    required this.name,
    required this.isselected,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
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
