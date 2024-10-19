import 'dart:convert';
import 'package:mongo_dart/mongo_dart.dart';

// JSON'dan model oluşturma
NotificationsModel notificationsModelFromJson(String str) =>
    NotificationsModel.fromJson(json.decode(str));

// Modeli JSON'a dönüştürme
String notificationsModelToJson(NotificationsModel data) =>
    json.encode(data.toJson());

class NotificationsModel {
  ObjectId id;
  String title;
  String description;
  DateTime date;

  NotificationsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
  });

  // JSON'dan sınıf oluşturma
  factory NotificationsModel.fromJson(Map<String, dynamic> json) =>
      NotificationsModel(
        id: json["_id"], // ObjectId dönüşümü
        title: json["title"],
        description: json["description"],
        date: DateTime.parse(json["date"]["\u0024date"]), // Tarihi parse etme
      );

  // Sınıfı JSON'a dönüştürme
  Map<String, dynamic> toJson() => {
        "_id": id.toJson(), // ObjectId'yi JSON'a çevirme
        "title": title,
        "description": description,
        "date": {
          "\u0024date": date.toIso8601String(), // Tarihi ISO 8601 formatına çevirme
        },
      };
}
