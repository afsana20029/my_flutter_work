import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? position;
  GoogleMapController? _mapController;
  final List<LatLng> _routeCoordinates = [];
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng initialLocation=const LatLng(23.79657535109147, 90.43579444943923);
  @override
  void initState() {
    super.initState();
    listenCurrentLocation();
  }

  Future<void> listenCurrentLocation() async {
    final isGranted = await isLocationPermissionGranted();
    if (isGranted) {
      final isServiceEnabled = await checkGPSServiceEnable();
      if (isServiceEnabled) {
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
              distanceFilter: 10, accuracy: LocationAccuracy.bestForNavigation),
        ).listen((pos) {
          setState(() {
            position = pos;
            LatLng currentLatLng = LatLng(pos.latitude, pos.longitude);

            _routeCoordinates.add(currentLatLng);

            _markers = {
              Marker(
                markerId: const MarkerId('current_location'),
                position: currentLatLng,
                infoWindow: InfoWindow(
                  title: 'Current Location',
                  snippet:
                      'Lat: ${currentLatLng.latitude}, Lng: ${currentLatLng.longitude}',
                ),
              ),
            };

            _polylines = {
              Polyline(
                polylineId: const PolylineId('route'),
                points: _routeCoordinates,
                color: Colors.blue,
                width: 5,
              ),
            };

            _mapController?.animateCamera(
              CameraUpdate.newLatLng(currentLatLng),
            );
          });
        });
      } else {
        Geolocator.openLocationSettings();
      }
    } else {
      final result = await requestLocationPermission();
      if (result) {
        getCurrentLocation();
      } else {
        Geolocator.openAppSettings();
      }
    }
  }

  Future<void> getCurrentLocation() async {
    final isGranted = await isLocationPermissionGranted();
    if (isGranted) {
      final isServiceEnabled = await checkGPSServiceEnable();
      if (isServiceEnabled) {
        Position p = await Geolocator.getCurrentPosition();
        setState(() {
          position = p;
        });
      } else {
        Geolocator.openLocationSettings();
      }
    } else {
      final result = await requestLocationPermission();
      if (result) {
        getCurrentLocation();
      } else {
        Geolocator.openAppSettings();
      }
    }
  }

  Future<bool> isLocationPermissionGranted() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkGPSServiceEnable() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: position != null
                  ? LatLng(position!.latitude, position!.longitude)
                  : const LatLng(0, 0),
              zoom: 16.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            markers: _markers,
            polylines: _polylines,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: ElevatedButton(
              onPressed: () {
                getCurrentLocation();
              },
              child: const Text('Get current location'),
            ),
          ),
        ],
      ),
    );
  }
}
