// lib/features/home/widgets/home_bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/navigation_controller.dart';

class HomeBottomNavBar extends StatelessWidget {
  const HomeBottomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationController>(
      builder: (context, controller, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_outlined),
                activeIcon: Icon(Icons.shopping_cart),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_outline),
                activeIcon: Icon(Icons.favorite),
                label: 'Wishlist',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.mail_outline),
                activeIcon: Icon(Icons.mail),
                label: 'Inbox',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            currentIndex: controller.currentIndex,
            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.grey,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            onTap: (index) => controller.setIndex(index),
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        );
      },
    );
  }
}
