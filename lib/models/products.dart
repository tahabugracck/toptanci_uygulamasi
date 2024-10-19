import 'dart:convert';
import 'package:mongo_dart/mongo_dart.dart';

// JSON'dan ProductsModel nesnesi oluşturur
ProductsModel productsModelFromJson(String str) => ProductsModel.fromJson(json.decode(str));

// ProductsModel nesnesini JSON'a dönüştürür
String productsModelToJson(ProductsModel data) => json.encode(data.toJson());

class ProductsModel {
  ObjectId id;
  String title;
  String image;
  ObjectId categoryId;
  ObjectId modelId;
  ObjectId brandId;
  int kdv;
  bool campaign; // Kampanya alanı bool olarak güncellendi
  int minStockLevel;
  double price;
  int stockQuantity;

  ProductsModel({
    required this.id,
    required this.title,
    required this.image,
    required this.categoryId,
    required this.modelId,
    required this.brandId,
    required this.kdv,
    required this.campaign,
    required this.minStockLevel,
    required this.price,
    required this.stockQuantity,
  });

  // JSON'dan ProductsModel nesnesi oluşturur
  factory ProductsModel.fromJson(Map<String, dynamic> json) => ProductsModel(
    id: json["_id"],
    title: json["title"],
    image: json["image"],
    categoryId: json["categoryId"],
    modelId: json["modelId"],
    brandId: json["brandId"],
    kdv: json["kdv"],
    campaign: json["campaign"],
    minStockLevel: json["minStockLevel"],
    price: json["price"],
    stockQuantity: json["stockQuantity"],
  );

  // ProductsModel nesnesini JSON'a dönüştürür
  Map<String, dynamic> toJson() => {
    "_id": id,
    "title": title,
    "image": image,
    "categoryId": categoryId,
    "modelId": modelId,
    "brandId": brandId,
    "kdv": kdv,
    "campaign": campaign,
    "minStockLevel": minStockLevel,
    "price": price,
    "stockQuantity": stockQuantity,
  };

  // copyWith metodu
  ProductsModel copyWith({
    ObjectId? id,
    String? title,
    String? image,
    ObjectId? categoryId,
    ObjectId? modelId,
    ObjectId? brandId,
    int? kdv,
    bool? campaign,
    int? minStockLevel,
    double? price,
    int? stockQuantity,
  }) {
    return ProductsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      image: image ?? this.image,
      categoryId: categoryId ?? this.categoryId,
      modelId: modelId ?? this.modelId,
      brandId: brandId ?? this.brandId,
      kdv: kdv ?? this.kdv,
      campaign: campaign ?? this.campaign,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
    );
  }
}