import 'dart:convert';

CatList catListFromJson(String str) => CatList.fromJson(json.decode(str));

String catListToJson(CatList data) => json.encode(data.toJson());

class CatList {
  CatList({
    required this.ignore,
    required this.code,
    required this.message,
    required this.data,
  });

  int ignore;
  int code;
  String message;
  List<Data> data;

  factory CatList.fromJson(Map<String, dynamic> json) => CatList(
    ignore: json["ignore"],
    code: json["code"],
    message: json["message"],
    data: List<Data>.from(json["data"].map((x) => Data.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "ignore": ignore,
    "code": code,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}


class Data {
  Data({
    required this.ctgId,
    required this.ctgName,
    required this.thumb,
  });

  String ctgId;
  String ctgName;
  String thumb;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
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
