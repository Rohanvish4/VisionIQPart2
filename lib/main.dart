import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_binding.dart';
import 'ui/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VisionIQApp());
}

class VisionIQApp extends StatelessWidget {
  const VisionIQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Vision IQ',
      initialBinding: AppBinding(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
