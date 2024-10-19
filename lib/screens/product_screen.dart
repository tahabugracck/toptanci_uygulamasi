// ignore_for_file: unnecessary_null_comparison, library_private_types_in_public_api, use_build_context_synchronously

import 'package:bson/bson.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toptanci_uygulamasi/service/mongodb.dart';
import '../widgets/drawers/theme_notifier.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController kdvController = TextEditingController();
  final TextEditingController campaignController = TextEditingController();
  final TextEditingController minStockController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockQuantityController = TextEditingController();

  String? selectedCategory;
  String? selectedModel;
  String? selectedBrand;

  bool isCampaign = false; // Kampanya durumu için bool değişkeni

  List<Map<String, String>> categories = [];
  List<Map<String, String>> models = [];
  List<Map<String, String>> brands = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categoriesData = await MongoDatabase.categoriesCollection.find().toList();
      setState(() {
        categories = categoriesData
            .map((e) => {
                  'id': e['_id'].toString(),
                  'name': e['name'].toString(),
                })
            .toList();
        selectedCategory = null;
        selectedBrand = null;
        selectedModel = null;
        brands = [];
        models = [];
      });
    } catch (e) {
      if (kDebugMode) {
        print('Kategoriler yüklenirken hata oluştu: $e');
      }
    }
  }

  Future<void> _loadModels(ObjectId categoryId) async {
    try {
      final categoryData = await MongoDatabase.getCategoryById(categoryId);

      if (categoryData == null || categoryData.modelIds.isEmpty) {
        if (kDebugMode) {
          print('Bu kategoriye ait model yok.');
        }
        return; // Kategoriye ait model yoksa çık
      }

      // Model ID'lerini al
      final modelIds = categoryData.modelIds.map((id) => id).toList();

      // Model ID'lerini ObjectId'ye çevir
      final objectIds = modelIds.map((id) => id).toList();

      // ObjectId'leri kullanarak modelleri bul
      final modelsData = await Future.wait(
          objectIds.map((id) => MongoDatabase.getModelById(id)).toList());

      // Null olanları filtrele
      modelsData.removeWhere((model) => model == null);

      setState(() {
        models = modelsData
            .map((e) => {
                  'id': e.id.toString(),
                  'name': e.name.toString(),
                })
            .toList();
        selectedModel = null; // Model seçimini sıfırla
        brands = []; // Markaları sıfırla
        selectedBrand = null; // Marka seçimini sıfırla
      });
    } catch (e) {
      if (kDebugMode) {
        print('Modeller yüklenirken hata oluştu: $e');
      }
    }
  }

  Future<void> _loadBrands(ObjectId modelId) async {
    try {
      final modelData = await MongoDatabase.getModelById(modelId);

      if (modelData == null || modelData.brandIds.isEmpty) {
        if (kDebugMode) {
          print('Bu modele ait marka yok.');
        }
        return; // Model verisi yoksa çık
      }

      // Marka ID'lerini al
      final brandIds = modelData.brandIds.map((id) => id).toList();

      // Brand ID'lerini ObjectId'ye çevir
      final objectIds = brandIds.map((id) => id).toList();

      // ObjectId'leri kullanarak markaları bul
      final brandsData = await Future.wait(
          objectIds.map((id) => MongoDatabase.getBrandById(id)).toList());

      // Null olanları filtrele
      brandsData.removeWhere((brand) => brand == null);

      setState(() {
        brands = brandsData
            .map((e) => {
                  'id': e.id.toString(),
                  'name': e.name.toString(),
                })
            .toList();
        selectedBrand = null; // Marka seçimini sıfırla
      });
    } catch (e) {
      if (kDebugMode) {
        print('Markalar yüklenirken hata oluştu: $e');
      }
    }
  }

  @override
Widget build(BuildContext context) {
  final themeNotifier = Provider.of<ThemeNotifier>(context);
  final theme = themeNotifier.currentTheme;

  return Scaffold(
    appBar: AppBar(
      title: const Text('Ürün Ekle'),
      backgroundColor: theme.appBarTheme.backgroundColor,
      foregroundColor: theme.appBarTheme.foregroundColor,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              "Ürün Bilgilerini Girin",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildDropdownButton(
              'Kategori',
              categories.map((e) => e['name']!).toList(),
              selectedCategory,
              (value) {
                if (value != null) {
                  setState(() {
                    selectedCategory = value;
                    final categoryId = categories
                        .firstWhere((c) => c['name'] == value)['id']
                        .toString()
                        .replaceAll('ObjectId("', '')
                        .replaceAll('")', '');
                    _loadModels(ObjectId.fromHexString(categoryId));
                  });
                }
              },
            ),
            _buildDropdownButton(
              'Model',
              models.map((e) => e['name']!).toList(),
              selectedModel,
              (value) {
                if (value != null) {
                  setState(() {
                    selectedModel = value;
                    final modelId = models
                        .firstWhere((m) => m['name'] == value)['id']
                        .toString()
                        .replaceAll('ObjectId("', '')
                        .replaceAll('")', '');
                    _loadBrands(ObjectId.fromHexString(modelId));
                  });
                }
              },
            ),
            _buildDropdownButton(
              'Marka',
              brands.map((e) => e['name']!).toList(),
              selectedBrand,
              (value) {
                setState(() {
                  selectedBrand = value;
                });
              },
            ),
            _buildTextField(titleController, "Başlık"),
            _buildTextField(imageController, "Fotoğraf URL"),
            _buildTextField(kdvController, "KDV"),
            // Kampanya durumu için DropdownButton ekleniyor
            _buildDropdownButton(
              'Kampanya',
              ['Kampanya Var', 'Kampanya Yok'],
              isCampaign ? 'Kampanya Var' : 'Kampanya Yok',
              (value) {
                setState(() {
                  isCampaign = value == 'Kampanya Var';
                });
              },
            ),
            _buildTextField(minStockController, "Minimum Stok"),
            _buildTextField(priceController, "Fiyat"),
            _buildTextField(stockQuantityController, "Stok Miktarı"),
            const SizedBox(height: 20),
            ElevatedButton(
  onPressed: _insertData,
  style: ElevatedButton.styleFrom(
    backgroundColor: theme.buttonTheme.colorScheme?.onSecondary,
  ),
  child: const Text("Ürün Ekle"),  // "Ürün Ekle" yazısını ekliyoruz
),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildDropdownButton(String label, List<String> items,
    String? selectedValue, ValueChanged<String?> onChanged) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: DropdownButtonFormField<String>(
      value: items.isEmpty ? null : selectedValue,
      hint: Text(label),
      items: items.isEmpty
          ? [DropdownMenuItem(value: null, child: Text(label))]
          : items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),
    ),
  );
}

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        ),
      ),
    );
  }

  Future<void> _insertData() async {
    try {
      if (selectedModel == null) {
        throw Exception('Lütfen bir model seçin.');
      }

      // Modeller listesinin boş olup olmadığını kontrol edelim
      if (models.isEmpty) {
        throw Exception('Model listesi boş.');
      }

      // Seçilen modeli almak için
      final selectedModelId = models
          .firstWhere((m) => m['name'] == selectedModel)['id']
          .toString()
          .replaceAll('ObjectId("', '')
          .replaceAll('")', '');

      // Seçilen marka id'si
      final selectedBrandId = brands
          .firstWhere((b) => b['name'] == selectedBrand)['id']
          .toString()
          .replaceAll('ObjectId("', '')
          .replaceAll('")', '');

      // Seçilen kategori id'si
      final selectedCategoryId = categories
          .firstWhere((c) => c['name'] == selectedCategory)['id']
          .toString()
          .replaceAll('ObjectId("', '')
          .replaceAll('")', '');

      // Kampanya bilgisini boolean olarak kaydet
      await MongoDatabase.productsCollection.insertOne({
        'title': titleController.text,
        'categoryId': ObjectId.fromHexString(selectedCategoryId), // Kategori ID'sini ekle
        'modelId': ObjectId.fromHexString(selectedModelId),
        'brandId': ObjectId.fromHexString(selectedBrandId),
        'image': imageController.text,
        'kdv':  int.parse(kdvController.text),
        'campaign': isCampaign, // Boolean olarak kaydet
        'minStockLevel': int.parse(minStockController.text),
        'price': double.parse(priceController.text),
        'stockQuantity': int.parse(stockQuantityController.text),
      });

      // Formu sıfırlamak için
      _clearAll();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veri başarıyla eklendi!')),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Veri eklenirken hata oluştu: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  void _clearAll() {
    titleController.clear();
    imageController.clear();
    kdvController.clear();
    minStockController.clear();
    priceController.clear();
    stockQuantityController.clear();
    setState(() {
      selectedCategory = null;
      selectedModel = null;
      selectedBrand = null;
      models = [];
      brands = [];
      isCampaign = false; // Kampanya durumu sıfırla
    });
  }
}