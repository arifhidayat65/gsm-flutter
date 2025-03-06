// // lib/features/navigation/screens/main_navigation_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../home/screens/home_screen.dart';
// import '../controllers/navigation_controller.dart';

// class MainNavigationScreen extends StatelessWidget {
//   const MainNavigationScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<NavigationController>(
//       builder: (context, controller, child) {
//         return Scaffold(
//           body: IndexedStack(
//             index: controller.currentIndex,
//             children: [
//               const HomeScreen(),
//               // const FeedScreen(), // Create these screens
//               // const WalletScreen(), // Create these screens
//               // const OrdersScreen(), // Create these screens
//               // const ProfileScreen(), // Create these screens
//             ],
//           ),
//           bottomNavigationBar: const HomeBottomNavBar(),
//         );
//       },
//     );
//   }
// }
