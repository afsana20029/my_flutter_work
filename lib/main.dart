import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_work/simple_calculator.dart';

void main(){
  runApp(Calculator());
}
class Calculator extends StatelessWidget {
  const Calculator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      home:SimpleCalculator(),
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}

