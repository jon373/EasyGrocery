import 'package:flutter/material.dart';
import 'homepage.dart';

void main() {
  runApp(EasyGroceryApp());
}

class EasyGroceryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyGrocery',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: GroceryHomePage(),
    );
  }
}
