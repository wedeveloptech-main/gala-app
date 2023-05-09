import 'dart:convert';

/*Albums albumsFromJson(String str) => Albums.fromJson(json.decode(str));

String albumsToJson(Albums data) => json.encode(data.toJson());

class Albums {
  Albums({
    required this.status,
    required this.data,
    required this.message,
  });

  String status;
  List<Datum> data;
  String message;

  factory Albums.fromJson(Map<String, dynamic> json) => Albums(
    status: json["status"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "message": message,
  };
}

class Datum {
  Datum({
    required this.id,
    required this.employeeName,
    required this.employeeSalary,
    required this.employeeAge,
    required this.profileImage,
  });

  int id;
  String employeeName;
  int employeeSalary;
  int employeeAge;
  String profileImage;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    employeeName: json["employee_name"],
    employeeSalary: json["employee_salary"],
    employeeAge: json["employee_age"],
    profileImage: json["profile_image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "employee_name": employeeName,
    "employee_salary": employeeSalary,
    "employee_age": employeeAge,
    "profile_image": profileImage,
  };
}*/

CatModel catModelFromJson(String str) => CatModel.fromJson(json.decode(str));

String catModelToJson(CatModel data) => json.encode(data.toJson());

class CatModel {
  CatModel({
    required this.code,
    required this.message,
    required this.data,
  });

  int code;
  String message;
  List<Datum> data;

  factory CatModel.fromJson(Map<String, dynamic> json) => CatModel(
    code: json["code"],
    message: json["message"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  Datum({
    required this.id,
    required this.name,
    required this.dispimg,
  });

  String id;
  String name;
  String dispimg;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"] ?? '',
    name: json["name"] ?? '',
    dispimg: json["dispimg"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "dispimg": dispimg,
  };
}

