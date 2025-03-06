// lib/features/home/widgets/home_menu_grid.dart
import 'package:flutter/material.dart';

class HomeMenuGrid extends StatelessWidget {
  const HomeMenuGrid({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> menus = const [
    {'icon': Icons.category, 'label': 'Categories', 'color': Colors.blue},
    {'icon': Icons.local_offer, 'label': 'Offers', 'color': Colors.orange},
    {'icon': Icons.card_giftcard, 'label': 'Rewards', 'color': Colors.purple},
    {'icon': Icons.storefront, 'label': 'Official Store', 'color': Colors.red},
    {'icon': Icons.trending_up, 'label': 'Trending', 'color': Colors.teal},
    {'icon': Icons.live_tv, 'label': 'Live', 'color': Colors.pink},
    {'icon': Icons.payment, 'label': 'Top Up', 'color': Colors.indigo},
    {'icon': Icons.more_horiz, 'label': 'More', 'color': Colors.brown},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: menus.length,
            itemBuilder: (context, index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: menus[index]['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      menus[index]['icon'],
                      color: menus[index]['color'],
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    menus[index]['label'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
