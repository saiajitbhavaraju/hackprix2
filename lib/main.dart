// lib/main.dart
// NO CHANGES WERE NEEDED FOR THIS FILE.

import 'package:flutter/material.dart';
import 'package:ecosnap_1/screens/home_page_screen.dart';
import 'package:ecosnap_1/services/snap_state_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SnapStateService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snapchat Clone App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePageScreen(),
    );
  }
}