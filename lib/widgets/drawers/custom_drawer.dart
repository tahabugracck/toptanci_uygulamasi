// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:toptanci_uygulamasi/screens/cash_register_screen.dart';
import 'package:toptanci_uygulamasi/screens/employee_reporting_screen.dart';
import 'package:toptanci_uygulamasi/screens/login_screen.dart';
import 'package:toptanci_uygulamasi/screens/mobile_organise_screen.dart';
import 'package:toptanci_uygulamasi/screens/orders_screen.dart';
import 'package:toptanci_uygulamasi/screens/product_display_screen.dart';
import 'package:toptanci_uygulamasi/screens/product_screen.dart';
import 'package:toptanci_uygulamasi/screens/settings_screen.dart';


class CustomDrawer extends StatefulWidget {
  final bool hasMobileScreen;
  final Function(Widget) onMenuItemSelected;

  const CustomDrawer({
    super.key,
    required this.hasMobileScreen,
    required this.onMenuItemSelected,
  });

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String? selectedItem; // Seçili olan menü elemanını tutar
  bool isExpanded = false; // Menünün geniş olup olmadığını belirten değişken

  // Renkler
  final Color primaryColor = const Color(0xFF1E1E1E); // Gri tonlarında arka plan
  final Color secondaryColor = const Color(0xFF424242); // Daha açık gri ton

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isExpanded ? 230 : 70, // Genişlik butona tıklama durumuna göre değişir
      color: primaryColor,
      child: Column(
        children: [
          // Genişleme ve daralma butonu en üstte
          IconButton(
            icon: Icon(
              isExpanded ? Icons.arrow_circle_left : Icons.arrow_circle_right, // İkon değiştirildi
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                isExpanded = !isExpanded; // Butona basıldığında menü genişleyip daralır
              });
            },
          ),
          Container(
            padding: const EdgeInsets.all(10.0),
            color: primaryColor,
            alignment: Alignment.center,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isExpanded
                  ? const Text(
                      'Toptancı Uygulaması',
                      key: ValueKey('Expanded'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Container(key: const ValueKey('Collapsed')),
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.2)), // Üstteki çizgi

          // "Ekranlar" başlığı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isExpanded
                    ? const Text(
                        'Ekranlar', // Ekranlar başlığı
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Container(), // Genişlememiş durumda boş bırakılır
              ),
            ),
          ),

          // Menü listesi (ekranlar)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  buildListTile(Icons.shopping_cart, 'Ürün Yönetimi', const ProductScreen()),
                  buildListTile(Icons.list, 'Stok Takibi', const ProductDisplayScreen()),
                  buildListTile(Icons.list_alt_outlined, 'Sipariş Takibi', const OrdersScreen()),
                  buildListTile(Icons.phone_android_outlined, 'Mobil Ekran', const MobileOrganisesScreen()),
                  buildListTile(Icons.cases, 'Kasa', const CashRegisterScreen()),
                  buildListTile(Icons.work, 'Çalışanlar Raporları',  EmployeeReportingScreen())
                ],
              ),
            ),
          ),

          // Alt kısma ayarlar ve kullanıcı değiştirme
          Divider(color: Colors.white.withOpacity(0.2)), // Alttaki çizgi
          buildListTile(Icons.settings, 'Ayarlar', const SettingsScreen()),
          buildListTile(Icons.arrow_back_rounded, 'Kullanıcı Değiştir', null, () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }),
        ],
      ),
    );
  }

  // Menüyü oluşturan liste elemanları
  Widget buildListTile(IconData icon, String title, Widget? page, [VoidCallback? onTapOverride]) {
    final isSelected = selectedItem == title; // Seçili olup olmadığını kontrol eder

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedItem = title; // Seçilen öğeyi günceller
        });
        if (onTapOverride != null) {
          onTapOverride();
        } else if (page != null) {
          widget.onMenuItemSelected(page); // Sayfa geçişini sağlar
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected ? secondaryColor : Colors.transparent, // Seçili olan menü elemanının rengini değiştirir
          borderRadius: BorderRadius.circular(50),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, spreadRadius: 1)] // Seçili olan menü elemanına gölge ekler
              : null,
        ),
        child: ListTile(
          leading: Icon(icon, color: isSelected ? Colors.black : Colors.white), // İkonun rengi seçili olup olmamasına göre değişir
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isExpanded
                ? Text(
                    title,
                    key: ValueKey(title),
                    style: TextStyle(color: isSelected ? Colors.black : Colors.white), // Başlık rengi
                  )
                : const SizedBox.shrink(), // Menü daraltılmışken başlık gösterilmez
          ),
        ),
      ),
    );
  }
}
