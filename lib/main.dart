import 'package:flutter/material.dart';
void main() => runApp(MyApp());


// Flutter apps require a main.dart but my code does not use it.
// My code is not attached to any UI elements.

class MyApp extends StatelessWidget {
  const MyApp({ Key key }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vending Machine',
      home: Scaffold(
        appBar: AppBar(
          title: Text("Vending Machine"),
        ),
        body: Center()
      ),
    );
  }
}
