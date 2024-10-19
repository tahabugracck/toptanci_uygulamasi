// To parse this JSON data, do
//
//     final mobileOrganisesModel = mobileOrganisesModelFromJson(jsonString);

import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

MobileOrganisesModel mobileOrganisesModelFromJson(String str) => MobileOrganisesModel.fromJson(json.decode(str));

String mobileOrganisesModelToJson(MobileOrganisesModel data) => json.encode(data.toJson());

class MobileOrganisesModel {
    ObjectId id;
    List<String> bannerImages;
    String scrollingText;

    MobileOrganisesModel({
        required this.id,
        required this.bannerImages,
        required this.scrollingText,
    });

    factory MobileOrganisesModel.fromJson(Map<String, dynamic> json) => MobileOrganisesModel(
        id: json["_id"],
        bannerImages: List<String>.from(json["bannerImages"].map((x) => x)),
        scrollingText: json["scrollingText"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id.toJson(),
        "bannerImages": List<dynamic>.from(bannerImages.map((x) => x)),
        "scrollingText": scrollingText,
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
