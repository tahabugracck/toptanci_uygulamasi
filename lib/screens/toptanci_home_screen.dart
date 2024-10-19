import 'package:flutter/material.dart';
import 'package:toptanci_uygulamasi/widgets/drawers/custom_drawer.dart'; // CustomDrawer burada yer alıyor

class ToptanciHomeScreen extends StatefulWidget {
  const ToptanciHomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ToptanciHomeScreenState createState() => _ToptanciHomeScreenState();
}

class _ToptanciHomeScreenState extends State<ToptanciHomeScreen> {
  Widget _selectedPage = const Center(
    child: Text(
      'Hoşgeldiniz Toptancı!',
      style: TextStyle(fontSize: 24),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          CustomDrawer(
            hasMobileScreen: false,
            onMenuItemSelected: (Widget page) {
              setState(() {
                _selectedPage = page;
              });
            },
          ),
          Expanded(
            child: _selectedPage,
          ),
        ],
      ),
    );
  }
}
