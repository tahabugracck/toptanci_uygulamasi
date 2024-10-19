// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toptanci_uygulamasi/service/mongodb.dart';
import 'package:crypto/crypto.dart';
import 'package:toptanci_uygulamasi/widgets/drawers/loading_bar.dart';
import 'dart:convert';
import '../widgets/drawers/theme_notifier.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // TextEditingController'lar, kullanıcı adı ve şifreyi yönetmek için
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // Yükleniyor durumunu kontrol eder
  bool _isAnimated = false; // Animasyon durumunu kontrol eder
  bool _obscureText = true; // Şifre alanının görünürlüğünü kontrol eder

  @override
  void initState() {
    super.initState();
    // MongoDB veritabanına bağlan
    MongoDatabase.connect();
    // Animasyonu başlatmak için kısa bir gecikme ekle
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _isAnimated = true; // Animasyon başlatıldı
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        final theme = themeNotifier.currentTheme;
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Row(
            children: [
              // Sol taraftaki animasyonlu karşılama alanı
              AnimatedContainer(
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOut,
                width: _isAnimated ? MediaQuery.of(context).size.width / 2 : 0,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor.withOpacity(0.3),
                      theme.primaryColor.withOpacity(0.5)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: AnimatedOpacity(
                    duration: const Duration(seconds: 1),
                    opacity: _isAnimated ? 1.0 : 0.0,
                    child: Text(
                      'Hoşgeldiniz',
                      style: TextStyle(
                        fontSize: 30,
                        color: theme.textTheme.headlineMedium?.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              // Sağ taraftaki giriş formu
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: theme.cardColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Giriş yap başlığı
                          Text(
                            'Giriş Yap',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: theme.textTheme.headlineMedium?.color,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 20),
                          // Kullanıcı adı girişi
                          _buildTextField(
                            controller: _emailController,
                            label: 'Kullanıcı Adı',
                            prefixIcon: Icons.person,
                            onSubmitted: (_) => _focusPasswordField(),
                          ),
                          const SizedBox(height: 20),
                          // Şifre girişi
                          _buildTextField(
                            controller: _passwordController,
                            label: 'Şifre',
                            prefixIcon: Icons.lock,
                            obscureText: _obscureText,
                            onSubmitted: (_) => _login(),
                          ),
                          const SizedBox(height: 30),
                          // Yükleniyor göstergesi veya giriş butonları
                          _isLoading
                              ? _buildLoadingIndicator()
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: _buildGradientButton(
                                        onPressed: _login,
                                        text: 'Giriş Yap',
                                        colors: [
                                          theme.primaryColor,
                                          theme.primaryColor.withOpacity(0.7),
                                        ],
                                        textColor:
                                            theme.textTheme.labelLarge?.color ??
                                                Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // Şifremi Unuttum butonu kaldırıldı
                                  ],
                                ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

 // Metin giriş alanı oluşturan fonksiyon
Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required IconData prefixIcon,
  bool obscureText = false,
  void Function(String)? onSubmitted,
}) {
  return Consumer<ThemeNotifier>(
    builder: (context, themeNotifier, child) {
      final theme = themeNotifier.currentTheme;
      return TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(prefixIcon, color: theme.iconTheme.color),
          suffixIcon: label == 'Şifre' // Yalnızca şifre için göz ikonu
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText; // Şifre alanının görünürlüğünü değiştir
                    });
                  },
                )
              : null, // Kullanıcı adı için ikon yok
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.primaryColor, width: 2.0),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onSubmitted: onSubmitted,
      );
    },
  );
}


  // Şifre alanına odaklanmak için kullanılacak fonksiyon
  void _focusPasswordField() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  // Gradient buton oluşturan fonksiyon
  Widget _buildGradientButton({
    required VoidCallback onPressed,
    required String text,
    required List<Color> colors,
    required Color textColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(30),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 18, color: textColor),
        ),
      ),
    );
  }

  // Yükleniyor göstergesi oluşturan fonksiyon
  Widget _buildLoadingIndicator() {
    return const LoadingAnimation(); // Yeni oluşturduğumuz yükleniyor animasyonu
  }

  // Giriş yapma fonksiyonu
  Future<void> _login() async {
    setState(() {
      _isLoading = true; // Yükleniyor durumunu güncelle
    });

    String email = _emailController.text; // Kullanıcı adı al
    String password = _passwordController.text; // Şifre al
    String hashedPassword = _hashPassword(password); // Şifreyi hash'le

    var user = await MongoDatabase.fetchUserByUsername(email); // Kullanıcıyı veritabanından al

    if (!mounted) return;

    if (user != null && user['password'] == hashedPassword) {

      final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);

      // Başarıyla giriş yaptıysa uygun ekrana yönlendir
      if (user['wholesaler'] == true) {
        Navigator.pushReplacementNamed(context, '/toptanci');
      }
    } else {
      // Hatalı giriş durumu için kullanıcıya mesaj göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kullanıcı adı veya şifre hatalı'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    setState(() {
      _isLoading = false; // Yükleniyor durumunu güncelle
    });
  }

  // Şifreyi hash'leme fonksiyonu
  String _hashPassword(String password) {
    final bytes = utf8.encode(password); // Şifreyi byte dizisine çevir
    final digest = sha256.convert(bytes); // SHA-256 ile hash'le
    return digest.toString(); // Hash'lenmiş şifreyi döndür
  }
}
