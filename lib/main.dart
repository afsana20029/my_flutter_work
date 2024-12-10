import 'package:flutter/material.dart';
import 'package:my_flutter_work/home_screen.dart';


void main(){
  runApp(Calculator());
}
class Calculator extends StatelessWidget {
  const Calculator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      home:const HomeScreen(),
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}

