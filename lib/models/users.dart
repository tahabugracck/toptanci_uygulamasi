// To parse this JSON data, do
//
//     final usersModel = usersModelFromJson(jsonString);

import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

UsersModel usersModelFromJson(String str) => UsersModel.fromJson(json.decode(str));

String usersModelToJson(UsersModel data) => json.encode(data.toJson());

class UsersModel {
    ObjectId id;
    String name;
    String email;
    String password;
    String taxNumber;
    bool wholesaler;
    List<ObjectId> favorites;
    List<ObjectId> orderId;
    double balance;
    String address;

    UsersModel({
        required this.id,
        required this.name,
        required this.email,
        required this.password,
        required this.taxNumber,
        required this.wholesaler,
        required this.favorites,
        required this.orderId,
        required this.balance,
        required this.address,
    });

    factory UsersModel.fromJson(Map<String, dynamic> json) => UsersModel(
        id: json["_id"],
        name: json["name"],
        email: json["email"],
        password: json["password"],
        taxNumber: json["taxNumber"],
        wholesaler: json["wholesaler"],
        favorites: List<ObjectId>.from(json["favorites"].map((x) => x)),
        orderId: List<ObjectId>.from(json["orderID"].map((x) => x)),
        balance: (json["balance"]),
        address: json["address"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id.toJson(),
        "name": name,
        "email": email,
        "password": password,
        "taxNumber": taxNumber,
        "wholesaler": wholesaler,
        "favorites": List<dynamic>.from(favorites.map((x) => x)),
        "orderID": List<dynamic>.from(orderId.map((x) => x)),
        "balance": balance,
        "address": address,
    };
}

