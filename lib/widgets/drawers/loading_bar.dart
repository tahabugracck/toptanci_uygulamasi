// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

// Yükleniyor animasyonu için ana bileşen
class LoadingAnimation extends StatelessWidget {
  const LoadingAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 50, // Yükleniyor animasyonunun genişliği
        height: 50, // Yükleniyor animasyonunun yüksekliği
        child: LoadingIndicator(), // Yükleniyor göstergesi bileşeni
      ),
    );
  }
}

// Yükleniyor göstergesi için durum yönetimi olan bileşen
class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({super.key});

  @override
  _LoadingIndicatorState createState() => _LoadingIndicatorState();
}

// Durum yönetimi
class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller; // Animasyon kontrolörü

  @override
  void initState() {
    super.initState();
    // Animasyon kontrolörünü oluştur ve sürekli tekrar et
    _controller = AnimationController(
      duration: const Duration(seconds: 2), // Animasyonun süresi
      vsync: this, // Tekrar için bir kaynak
    )..repeat(); // Animasyonu sürekli tekrar et
  }

  @override
  void dispose() {
    _controller.dispose(); // Kontrolörü serbest bırak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dönme animasyonu için RotationTransition kullan
    return RotationTransition(
      turns: _controller, // Dönüş açısını kontrol et
      child: Icon(
        Icons.refresh, // Yükleniyor simgesi
        size: 50, // İkon boyutu
        color: Theme.of(context).primaryColor, // Temanın birincil rengi
      ),
    );
  }
}
