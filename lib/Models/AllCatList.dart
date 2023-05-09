import 'dart:convert';

AllCatList allCatListFromJson(String str) => AllCatList.fromJson(json.decode(str));

String allCatListToJson(AllCatList data) => json.encode(data.toJson());

class AllCatList {
  AllCatList({
    required this.ignore,
    required this.code,
    required this.message,
    required this.data,
  });

  int ignore;
  int code;
  String message;
  List<Datum> data;

  factory AllCatList.fromJson(Map<String, dynamic> json) => AllCatList(
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
    required this.ctgId,
    required this.ctgName,
    required this.thumb,
  });

  String ctgId;
  String ctgName;
  String thumb;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    ctgId: json["ctg_id"],
    ctgName: json["ctg_name"],
    thumb: json["thumb"],
  );

  Map<String, dynamic> toJson() => {
    "ctg_id": ctgId,
    "ctg_name": ctgName,
    "thumb": thumb,
  };
}
