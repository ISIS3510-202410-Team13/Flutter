import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'package:test_drive/location.dart';

class MapView extends StatefulWidget {
  const MapView({
    Key? key,
    required this.lat,
    required this.long,
  }) : super(key: key);

  final double lat;
  final double long;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final locationController = Location();
  LatLng? _center;
  LatLng? currentPosition;
  Map<PolylineId, Polyline> polylines = {};
  StreamSubscription<LocationData>? locationSubscription;

  @override
  void initState() {
    super.initState();
    _center = LatLng(widget.lat, widget.long);
    WidgetsBinding.instance.addPostFrameCallback((_) async => await initializeMap());
  }

  Future<void> initializeMap() async {
    fetchLocationUpdates();
    final coordinates = await fetchPolylinePoints();
    generatePolyLineFromPoints(coordinates);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Center(child: Text("U. de los Andes")),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Handle menu button press
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Handle user logo button press
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: currentPosition == null
                  ? const Center(child: Text("Loading"))
                  : GoogleMap(
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      initialCameraPosition: CameraPosition(
                        target: _center!,
                        zoom: 19.0,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId("U. De Los Andes"),
                          position: LatLng(_center!.latitude, _center!.longitude),
                        ),
                        Marker(
                          markerId: MarkerId("currentLocation"),
                          position: LatLng(currentPosition!.latitude, currentPosition!.longitude),
                        ),
                      },
                      polylines: Set<Polyline>.of(polylines.values),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationController.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationSubscription = locationController.onLocationChanged.listen((currentLocation) {
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        if (mounted) {
          setState(() {
            currentPosition = LatLng(currentLocation.latitude!, currentLocation.longitude!);
          });

          fetchPolylinePoints().then((coordinates) {
            if (mounted) {
              generatePolyLineFromPoints(coordinates);
            }
          });
        }
      }
    });
  }

  Future<List<LatLng>> fetchPolylinePoints() async {
    final polylinePoints = PolylinePoints();

    final result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyAl1qbz6VmRsbbc5bbMUZAvUeNWRG9ofic", // Reemplaza "YOUR_API_KEY" con tu clave de API de Google Maps
      PointLatLng(currentPosition!.latitude, currentPosition!.longitude),
      PointLatLng(widget.lat, widget.long),
      travelMode: TravelMode.walking, // Especificar el modo de viaje a pie
    );

    if (result.points.isNotEmpty) {
      return result.points.map((point) => LatLng(point.latitude, point.longitude)).toList();
    } else {
      debugPrint(result.errorMessage);
      return [];
    }
  }

  Future<void> generatePolyLineFromPoints(List<LatLng> polylineCoordinates) async {
    const id = PolylineId('polyline');

    final polyline = Polyline(
      polylineId: id,
      color: Colors.blueAccent,
      points: polylineCoordinates,
      width: 5,
    );

    if (mounted) {
      setState(() => polylines[id] = polyline);
    }
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    super.dispose();
  }
}
