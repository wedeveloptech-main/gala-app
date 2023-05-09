import 'dart:convert';

SearchData searchDataFromJson(String str) => SearchData.fromJson(json.decode(str));

String searchDataToJson(SearchData data) => json.encode(data.toJson());

class SearchData {
  SearchData({
    required this.ignore,
    required this.code,
    required this.message,
    required this.data,
  });

  int ignore;
  int code;
  String message;
  List<Datum> data;

  factory SearchData.fromJson(Map<String, dynamic> json) => SearchData(
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

  factory Datum.fromJson(dynamic json) => Datum(
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
