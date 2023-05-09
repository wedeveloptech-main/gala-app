import 'dart:convert';

HomeMenu homeMenuFromJson(String str) => HomeMenu.fromJson(json.decode(str));

String homeMenuToJson(HomeMenu data) => json.encode(data.toJson());

class HomeMenu {
  int ignore;
  int code;
  String message;
  Data data;

  HomeMenu({
    required this.ignore,
    required this.code,
    required this.message,
    required this.data,
  });

  factory HomeMenu.fromJson(Map<String, dynamic> json) => HomeMenu(
    ignore: json["ignore"],
    code: json["code"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "ignore": ignore,
    "code": code,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  List<Biting> bitings;
  List<Biting> juice;
  List<Biting> mocktail;

  Data({
    required this.bitings,
    required this.juice,
    required this.mocktail,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    bitings: List<Biting>.from(json["Bitings"].map((x) => Biting.fromJson(x))),
    juice: List<Biting>.from(json["Juice"].map((x) => Biting.fromJson(x))),
    mocktail: List<Biting>.from(json["Mocktail"].map((x) => Biting.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Bitings": List<dynamic>.from(bitings.map((x) => x.toJson())),
    "Juice": List<dynamic>.from(juice.map((x) => x.toJson())),
    "Mocktail": List<dynamic>.from(mocktail.map((x) => x.toJson())),
  };
}

class Biting {
  String ctgId;
  String prodId;
  String prodName;
  String thumb;

  Biting({
    required this.ctgId,
    required this.prodId,
    required this.prodName,
    required this.thumb,
  });

  factory Biting.fromJson(Map<String, dynamic> json) => Biting(
    ctgId: json["ctg_id"],
    prodId: json["prod_id"],
    prodName: json["prod_name"],
    thumb: json["thumb"],
  );

  Map<String, dynamic> toJson() => {
    "ctg_id": ctgId,
    "prod_id": prodId,
    "prod_name": prodName,
    "thumb": thumb,
  };
}