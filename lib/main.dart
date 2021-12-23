import 'package:flutter/material.dart';
import 'package:objectbox_practice/home_page.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Object Box',
      home: HomePage(),
    );
  }
}
