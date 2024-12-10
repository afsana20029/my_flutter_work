import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? position;
  GoogleMapController? mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  final LatLng? _destination = const LatLng(
      23.756188979961518, 90.38667634904655); // Example destination (Kolkata)

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
            distanceFilter: 10,
            accuracy: LocationAccuracy.bestForNavigation,
          ),
        ).listen((pos) {
          setState(() {
            position = pos;
            _updateMap();
          });
        });//
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
          _updateMap();
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

  void _updateMap() {
    if (position != null) {
      _markers = {
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(position!.latitude, position!.longitude),
          infoWindow: const InfoWindow(title: 'Current Location'),
        ),
        Marker(
          markerId: const MarkerId('destination'),
          position: _destination!,
          infoWindow: const InfoWindow(title: 'Destination'),
        ),
      };

      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: [
            LatLng(position!.latitude, position!.longitude),
            _destination!,
          ],
          color: Colors.blue,
          width: 5,
        ),
      };
    }
  }

  Future<bool> isLocationPermissionGranted() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
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
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(position!.latitude, position!.longitude),
          zoom: 14,
        ),
        markers: _markers,
        polylines: _polylines,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
