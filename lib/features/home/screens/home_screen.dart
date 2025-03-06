// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:gsmpromo/features/home/widgets/home_bottom_nav_bar.dart';
// import 'widgets/home_bottom_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: const [
              // HomeAppBar(),
              // HomeSearchBar(),
              // HomeBanner(),
              // HomeMenuGrid(),
              // HomePromoSection(),
              // HomeProductGrid(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const HomeBottomNavBar(),
    );
  }
}
