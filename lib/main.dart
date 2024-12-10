import 'package:flutter/material.dart';
import 'package:my_flutter_work/home_screen.dart';


void main(){
  runApp(const GoogleMapGeolocator());
}
class GoogleMapGeolocator extends StatelessWidget {
  const GoogleMapGeolocator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      home:HomeScreen(),
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}

