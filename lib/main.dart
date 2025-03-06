// lib/main.dart
import 'package:flutter/material.dart';
import 'package:gsmpromo/features/home/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'controllers/navigation_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationController()),
        // Add other providers here
      ],
      child: MaterialApp(
        title: 'Tokopedia Clone',
        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: Colors.grey[100],
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
