// To parse this JSON data, do
//
//     final purpleString = purpleStringFromJson(jsonString);

import 'dart:convert';

PurpleString purpleStringFromJson(String str) => PurpleString.fromJson(json.decode(str));

String purpleStringToJson(PurpleString data) => json.encode(data.toJson());

class PurpleString {
  int id;
  DateTime date;
  String mealType;
  String mealTaken;

  PurpleString({
    required this.id,
    required this.date,
    required this.mealType,
    required this.mealTaken,
  });

  factory PurpleString.fromJson(Map<String, dynamic> json) => PurpleString(
    id: json["id"],
    date: DateTime.parse(json["date"]),
    mealType: json["meal_type"],
    mealTaken: json["meal_taken"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "date": date.toIso8601String(),
    "meal_type": mealType,
    "meal_taken": mealTaken,
  };
}
