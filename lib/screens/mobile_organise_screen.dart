// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:toptanci_uygulamasi/service/mongodb.dart';
import 'package:toptanci_uygulamasi/models/mobile_organises.dart';
import 'package:toptanci_uygulamasi/widgets/drawers/theme_notifier.dart';

class MobileOrganisesScreen extends StatefulWidget {
  const MobileOrganisesScreen({super.key});

  @override
  _MobileOrganisesScreenState createState() => _MobileOrganisesScreenState();
}

class _MobileOrganisesScreenState extends State<MobileOrganisesScreen> {
  late Future<List<MobileOrganisesModel>> _mobileOrganisesFuture;

  @override
  void initState() {
    super.initState();
    MongoDatabase.connect();
    _mobileOrganisesFuture = _fetchMobileOrganiseData();
  }

  Future<List<MobileOrganisesModel>> _fetchMobileOrganiseData() async {
    return MongoDatabase.fetchMobileOrganiseData();
  }

  Future<void> _updateMobileOrganise(MobileOrganisesModel updatedItem) async {
    try {
      await MongoDatabase.updateMobileOrganise(updatedItem);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veri güncellendi')),
      );
      setState(() {
        _mobileOrganisesFuture = _fetchMobileOrganiseData();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Güncelleme hatası: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Güncelleme hatası')),
      );
    }
  }

  void _showEditDialog(MobileOrganisesModel item, bool isBanner) {
    final scrollingTextController =
        TextEditingController(text: item.scrollingText);
    final bannerImagesControllers = List<TextEditingController>.generate(
      item.bannerImages.length,
      (index) => TextEditingController(text: item.bannerImages[index]),
    );
    final newImageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(isBanner ? 'Banner Düzenle' : 'Kayan Yazı Düzenle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: isBanner
                ? [
                    ...bannerImagesControllers.map((controller) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Banner Image URL',
                            ),
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextField(
                        controller: newImageController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Yeni Banner Image URL',
                        ),
                      ),
                    ),
                  ]
                : [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextField(
                        controller: scrollingTextController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Kayan Yazı',
                        ),
                      ),
                    ),
                  ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                final updatedItem = MobileOrganisesModel(
                  id: item.id,
                  bannerImages: isBanner
                      ? [
                          ...bannerImagesControllers.map((c) => c.text),
                          newImageController.text
                        ]
                      : item.bannerImages,
                  scrollingText: isBanner
                      ? item.scrollingText
                      : scrollingTextController.text,
                );
                _updateMobileOrganise(updatedItem);
                Navigator.of(context).pop();
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  void _showImageEditDialog(MobileOrganisesModel item, int index) {
    final imageUrlController =
        TextEditingController(text: item.bannerImages[index]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Text('Resim URL Düzenle'),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              controller: imageUrlController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Resim URL',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                final updatedItem = MobileOrganisesModel(
                  id: item.id,
                  bannerImages: List.from(item.bannerImages)
                    ..[index] = imageUrlController.text,
                  scrollingText: item.scrollingText,
                );
                _updateMobileOrganise(updatedItem);
                Navigator.of(context).pop();
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Mobile Organises'),
            backgroundColor:
                themeNotifier.currentTheme.appBarTheme.backgroundColor,
            actions: const [],
          ),
          body: FutureBuilder<List<MobileOrganisesModel>>(
            future: _mobileOrganisesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Hata: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Veri bulunamadı'));
              } else {
                final mobileOrganises = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: mobileOrganises.length,
                  itemBuilder: (context, index) {
                    final item = mobileOrganises[index];

                    return Card(
                      color: themeNotifier.currentTheme.cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 5.0,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            title: Text(
                              'Kayan Yazı: ${item.scrollingText}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                                color: themeNotifier
                                    .currentTheme.textTheme.bodyLarge!.color,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditDialog(item, false),
                            ),
                          ),
                          if (item.bannerImages.isNotEmpty)
                            Divider(height: 1.0, color: Colors.grey[300]),
                          if (item.bannerImages.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              height: 450,
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8.0,
                                  mainAxisSpacing: 8.0,
                                ),
                                itemCount: item.bannerImages.length,
                                itemBuilder: (context, imageIndex) {
                                  return GestureDetector(
                                    onTap: () =>
                                        _showImageEditDialog(item, imageIndex),
                                    child: Stack(
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl:
                                              item.bannerImages[imageIndex],
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.red),
                                                onPressed: () {
                                                  final updatedItem =
                                                      MobileOrganisesModel(
                                                    id: item.id,
                                                    bannerImages: List.from(
                                                        item.bannerImages)
                                                      ..removeAt(imageIndex),
                                                    scrollingText:
                                                        item.scrollingText,
                                                  );
                                                  _updateMobileOrganise(
                                                      updatedItem);
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.edit),
                                                onPressed: () =>
                                                    _showImageEditDialog(
                                                        item, imageIndex),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          if (item.bannerImages.isEmpty)
                            ListTile(
                              title: ElevatedButton(
                                onPressed: () => _showEditDialog(item, false),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: themeNotifier
                                          .currentTheme
                                          .elevatedButtonTheme
                                          .style
                                          ?.backgroundColor
                                          ?.resolve({}) ??
                                      themeNotifier.currentTheme.colorScheme
                                          .primary, // Temadan gelen renk
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: const Text('Kayan Yazı Ekle',
                                    style: TextStyle(color: Colors.black)),
                              ),
                            ),
                          ListTile(
                            title: ElevatedButton(
                              onPressed: () => _showEditDialog(item, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeNotifier
                                        .currentTheme
                                        .elevatedButtonTheme
                                        .style
                                        ?.backgroundColor
                                        ?.resolve({}) ??
                                    themeNotifier.currentTheme.colorScheme
                                        .primary, // Temadan gelen renk
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text('Resim Ekle',
                                  style: TextStyle(color: Colors.black)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            },
          ),
        );
      },
    );
  }
}
