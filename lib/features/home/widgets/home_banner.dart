// lib/features/home/widgets/home_banner.dart
import 'package:flutter/material.dart';

class HomeBanner extends StatefulWidget {
  const HomeBanner({Key? key}) : super(key: key);

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> banners = [
    {"image": "assets/banner1.jpg", "title": "Special Offer"},
    {"image": "assets/banner2.jpg", "title": "Big Sale"},
    {"image": "assets/banner3.jpg", "title": "New Arrival"},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: banners.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.green[100 * ((index % 3) + 1)],
                  image: DecorationImage(
                    image: AssetImage(banners[index]["image"]!),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                banners.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Colors.green
                        : Colors.grey.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
