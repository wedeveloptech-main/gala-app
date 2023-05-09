import 'dart:convert';

MenuListData menuListDataFromJson(String str) => MenuListData.fromJson(json.decode(str));

String menuListDataToJson(MenuListData data) => json.encode(data.toJson());

class MenuListData {
  MenuListData({
    required this.ignore,
    required this.code,
    required this.message,
    required this.data,
  });

  int ignore;
  int code;
  String message;
  List<Datum> data;

  factory MenuListData.fromJson(Map<String, dynamic> json) => MenuListData(
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
    required this.name,
    required this.items,
  });

  String ctgId;
  String name;
  List<Item> items;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    ctgId: json["ctg_id"],
    name: json["name"],
    items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "ctg_id": ctgId,
    "name": name,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class Item {
  Item({
    required this.prodId,
    required this.prodName,
    required this.thumb,
  });

  String prodId;
  String prodName;
  String thumb;

  factory Item.fromJson(Map<String, dynamic> json) => Item(
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
