import 'package:mongo_dart/mongo_dart.dart';

class BrandsModel {
  ObjectId id;
  String name;
  List<ObjectId> productIds;

  BrandsModel({
    required this.id,
    required this.name,
    required this.productIds,
  });

  factory BrandsModel.fromJson(Map<String, dynamic> json) {
    return BrandsModel(
      id: json["_id"],
      name: json["name"],
      productIds: List<ObjectId>.from(json["productIds"].map((x) => x)) 
    );
  }
  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "productIds": List<dynamic>.from(productIds.map((x) => x.toJson())),
      };
}