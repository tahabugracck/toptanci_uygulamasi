// ignore_for_file: deprecated_member_use, library_prefixes, library_private_types_in_public_api, avoid_print, prefer_const_constructors, unnecessary_to_list_in_spreads, use_build_context_synchronously, unused_element

import 'package:bson/bson.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toptanci_uygulamasi/models/users.dart';
import 'package:toptanci_uygulamasi/service/mongodb.dart';
import 'package:toptanci_uygulamasi/models/orders.dart';
import 'package:toptanci_uygulamasi/models/products.dart';
import 'package:toptanci_uygulamasi/models/users_wholesaler.dart'
    as wholesalerModel;

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late MongoDatabase mongoService; // MongoDB servisi
  List<OrdersModel> orders = []; // Siparişler listesi
  Map<ObjectId, UsersModel> customers = {};
  Map<ObjectId, wholesalerModel.UsersWholesalerModel> wholesalers =
      {}; //toptancı

  Map<ObjectId, Map<OrderProduct, ProductsModel>> orderProducts = {};

  List<ProductsModel> products = []; // Ürünler listesi
  bool isLoading = true; // Yükleniyor durumu

  @override
  void initState() {
    super.initState();
    mongoService = MongoDatabase(); // MongoDB servisini başlat
    _loadOrders(); // Siparişleri yükle
  }

  Future<void> _loadOrders() async {
    try {
      orders = await MongoDatabase.getOrders(); // Siparişleri yükle
      for (OrdersModel order in orders) {
        //Siparişin Müşterisi
        final customer = await mongoService.getCustomerById(order.customerId);
        if (customer != null) {
          customers[order.customerId] = customer;
        } else {
          print('Müşteri bulunamadı: ${order.customerId}');
        }
        //Siparişin Toptancısı
        final wholesaler =
            await mongoService.getWholesalerById(order.wholesalerId);
        if (wholesaler != null) {
          wholesalers[wholesaler.id] = wholesaler;
        } else {
          print('Toptancı bulunamadı: ${order.customerId}');
        }
        //Siparişin Ürünleri
        final productsList = await mongoService.getProductsWithOrder(order);
        orderProducts[order.id] = productsList;
      }

      setState(() {
        isLoading = false; // Yükleme tamamlandı
      });
    } catch (e) {
      print('Siparişleri yüklerken hata: $e'); // Hata durumunda mesaj göster
      _showErrorSnackbar(
          'Siparişleri yüklerken hata: $e'); // Hata durumunda mesaj göster
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date); // Tarih formatını ayarla
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message))); // Hata mesajını göster
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Siparişler'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final productList = orderProducts[order.id] ?? {};
                var orderTotalAmount = 0.0;
                return Card(
                  margin: EdgeInsets.all(8),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Müşteri ve Toptancı bilgisi
                        Text(
                          'Müşteri: ${customers[order.customerId]?.name ?? 'Bilinmiyor'}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Toptancı: ${wholesalers[order.wholesalerId]?.name ?? 'Bilinmiyor'}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        // Tarih kısmını sağ üst köşeye taşı
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Durum: ${order.status}',
                                style: TextStyle(color: Colors.grey)),
                            Text(
                              'Sipariş Tarihi: ${formatDate(order.orderDate)}',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),

                        // Ürünler başlığı
                        Text('Ürünler:',
                            style: TextStyle(fontWeight: FontWeight.bold)),

                        // Ürünleri yan yana listeleme bölümü
                        Wrap(
                          spacing: 8.0, // Ürünler arasındaki boşluk
                          runSpacing: 8.0,
                          children: productList.entries.map((entry) {
                            var product = entry.value;
                            var orderproduct = entry.key;
                            var productTotalAmount = orderproduct.price *
                                orderproduct.quantity.toDouble();
                            orderTotalAmount += productTotalAmount;
                            return SizedBox(
                              width: 150, // Her ürünün genişliği
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Ürün İsmi: ${product.title}'),
                                      Text('Fiyat: ${orderproduct.price}',
                                          style: TextStyle(color: Colors.grey)),
                                      Text('Miktar: ${orderproduct.quantity}',
                                          style: TextStyle(color: Colors.grey)),
                                      Text(
                                          'Ürün Toplam Fiyat: $productTotalAmount',
                                          style: TextStyle(color: Colors.grey)),
                                      Image.network(
                                        product.image,
                                        width: 800,
                                        height: 150,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Text(
                                              'Resim yüklenirken hata oluştu');
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        // Sipariş toplam fiyatı sağ alt köşeye taşı
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              'Sipariş Toplam Fiyat: $orderTotalAmount',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
