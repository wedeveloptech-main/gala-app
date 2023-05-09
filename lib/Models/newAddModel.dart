import 'package:flutter/material.dart';
import 'dart:convert';

NewAdd newAddModelFromJson(String str) => NewAdd.fromJson(json.decode(str));
String newAddModelToJson(NewAdd data) => json.encode(data.toJson());

/*class NewAdd {
  int ignore;
  int code;
  String message;
  List<Data> data;

  NewAdd({required this.ignore, required this.code, required this.message, required this.data});

  NewAdd.fromJson(Map<String, dynamic> json) {
    ignore = json['ignore'];
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ignore'] = this.ignore;
    data['code'] = this.code;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}*/

class NewAdd {
  NewAdd({
    required this.ignore, required this.code, required this.message, required this.data
  });

  int ignore;
  int code;
  String message;
  List<Data> data;

  factory NewAdd.fromJson(Map<String, dynamic> json) => NewAdd(
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

/*class Data {
  String? prodId;
  String? prodName;
  String? thumb;

  Data({this.prodId, this.prodName, this.thumb});

  Data.fromJson(Map<String, dynamic> json) {
    prodId = json['prod_id'];
    prodName = json['prod_name'];
    thumb = json['thumb'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['prod_id'] = this.prodId;
    data['prod_name'] = this.prodName;
    data['thumb'] = this.thumb;
    return data;
  }
}*/