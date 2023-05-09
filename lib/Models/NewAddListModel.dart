import 'package:flutter/material.dart';
import 'dart:convert';

NewAddList newAddListModelFromJson(String str) => NewAddList.fromJson(json.decode(str));
String newAddListModelToJson(NewAddList data) => json.encode(data.toJson());


class NewAddList {
  NewAddList({
    required this.ignore, required this.code, required this.message, required this.data
  });

  int ignore;
  int code;
  String message;
  List<Data> data;

  factory NewAddList.fromJson(Map<String, dynamic> json) => NewAddList(
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
    required this.prodId,
    required this.prodName,
    required this.thumb,
  });

  String prodId;
  String prodName;
  String thumb;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    prodId: json["prod_id"] ?? '',
    prodName: json["prod_name"] ?? '',
    thumb: json["thumb"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "prod_id": prodId,
    "prod_name": prodName,
    "thumb": thumb,
  };
}
