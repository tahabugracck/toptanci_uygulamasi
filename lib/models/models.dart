import 'package:mongo_dart/mongo_dart.dart';

class ModelsModel {
  ObjectId id;
  String name;
  List<ObjectId> brandIds;

  ModelsModel({
    required this.id,
    required this.name,
    required this.brandIds,
  });

  factory ModelsModel.fromJson(Map<String, dynamic> json) => ModelsModel(
    id: json["_id"], 
    name: json["name"],
    brandIds: List<ObjectId>.from(json["brandIds"].map((x) =>x)),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "brandIds": List<dynamic>.from(brandIds.map((x) => x.toJson())),
  };
}