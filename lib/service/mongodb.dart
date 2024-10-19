// ignore_for_file: unnecessary_brace_in_string_interps


import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:toptanci_uygulamasi/models/brands.dart';
import 'package:toptanci_uygulamasi/models/categories.dart';
import 'package:toptanci_uygulamasi/models/models.dart';
import 'package:toptanci_uygulamasi/models/orders.dart';
import 'package:toptanci_uygulamasi/service/constant.dart';
import 'package:toptanci_uygulamasi/models/products.dart';
import 'package:toptanci_uygulamasi/models/mobile_organises.dart';
import 'package:logging/logging.dart';
import 'package:toptanci_uygulamasi/models/users.dart';
import 'package:toptanci_uygulamasi/models/users_wholesaler.dart' as wholesaler;

class MongoDatabase {
  static late Db db;
  static late DbCollection brandsCollection;
  static late DbCollection productsCollection;
  static late DbCollection categoriesCollection;
  static late DbCollection modelsCollection;
  static late DbCollection usersCollection;
  static late DbCollection stockMovementCollection;
  static late DbCollection mobileOrganiseCollection;
  static late DbCollection ordersCollection;

  static final Logger _logger = Logger('MongoDatabase');

  // MongoDB bağlantısını başlatır
  static Future<void> connect() async {
    try {
      db = await Db.create(MONGO_CONN_URL);
      await db.open();
      _initializeCollections();

      if (kDebugMode) {
        _logger.info("MongoDB bağlantısı sağlandı ");
        print("MongoDB bağlantısı sağlandı");
      }
    } catch (e) {
      _logger.severe("MongoDB bağlantısı sağlanamadı: $e");
      if (kDebugMode) {
        print("MongoDB bağlantısı sağlanamadı: $e");
      }
    }
  }

  // Koleksiyonları başlatır
  static void _initializeCollections() {
    brandsCollection = db.collection(BRANDS_COLLECTION);
    productsCollection = db.collection(PRODUCTS_COLLECTION);
    categoriesCollection = db.collection(CATEGORIES_COLLECTION);
    modelsCollection = db.collection(MODELS_COLLECTION);
    usersCollection = db.collection(USERS_COLLECTION);
    stockMovementCollection = db.collection(STOCK_MOVEMENT_COLLECTION);
    mobileOrganiseCollection = db.collection(MOBILE_ORGANISES_COLLECTION);
    ordersCollection = db.collection(ORDERS_COLLECTION);
  }

  // Veritabanı bağlantısını kapatır
  static Future<void> close() async {
    try {
      await db.close();
      if (kDebugMode) {
        _logger.info("MongoDB bağlantısı kapatıldı");
      }
    } catch (e) {
      _logger.severe("MongoDB bağlantısını kapatırken hata oluştu: $e");
    }
  }

// Siparişleri listeleyen fonksiyon
  static Future<List<OrdersModel>> getOrders() async {
    try {
      final orders =
          await ordersCollection.find().toList(); // Tüm siparişleri çekiyoruz

      List<OrdersModel> orderList = orders
          .map((order) => OrdersModel.fromJson(order))
          .toList(); // JSON'dan OrdersModel'e dönüştürüyoruz

      return orderList;
    } catch (e) {
      if (kDebugMode) {
        print('Siparişleri listeleme hatası: $e');
      }
      return [];
    }
  }

  Future<UsersModel?> getCustomerById(ObjectId customerId) async {
    final json = await usersCollection.findOne(where.id(customerId));
    return json != null ? UsersModel.fromJson(json) : null;
  }

  Future<wholesaler.UsersWholesalerModel?> getWholesalerById(ObjectId wholesalerId) async {
    final json = await usersCollection.findOne(where.id(wholesalerId));
    return json != null ? wholesaler.UsersWholesalerModel.fromJson(json) : null;
  }

// Kart hareketini eklemek için metod
  static Future<void> addCardMovement(
      String userId, Map<String, dynamic> data) async {
    try {
      var collection = db.collection('users'); // users koleksiyonuna erişim
      var result = await collection.updateOne(
        where.eq(
            '_id',
            ObjectId.fromHexString(
                userId)), // Kullanıcı kimliğine göre kullanıcı bulunuyor.
        modify.push('card', {
          // 'card' alt objesine veri push ediliyor
          'to_from': data['to_from'], // Gönderen/Alıcı bilgisi
          'amount': data['amount'], // İşlem tutarı
          'transactionDate': DateTime.parse(data[
              'transactionDate']), // Tarih bilgisi doğru formatta gönderiliyor
          'description': data['description'], // İşlem açıklaması
          '_id': ObjectId(), // Her işlem için benzersiz bir ObjectId ekleniyor.
          'incoming': data['incoming'], // Gelir/gider olduğunu belirtiyor
        }),
      );

      if (result.isSuccess) {
        if (kDebugMode) {
          print('Kart hareketi başarıyla eklendi: $data');
        }
      } else {
        if (kDebugMode) {
          print('Kart hareketi eklenemedi: ${result.writeError}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Veritabanına eklerken hata: $e');
      }
    }
  }

// Nakit hareketini eklemek için metod
  static Future<void> addCashMovement(
      String userId, Map<String, dynamic> movement) async {
    try {
      var collection = db.collection('users'); // 'users' koleksiyonuna erişim
      var result = await collection.updateOne(
        where.eq(
            '_id',
            ObjectId.fromHexString(
                userId)), // Kullanıcı kimliğine göre kullanıcı bulunuyor.
        modify.push('cash', {
          // 'cash' alt objesine veri push ediliyor
          'to_from': movement['to_from'], // Gönderen/Alıcı bilgisi
          'amount': movement['amount'], // İşlem tutarı
          'transactionDate': DateTime.parse(movement['transactionDate'])
              .toIso8601String(), // Tarih bilgisi
          'description': movement['description'], // İşlem açıklaması
          '_id': ObjectId()
              // ignore: deprecated_member_use
              .toHexString(), // Her işlem için benzersiz bir ObjectId ekleniyor
          'incoming': movement['incoming'], // Gelir/gider olduğunu belirtiyor
        }),
      );

      if (result.isSuccess) {
        _logger.info(
            'Nakit hareketi başarıyla eklendi: $movement'); // Başarı mesajı loglanıyor.
      } else {
        _logger.severe(
            'Nakit hareketi eklenemedi: ${result.writeError}'); // Başarısızlık durumu loglanıyor.
      }
    } catch (e) {
      // Hata durumunda
      _logger.severe(
          'Nakit hareketi eklenirken hata oluştu: $e'); // Hata mesajı loglanıyor.
    }
  }

// Kart gelir hareketlerini çeken metod
  static Future<List<Map<String, dynamic>>> getCardsIncomeMovements() async {
    try {
      final movements =
          await usersCollection.find({'card.incoming': true}).toList();

      return movements
          .expand((user) => user['card'] as List<dynamic>)
          .where((card) => card['incoming'] == true)
          .map((card) {
        return {
          "description": card["description"] ?? "Açıklama Yok",
          "date": card["transactionDate"] ?? "Tarih Yok",
          "amount": card["amount"]?.toString() ?? "0",
          "to_from":
              card["to_from"] ?? "Gönderen Bilgisi Yok", // Gönderen bilgisi
        };
      }).toList();
    } catch (e) {
      _logger.severe('Kart gelir hareketlerini çekerken hata oluştu: $e');
      return [];
    }
  }

// Kart gider hareketlerini çeken metod
  static Future<List<Map<String, dynamic>>> getCardsExpenseMovements() async {
    try {
      final movements =
          await usersCollection.find({'card.incoming': false}).toList();

      return movements
          .expand((user) => user['card'] as List<dynamic>)
          .where((card) => card['incoming'] == false)
          .map((card) {
        return {
          "description": card["description"] ?? "Açıklama Yok",
          "date": card["transactionDate"] ?? "Tarih Yok",
          "amount": card["amount"]?.toString() ?? "0",
          "to_from":
              card["to_from"] ?? "Gönderen Bilgisi Yok", // Gönderen bilgisi
        };
      }).toList();
    } catch (e) {
      _logger.severe('Kart gider hareketlerini çekerken hata oluştu: $e');
      return [];
    }
  }

// Nakit gelir hareketlerini çeken metod
  static Future<List<Map<String, dynamic>>> getCashIncomeMovements() async {
    try {
      final movements =
          await usersCollection.find({'cash.incoming': true}).toList();

      return movements
          .expand((user) => user['cash'] as List<dynamic>)
          .where((cash) => cash['incoming'] == true)
          .map((cash) {
        return {
          "description": cash["description"] ?? "Açıklama Yok",
          "date": cash["transactionDate"] ?? "Tarih Yok",
          "amount": cash["amount"]?.toString() ?? "0",
          "to_from":
              cash["to_from"] ?? "Gönderen Bilgisi Yok", // Gönderen bilgisi
        };
      }).toList();
    } catch (e) {
      _logger.severe('Nakit gelir hareketlerini çekerken hata oluştu: $e');
      return [];
    }
  }

// Nakit gider hareketlerini çeken metod
  static Future<List<Map<String, dynamic>>> getCashExpenseMovements() async {
    try {
      final movements =
          await usersCollection.find({'cash.incoming': false}).toList();

      return movements
          .expand((user) => user['cash'] as List<dynamic>)
          .where((cash) => cash['incoming'] == false)
          .map((cash) {
        return {
          "description": cash["description"] ?? "Açıklama Yok",
          "date": cash["transactionDate"] ?? "Tarih Yok",
          "amount": cash["amount"]?.toString() ?? "0",
          "to_from":
              cash["to_from"] ?? "Gönderen Bilgisi Yok", // Gönderen bilgisi
        };
      }).toList();
    } catch (e) {
      _logger.severe('Nakit gider hareketlerini çekerken hata oluştu: $e');
      return [];
    }
  }

// Ürünleri veritabanından getiren metod
  static Future<List<Map<String, dynamic>>> getData() async {
    try {
      final arrData = await productsCollection.find().toList();
      return arrData;
    } catch (e) {
      _logger.severe('Ürünleri alırken hata oluştu: $e');
      return [];
    }
  }

  // Ürün silme metodu
  static Future<void> deleteProduct(ObjectId id) async {
    try {
      final result = await productsCollection.deleteOne(where.eq('_id', id));
      if (result.ok == 0) {
        _logger.warning("Silinecek ürün bulunamadı: $id");
      } else {
        _logger.info("Ürün başarıyla silindi: $id");
      }
    } catch (e) {
      _logger.severe('Ürün silme hatası: $e');
    }
  }

// Ürün güncelleme metodu
  static Future<void> updateProduct(ProductsModel product) async {
    try {
      await productsCollection.updateOne(
        where.eq('_id', product.id),
        modify
            .set('title', product.title)
            .set('price', product.price)
            .set('image', product.image)
            .set('kdv', product.kdv)
            .set('campaign', product.campaign)
            .set('min stok', product.minStockLevel)
            .set('stok quantity', product.stockQuantity),
      );
      _logger.info("Ürün bilgileri güncellendi: ${product.title}");
    } catch (e) {
      _logger.severe('Ürün güncelleme hatası: $e');
    }
  }

// Kategori ID'sine göre kategori bilgisini getiren metod
  static Future<CategoriesModel> getCategoryById(ObjectId categoryId) async {
    var categoryJson = await categoriesCollection.findOne(where.id(categoryId));
    if (categoryJson == null) {
      _logger.warning('Kategori bulunamadı: $categoryId');
    }
    var category = CategoriesModel.fromJson(categoryJson!);
    return category;
  }

// Model ID'sine göre model bilgisini getiren metod
  static Future<ModelsModel> getModelById(ObjectId modelId) async {
    var modeljson = await modelsCollection.findOne(where.id(modelId));
    if (modeljson == null) {
      _logger.warning('Model bulunamadı: $modelId');
    }
    var model = ModelsModel.fromJson(modeljson!);
    return model;
  }

// Marka ID'sine göre marka bilgisini getiren metod
  static Future<BrandsModel> getBrandById(ObjectId brandId) async {
    var brandJson = await brandsCollection.findOne(where.id(brandId));

    if (brandJson == null) {
      _logger.warning('Marka bulunamadı: $brandId');
    }

    var brand = BrandsModel.fromJson(brandJson!);
    return brand;
  }

// Ürünleri veritabanından getiren metod
  Future<Map<OrderProduct, ProductsModel>> getProductsWithOrder(
      OrdersModel order) async {
    Map<OrderProduct, ProductsModel> ordersProducts = {};

    for (OrderProduct product in order.products) {
      final orderProductData =
          await productsCollection.findOne(where.id(product.productId));

      if (orderProductData != null) {
        // Eğer dönen veri Map formatındaysa, ProductsModel'e dönüştür
        final orderProduct = ProductsModel.fromJson(orderProductData);
        ordersProducts[product] = orderProduct;
      } else {
        if (kDebugMode) {
          print('Ürün bulunamadı: ${product.productId}');
        }
      }
    }

    return ordersProducts;
  }

// MobileOrganise koleksiyonundan veri çeken metod
  static Future<List<MobileOrganisesModel>> fetchMobileOrganiseData() async {
    try {
      final data = await mobileOrganiseCollection.find().toList();
      return data.map((doc) => MobileOrganisesModel.fromJson(doc)).toList();
    } catch (e) {
      _logger.severe("MobileOrganise verilerini çekerken hata oluştu: $e");
      return [];
    }
  }

// MobileOrganise verisini güncelleyen metod
  static Future<void> updateMobileOrganise(
      MobileOrganisesModel updatedItem) async {
    try {
      await mobileOrganiseCollection.updateOne(
        where.eq('_id', updatedItem.id),
        modify
            .set('bannerImages', updatedItem.bannerImages)
            .set('scrollingText', updatedItem.scrollingText),
      );
      _logger.info("MobileOrganise verisi güncellendi: ${updatedItem.id}");
    } catch (e) {
      _logger.severe('MobileOrganise güncelleme hatası: $e');
    }
  }

  // Kullanıcı adı ile kullanıcıyı veritabanında arayan metod
 static Future<Map<String, dynamic>?> fetchUserByUsername(String email) async {
    try {
        final user = await usersCollection.findOne(where.eq('email', email));
        return user;
    } catch (e) {
        _logger.severe('Kullanıcı aranırken hata oluştu: $e');
        if (kDebugMode) {
            print('Kullanıcı aranırken hata oluştu: $e');
        }
    }
    return null;
}




}
