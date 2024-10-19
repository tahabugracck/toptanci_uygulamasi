// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:toptanci_uygulamasi/models/brands.dart';
import 'package:toptanci_uygulamasi/models/categories.dart';
import 'package:toptanci_uygulamasi/models/models.dart';
import 'package:toptanci_uygulamasi/service/mongodb.dart';
import 'package:toptanci_uygulamasi/models/products.dart';

class ProductDisplayScreen extends StatefulWidget {
  const ProductDisplayScreen({super.key});

  @override
  _ProductDisplayScreenState createState() => _ProductDisplayScreenState();
}

class _ProductDisplayScreenState extends State<ProductDisplayScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Fetch current theme

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ürünler'),
        backgroundColor:
            theme.appBarTheme.backgroundColor, // Use theme's app bar color
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder(
            future: MongoDatabase.getData(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(theme
                        .primaryColor), // Use theme's primary color for loader
                  ),
                );
              } else if (snapshot.hasData) {
                var dataList = snapshot.data as List;
                return ListView.builder(
                  itemCount: dataList.length,
                  itemBuilder: (context, index) {
                    var productData = ProductsModel.fromJson(dataList[index]);
                    return FutureBuilder(
                      future: Future.wait([
                        MongoDatabase.getCategoryById(productData.categoryId),
                        MongoDatabase.getModelById(productData.modelId),
                        MongoDatabase.getBrandById(productData.brandId),
                      ]),
                      builder:
                          (context, AsyncSnapshot<List<Object>?> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(theme
                                  .primaryColor), // Use theme's primary color for loader
                            ),
                          );
                        } else if (snapshot.hasData) {
                          var category = snapshot.data?[0] as CategoriesModel?;
                          var model = snapshot.data?[1] as ModelsModel?;
                          var brand = snapshot.data?[2] as BrandsModel?;
                          return ProductRow(
                            productData: productData,
                            category: category,
                            model: model,
                            brand: brand,
                            onEdit: () {
                              _showEditDialog(context, productData);
                            },
                            onDelete: () {
                              _confirmDelete(context, productData);
                            },
                          );
                        } else {
                          return ProductRow(
                            productData: productData,
                            category: null,
                            model: null,
                            brand: null,
                            onEdit: () {
                              _showEditDialog(context, productData);
                            },
                            onDelete: () {
                              _confirmDelete(context, productData);
                            },
                          );
                        }
                      },
                    );
                  },
                );
              } else {
                return Center(
                  child: Text(
                    "Veri mevcut değil",
                    style: theme
                        .textTheme.bodyMedium, // Use theme's body text style
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  // Ürün düzenleme diyalogu
  void _showEditDialog(BuildContext context, ProductsModel productData) {
    TextEditingController titleController =
        TextEditingController(text: productData.title);
    TextEditingController priceController =
        TextEditingController(text: productData.price.toString());
    TextEditingController imageController =
        TextEditingController(text: productData.image);
    TextEditingController kdvController =
        TextEditingController(text: productData.kdv.toString());
    TextEditingController campaignController =
        TextEditingController(text: productData.campaign.toString());
    TextEditingController minStockLevelController =
        TextEditingController(text: productData.minStockLevel.toString());
    TextEditingController stockQuantityController =
        TextEditingController(text: productData.stockQuantity.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ürün Düzenle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Başlık'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Fiyat'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: kdvController,
                decoration: const InputDecoration(labelText: 'KDV'),
              ),
              TextField(
                controller: campaignController,
                decoration: const InputDecoration(labelText: 'Kampanya'),
              ),
              TextField(
                controller: minStockLevelController,
                decoration:
                    const InputDecoration(labelText: 'Min Stok Seviyesi'),
              ),
              TextField(
                controller: stockQuantityController,
                decoration: const InputDecoration(labelText: 'Stok Miktarı'),
              ),
              TextField(
                controller: imageController,
                decoration: const InputDecoration(labelText: 'Resim'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  // Yeni değerleri güncelleme
                  productData.title = titleController.text;
                  productData.price = double.tryParse(priceController.text) ??
                      productData.price;
                  productData.image = imageController.text;
                  productData.kdv =
                      int.tryParse(kdvController.text) ?? productData.kdv;
                  productData.campaign =
                      campaignController.text.toLowerCase() == 'true';
                  productData.minStockLevel =
                      int.tryParse(minStockLevelController.text) ??
                          productData.minStockLevel;
                  productData.stockQuantity =
                      int.tryParse(stockQuantityController.text) ??
                          productData.stockQuantity;

                  // Veritabanına güncelleme işlemi
                  await MongoDatabase.updateProduct(productData);

                  setState(() {});

                  
                  Navigator.of(context).pop(); // Diyalog kapatılıyor
                } catch (e) {
                  if (kDebugMode) {
                    print("Hata oluştu: $e");
                  }
                }
              },
              child: const Text('Kaydet'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
          ],
        );
      },
    );
  }

  // Silme onayı
  void _confirmDelete(BuildContext context, ProductsModel productData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ürünü Sil'),
          content: Text(
            '"${productData.title}" ürününü silmek istediğinizden emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await MongoDatabase.deleteProduct(productData.id);
                  setState(() {});
                  Navigator.of(context).pop(); // Diyalog kapatılıyor
                } catch (e) {
                  if (kDebugMode) {
                    print("Hata oluştu: $e");
                  }
                }
              },
              child: const Text('Sil'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
          ],
        );
      },
    );
  }
}

class ProductRow extends StatelessWidget {
  final ProductsModel productData;
  final CategoriesModel? category;
  final ModelsModel? model;
  final BrandsModel? brand;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductRow({
    super.key,
    required this.productData,
    this.category,
    this.model,
    this.brand,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(12)),
            child: Image.network(
              productData.image,
              fit: BoxFit.cover,
              width: 100,
              height: 100,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image, size: 100);
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productData.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Fiyat: ${productData.price}",
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "KDV: ${productData.kdv}",
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Kategori: ${category?.name ?? 'Bilgi mevcut değil'}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Ürün Grubu: ${model?.name ?? 'Bilgi mevcut değil'}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Marka: ${brand?.name ?? 'Bilgi mevcut değil'}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Stok Miktarı: ${productData.stockQuantity}",
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Min Stok Seviyesi: ${productData.minStockLevel}",
                    style: const TextStyle(color: Colors.orange),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Kampanya: ${productData.campaign ? 'Kampanya Var' : 'Kampanya Yok'}",
                    style: const TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final ProductsModel productData;
  final Map<String, dynamic>? category;
  final Map<String, dynamic>? model;
  final Map<String, dynamic>? brand;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.productData,
    this.category,
    this.model,
    this.brand,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Açılır modal gösterimi için
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productData.title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Image.network(
                    productData.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, size: 200);
                    },
                  ),
                  const SizedBox(height: 10),
                  Text("Fiyat: ${productData.price}",
                      style: const TextStyle(color: Colors.green)),
                  Text("KDV: ${productData.kdv}"),
                  Text("Stok Miktarı: ${productData.stockQuantity}"),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: onEdit,
                    child: const Text('Düzenle'),
                  ),
                  ElevatedButton(
                    onPressed: onDelete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Sil'),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(12)),
              child: Image.network(
                productData.image,
                fit: BoxFit.cover,
                width: 100, // Resim genişliğini büyüttük
                height: 100, // Resim yüksekliğini ayarladık
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image, size: 100);
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productData.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text("Fiyat: ${productData.price}",
                        style: const TextStyle(color: Colors.green)),
                    Text("KDV: ${productData.kdv}"),
                    Text("Stok Miktarı: ${productData.stockQuantity}"),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
