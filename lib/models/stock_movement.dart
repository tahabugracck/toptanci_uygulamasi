// To parse this JSON data, do
//
//     final stockMovementModel = stockMovementModelFromJson(jsonString);

import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

StockMovementModel stockMovementModelFromJson(String str) => StockMovementModel.fromJson(json.decode(str));

String stockMovementModelToJson(StockMovementModel data) => json.encode(data.toJson());

class StockMovementModel {
    ObjectId id;
    String productId;
    String type;
    int quantity;
    DateTime date;
    Source source;
    String destination;
    String userId;

    StockMovementModel({
        required this.id,
        required this.productId,
        required this.type,
        required this.quantity,
        required this.date,
        required this.source,
        required this.destination,
        required this.userId,
    });

    factory StockMovementModel.fromJson(Map<String, dynamic> json) => StockMovementModel(
        id: json["_id"],
        productId: json["productId"],
        type: json["type"],
        quantity: json["quantity"],
        date: DateTime.parse(json["date"]),
        source: Source.fromJson(json["source"]),
        destination: json["destination"],
        userId: json["userId"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id.toJson(),
        "productId": productId,
        "type": type,
        "quantity": quantity,
        "date": date.toIso8601String(),
        "source": source.toJson(),
        "destination": destination,
        "userId": userId,
    };
}

class Id {
    String oid;

    Id({
        required this.oid,
    });

    factory Id.fromJson(Map<String, dynamic> json) => Id(
        oid: json["\u0024oid"],
    );

    Map<String, dynamic> toJson() => {
        "\u0024oid": oid,
    };
}

class Source {
    String name;
    String productId;

    Source({
        required this.name,
        required this.productId,
    });

    factory Source.fromJson(Map<String, dynamic> json) => Source(
        name: json["name"],
        productId: json["productId"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "productId": productId,
    };
}
