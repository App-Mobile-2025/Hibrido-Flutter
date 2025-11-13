import 'package:flutter/material.dart';
import 'routing/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoApp',
      theme: ThemeData(primarySwatch: Colors.green),
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: '/',
    );
  }
}
