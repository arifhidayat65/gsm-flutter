// lib/features/home/widgets/home_search_bar.dart
import 'package:flutter/material.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.white,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search Products',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: const Icon(Icons.camera_alt_outlined, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
