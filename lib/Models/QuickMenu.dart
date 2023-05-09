import 'dart:convert';

QuickMenu quickMenuFromJson(String str) => QuickMenu.fromJson(json.decode(str));

String quickMenuToJson(QuickMenu data) => json.encode(data.toJson());

class QuickMenu {
  QuickMenu({
    required this.ignore,
    required this.code,
    required this.message,
    required this.data,
  });

  int ignore;
  int code;
  String message;
  List<Datum> data;

  factory QuickMenu.fromJson(Map<String, dynamic> json) => QuickMenu(
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
    required this.iconurl,
    required this.label,
  });

  int ctgId;
  String iconurl;
  String label;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    ctgId: json["ctg_id"],
    iconurl: json["iconurl"],
    label: json["label"],
  );

  Map<String, dynamic> toJson() => {
    "ctg_id": ctgId,
    "iconurl": iconurl,
    "label": label,
  };
}
