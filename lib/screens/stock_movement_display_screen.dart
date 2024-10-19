import 'package:flutter/material.dart';
import 'package:toptanci_uygulamasi/service/mongodb.dart';
import 'package:toptanci_uygulamasi/models/products.dart';

class StockMovementDisplayScreen extends StatefulWidget {
  const StockMovementDisplayScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StockMovementDisplayScreenState createState() => _StockMovementDisplayScreenState();
}

class _StockMovementDisplayScreenState extends State<StockMovementDisplayScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ürünler'),
        backgroundColor: const Color(0xFFFF6F61),
        // IconButton kaldırıldı
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: FutureBuilder(
            future: MongoDatabase.getData(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                if (snapshot.hasData) {
                  var dataList = snapshot.data as List;
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // Ürünlerin 3 sütunlu düzenini sağlar
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 12.0,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: dataList.length,
                    itemBuilder: (context, index) {
                      var productData = ProductsModel.fromJson(dataList[index]);
                      return FutureBuilder(
                        future: Future.wait([
                          MongoDatabase.getCategoryById(productData.categoryId),
                          MongoDatabase.getModelById(productData.modelId),
                          MongoDatabase.getBrandById(productData.brandId),
                        ]),
                        builder: (context, AsyncSnapshot<List<Object>?>
                            snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else {
                            if (snapshot.hasData) {
                              var category = snapshot.data?[0] as Map<String, dynamic>?;
                              var model = snapshot.data?[1] as Map<String, dynamic>?;
                              var brand = snapshot.data?[2] as Map<String, dynamic>?;
                              return ProductCard(
                                productData: productData,
                                category: category,
                                model: model,
                                brand: brand,
                              );
                            } else {
                              return ProductCard(
                                productData: productData,
                                category: null,
                                model: null,
                                brand: null,
                              );
                            }
                          }
                        },
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text("Veri mevcut değil"),
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final ProductsModel productData;
  final Map<String, dynamic>? category;
  final Map<String, dynamic>? model;
  final Map<String, dynamic>? brand;

  const ProductCard({
    super.key,
    required this.productData,
    this.category,
    this.model,
    this.brand,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              productData.image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Text('Resim yüklenirken hata oluştu'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Başlık: ${productData.title}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "Kategori: ${category?['name'] ?? 'Bilgi mevcut değil'}",
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "Model: ${model?['name'] ?? 'Bilgi mevcut değil'}",
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "Marka: ${brand?['name'] ?? 'Bilgi mevcut değil'}",
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "KDV: ${productData.kdv}",
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Kampanya: ${productData.campaign}",
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Min Stok Seviyesi: ${productData.minStockLevel}",
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Fiyat: ${productData.price}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Stok Miktarı: ${productData.stockQuantity}",
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
