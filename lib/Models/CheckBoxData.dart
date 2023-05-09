import 'package:flutter/material.dart';

class CheckBoxData {
  String id;
  String displayId;
  bool checked;

  CheckBoxData({
    required this.id,
    required this.displayId,
    required this.checked,
  });

  factory CheckBoxData.fromJson(Map<String, dynamic> json) => CheckBoxData(
    id: json["id"] == null ? null : json["id"],
    displayId: json["displayId"] == null ? null : json["displayId"],
    checked: json["checked"] == null ? null : json["checked"],
  );

  Map<String, dynamic> toJson() => {
    "id": id == null ? null : id,
    "displayId": displayId == null ? null : displayId,
    "checked": checked == null ? null : checked,
  };
}