import 'dart:convert';

AllMenu allMenuFromJson(String str) => AllMenu.fromJson(json.decode(str));

String allMenuToJson(AllMenu data) => json.encode(data.toJson());

class AllMenu {
  AllMenu({
    required this.ignore,
    required this.code,
    required this.message,
    required this.data,
  });

  int ignore;
  int code;
  String message;
  List<Datum> data;

  factory AllMenu.fromJson(Map<String, dynamic> json) => AllMenu(
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
    required this.prodId,
    required this.prodName,
    required this.thumb,
  });

  String prodId;
  String prodName;
  String thumb;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    prodId: json["prod_id"],
    prodName: json["prod_name"],
    thumb: json["thumb"],
  );

  Map<String, dynamic> toJson() => {
    "prod_id": prodId,
    "prod_name": prodName,
    "thumb": thumb,
  };
}
