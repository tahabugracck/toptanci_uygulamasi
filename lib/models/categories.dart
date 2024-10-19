import 'package:mongo_dart/mongo_dart.dart';

class CategoriesModel {
    ObjectId id;
    String name;
    List<ObjectId> modelIds;
    String image;

    CategoriesModel({
        required this.id,
        required this.name,
        required this.modelIds, 
        required this.image,
    });

    factory CategoriesModel.fromJson(Map<String, dynamic> json) => CategoriesModel(
        id: json["_id"],
        name: json["name"],
        modelIds: List<ObjectId>.from(json["modelIds"].map((x) =>x)),
        image: json["image"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "modelIds": List<dynamic>.from(modelIds.map((x) => x.toJson())),
        "image": image,
    };
}
