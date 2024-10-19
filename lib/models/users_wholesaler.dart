import 'dart:convert';
import 'package:mongo_dart/mongo_dart.dart';

UsersWholesalerModel usersWholesalerModelFromJson(String str) => UsersWholesalerModel.fromJson(json.decode(str));

String usersWholesalerModelToJson(UsersWholesalerModel data) => json.encode(data.toJson());

class UsersWholesalerModel {
  ObjectId id;
  String name;
  String email;
  String password;
  String taxNumber;
  bool wholesaler;
  List<Employee> employee;
  List<ObjectId> orderId;
  List<Card> card;
  List<Cash> cash;
  String address;

  UsersWholesalerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.taxNumber,
    required this.wholesaler,
    required this.employee,
    required this.orderId,
    required this.card,
    required this.cash,
    required this.address,
  });

  factory UsersWholesalerModel.fromJson(Map<String, dynamic> json) => UsersWholesalerModel(
    id: json["_id"],
    name: json["name"],
    email: json["email"],
    password: json["password"],
    taxNumber: json["taxNumber"],
    wholesaler: json["wholesaler"],
    employee: List<Employee>.from(json["employee"].map((x) => Employee.fromJson(x))),
    orderId: List<ObjectId>.from(json["orderID"].map((x) => x)),
    card: List<Card>.from(json["card"].map((x) => Card.fromJson(x))),
    cash: List<Cash>.from(json["cash"].map((x) => Cash.fromJson(x))),
    address: json["address"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "email": email,
    "password": password,
    "taxNumber": taxNumber,
    "wholesaler": wholesaler,
    "employee": List<dynamic>.from(employee.map((x) => x.toJson())),
    "orderID": List<dynamic>.from(orderId.map((x) => x)),
    "card": List<dynamic>.from(card.map((x) => x.toJson())),
    "cash": List<dynamic>.from(cash.map((x) => x.toJson())),
    "address": address,
  };
}

class Card {
  final String toFrom;
  final bool incoming;
  final double amount; // Düz bir int olarak
  final DateTime transactionDate; // DateTime olarak
  final String description;
  final ObjectId id;

  Card({
    required this.toFrom,
    required this.incoming,
    required this.amount,
    required this.transactionDate,
    required this.description,
    required this.id,
  });

  factory Card.fromJson(Map<String, dynamic> json) => Card(
        toFrom: json['to_from'],
        incoming: json['incoming'],
        amount: json['amount'], // Düz bir int olarak
        transactionDate: json['transactionDate'], // Tarih formatını düzelt
        description: json['description'],
        id: json['_id'],
      );

  Map<String, dynamic> toJson() => {
        'to_from': toFrom,
        'incoming': incoming,
        'amount': amount, // Düz bir int olarak
        'transactionDate':  transactionDate.toIso8601String(), // Tarih formatını düzelt
        'description': description,
        '_id': id,
      };
}

class Cash {
  final String toFrom;
  final bool incoming;
  final double amount; // Düz bir int olarak
  final DateTime transactionDate; // DateTime olarak
  final String description;
  final ObjectId id;

  Cash({
    required this.toFrom,
    required this.incoming,
    required this.amount,
    required this.transactionDate,
    required this.description,
    required this.id,
  });

  factory Cash.fromJson(Map<String, dynamic> json) => Cash(
        toFrom: json['to_from'],
        incoming: json['incoming'],
        amount: json['amount'], // Düz bir int olarak
        transactionDate: json['transactionDate'], // Tarih formatını düzelt
        description: json['description'],
        id: json['_id'],
      );

  Map<String, dynamic> toJson() => {
        'to_from': toFrom,
        'incoming': incoming,
        'amount': amount, // Düz bir int olarak
        'transactionDate': transactionDate.toIso8601String(), // Tarih formatını düzelt
        'description': description,
        '_id': id,
      };
}


class Employee {
  String name;
  String password;
  dynamic admin;
  ObjectId id;

  Employee({
    required this.name,
    required this.password,
    required this.admin,
    required this.id,
  });

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
    name: json["name"],
    password: json["password"],
    admin: json["admin"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "password": password,
    "admin": admin,
    "_id": id,
  };
}

