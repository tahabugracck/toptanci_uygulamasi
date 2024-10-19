import 'package:mongo_dart/mongo_dart.dart';
import 'package:fixnum/fixnum.dart'; // Int64 kullanımı için

class OrdersModel {
  ObjectId id;
  ObjectId customerId;
  DateTime orderDate; // DateTime nesnesi
  String status;
  List<OrderProduct> products; // products dizisi
  ObjectId wholesalerId;

  OrdersModel({
    required this.id,
    required this.customerId,
    required this.orderDate,
    required this.status,
    required this.products,
    required this.wholesalerId,
  });

  // JSON'dan OrdersModel nesnesi oluşturur
  factory OrdersModel.fromJson(Map<String, dynamic> json) {
    return OrdersModel(
      id: json["_id"],
      customerId: json["customerId"],
      orderDate: json['orderDate'],
      status: json["status"],
      products:
          List<OrderProduct>.from(json["products"].map((x) => OrderProduct.fromJson(x))),
      wholesalerId: json["wholesalerId"],
    );
  }

  // OrdersModel nesnesini JSON'a dönüştürür
  Map<String, dynamic> toJson() => {
        "_id": id,
        "customerId": customerId,
        "orderDate": orderDate.toIso8601String(),
        "status": status,
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
        "wholesalerId": wholesalerId,
      };
}

class OrderProduct {
  ObjectId productId;
  double price; // Fiyat
  Int64 quantity; // Stok miktarı

  OrderProduct({
    required this.productId,
    required this.price,
    required this.quantity,
  });

  // JSON'dan Product nesnesi oluşturur
  factory OrderProduct.fromJson(Map<String, dynamic> json) => OrderProduct(
        productId: json["productId"],
        price: (json["price"]), // Int64 ise dönüştür
        quantity: (json["quantity"]), // Int64 ise dönüştür
      );

  // Product nesnesini JSON'a dönüştürür
  Map<String, dynamic> toJson() => {
        "productId": productId,
        "price": price,
        "quantity": quantity,
      };
}
