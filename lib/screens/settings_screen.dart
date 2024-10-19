// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toptanci_uygulamasi/widgets/drawers/theme_notifier.dart';
import 'package:toptanci_uygulamasi/widgets/drawers/theme_setting.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedTheme = 'Standart';
  bool _obscurePassword = true; // Şifre görünürlüğünü kontrol eden değişken


  List<String> employees = ['Ali', 'Ayşe', 'Mehmet']; // Çalışan listesi
  String? _selectedEmployee; // Seçilen çalışan
  final List<bool> _selectedScreens = [false, false, false]; // Çalışan ekranları seçimi
  final List<String> _screens = ['Satış Ekranı', 'Ürün Yönetimi', 'Raporlama'];


  String _email = '';
  String _password = '';
  
  @override
  void initState() {
    super.initState();
    // Kullanıcı adı ve şifreyi mevcut kullanıcıdan alabilirsiniz
     _loadUserData();
  }

  // Kullanıcı bilgilerini yükle
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = prefs.getString('email') ?? 'Bilinmiyor';
      _password = prefs.getString('password') ?? 'Bilinmiyor';
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _changeTheme(String theme) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    ThemeData newTheme;

    if (theme == 'Beyaz') {
      newTheme = ThemeSettings.whiteTheme; // Beyaz tema
    } else if (theme == 'Karanlık') {
      newTheme = ThemeSettings.darkTheme; // Karanlık tema
    } else {
      newTheme = ThemeSettings.standardTheme; // Standart tema
    }

    themeNotifier.setTheme(newTheme);
  }

  Future<void> _updateUserData() async {
}


  void _saveEmployeeAccess() {
    List<String> selectedScreens = [];
    for (int i = 0; i < _screens.length; i++) {
      if (_selectedScreens[i]) {
        selectedScreens.add(_screens[i]);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Çalışan: $_selectedEmployee, Erişim: $selectedScreens'),
      ),
    );
  }

  // Hakkında bilgilerini gösteren yöntem
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hakkında'),
          content: const Text('Uygulama Versiyonu: 1.0.0\nGeliştirici: Mehel Ar-Ge ve Otomasyon'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ayarlar"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Tema Seçimi Kartı
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.palette, size: 24),
                        SizedBox(width: 10),
                        Text(
                          'Tema Seçimi',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedTheme = 'Standart';
                              _changeTheme(_selectedTheme);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeSettings.standardTheme.primaryColor,
                          ),
                          child: const Text('Standart'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedTheme = 'Beyaz';
                              _changeTheme(_selectedTheme);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeSettings.whiteTheme.primaryColor,
                          ),
                          child: const Text('Beyaz'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedTheme = 'Karanlık';
                              _changeTheme(_selectedTheme);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeSettings.darkTheme.primaryColor,
                          ),
                          child: const Text('Karanlık'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Kullanıcı Bilgileri Kartı
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 10),
                        Text(
                          'Kullanıcı Bilgileri',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Kullanıcı Adı'),
                      controller: TextEditingController(text: _email),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Şifre'),
                      obscureText: _obscurePassword,
                      controller: TextEditingController(text: _password),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: !_obscurePassword,
                          onChanged: (value) {
                            setState(() {
                              _obscurePassword = !value!;
                            });
                          },
                        ),
                        const Text('Şifreyi Göster')
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onPressed: _updateUserData,
                      child: const Text('Bilgileri Güncelle', style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ),
            // Çalışan Erişimi Kartı
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.work, size: 24),
                        SizedBox(width: 10),
                        Text(
                          'Çalışan Erişimi',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      hint: const Text('Çalışan Seçin'),
                      value: _selectedEmployee,
                      items: employees.map((String employee) {
                        return DropdownMenuItem<String>(
                          value: employee,
                          child: Text(employee),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedEmployee = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: List.generate(_screens.length, (index) {
                        return CheckboxListTile(
                          title: Text(_screens[index]),
                          value: _selectedScreens[index],
                          onChanged: (bool? value) {
                            setState(() {
                              _selectedScreens[index] = value!;
                            });
                          },
                        );
                      }),
                    ),
                    ElevatedButton(
                      onPressed: _saveEmployeeAccess,
                      child: const Text('Çalışan Ekranlarına Erişim Sağla'),
                    ),
                  ],
                ),
              ),
            ),
            // Hakkında Butonu
            TextButton(
              onPressed: _showAboutDialog,
              child: const Text('Hakkında', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
