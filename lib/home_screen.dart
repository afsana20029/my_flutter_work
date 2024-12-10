import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapApp extends StatefulWidget {
  @override
  _MapAppState createState() => _MapAppState();
}

class _MapAppState extends State<MapApp> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Marker? _currentMarker;
  List<LatLng> _polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  Timer? _locationUpdateTimer;

  @override
  void initState() {
    super.initState();
    _initializeLocationUpdates();
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocationUpdates() async {
    final permissionGranted = await _requestLocationPermission();
    if (permissionGranted) {
      _updateCurrentLocation(); // Get the initial location.
      _locationUpdateTimer = Timer.periodic(const Duration(seconds: 10), () {
        _updateCurrentLocation(); // Update every 10 seconds.
      } as void Function(Timer timer));
    }
  }

  Future<bool> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> _updateCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _updateMarker(position);
        _updatePolyline(position);
        _animateMapToPosition(position);
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void _updateMarker(Position position) {
    final LatLng currentLatLng = LatLng(position.latitude, position.longitude);
    _currentMarker = Marker(
      markerId: const MarkerId("current_location"),
      position: currentLatLng,
      infoWindow: InfoWindow(
        title: "My current location",
        snippet:
        "Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}",
      ),
    );
  }

  void _updatePolyline(Position position) {
    final LatLng currentLatLng = LatLng(position.latitude, position.longitude);
    _polylineCoordinates.add(currentLatLng);
    _polylines = {
      Polyline(
        polylineId: const PolylineId("tracking_route"),
        points: _polylineCoordinates,
        color: Colors.blue,
        width: 4,
      ),
    };
  }

  void _animateMapToPosition(Position position) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map Tracking App"),
        backgroundColor: Colors.blue,
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          zoom: 16,
        ),
        markers: _currentMarker != null ? {_currentMarker!} : {},
        polylines: _polylines,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}

