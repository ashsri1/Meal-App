// To parse this JSON data, do
//
//     final suggestion = suggestionFromJson(jsonString);

import 'dart:convert';

List<Suggestion> suggestionFromJson(String str) => List<Suggestion>.from(json.decode(str).map((x) => Suggestion.fromJson(x)));

String suggestionToJson(List<Suggestion> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Suggestion {
  int id;
  String name;

  Suggestion({
    required this.id,
    required this.name,
  });

  factory Suggestion.fromJson(Map<String, dynamic> json) => Suggestion(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}
