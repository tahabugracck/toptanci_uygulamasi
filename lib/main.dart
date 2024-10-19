import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toptanci_uygulamasi/service/mongodb.dart';
import 'package:toptanci_uygulamasi/screens/login_screen.dart';
import 'package:toptanci_uygulamasi/screens/toptanci_home_screen.dart';
import 'package:toptanci_uygulamasi/widgets/drawers/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MongoDatabase.connect(); // MongoDB bağlantısını başlat
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeNotifier()), // Tema yöneticisini sağlayıcı olarak ekleyin
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Uygulama',  
          theme: themeNotifier.currentTheme, // Tema ayarlarını tema yöneticisinden al
          initialRoute: '/', // Başlangıç rotası
          routes: {
            '/': (context) => const LoginScreen(), // Giriş ekranı
            '/toptanci': (context) => const ToptanciHomeScreen(), // Toptancı ana ekranı
          },
        );
      },
    );
  }
}
