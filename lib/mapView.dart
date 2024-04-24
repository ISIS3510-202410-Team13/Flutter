import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

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
  
  Completer<GoogleMapController> _controller = Completer();

  LatLng? _center;

  Map<PolylineId, Polyline> polylines = {};

  late Future<Position> _currentPosition;

  @override
  void initState() {
    super.initState();
    _center = LatLng(widget.lat, widget.long);
    _currentPosition = getUserCurrentLocation();
  }

  Future<Position> getUserCurrentLocation() async {

    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
 if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the 
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale 
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately. 
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

    Future<List<LatLng>> fetchPolylinePoints() async {
    final polylinePoints = PolylinePoints();

    final result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyAl1qbz6VmRsbbc5bbMUZAvUeNWRG9ofic",
      PointLatLng(4.6025061, -74.066107),
      PointLatLng(widget.lat, widget.long),
    );

    if (result.points.isNotEmpty) {
      return result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    } else {
      debugPrint(result.errorMessage);
      return [];
    }
  }

  Future<void> generatePolyLineFromPoints(
      List<LatLng> polylineCoordinates) async {
    const id = PolylineId('polyline');

    final polyline = Polyline(
      polylineId: id,
      color: Colors.blueAccent,
      points: polylineCoordinates,
      width: 5,
    );

    setState(() => polylines[id] = polyline);

    print(polylines);
    }

  getPolypoints(){
    //Position current = _currentPosition as Position;
    LatLng desde = LatLng(4.6025061, -74.066107);
    LatLng hasta = LatLng(widget.lat, widget.long);

    final Set<Polyline> _polyline = {};

    _polyline.add( 
      Polyline(
        polylineId: PolylineId('ruta'),
        visible: true,
        points: [desde, hasta],
        color: Colors.blue,
        width: 4,
      )
    );

  return _polyline;
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
      body:  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: GoogleMap(
                polylines: polylines.values.toSet(),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  () async {
                    final Position position = getUserCurrentLocation() as Position;
                    controller.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(position.latitude, position.longitude),
                        zoom: 19.0,
                      ),
                    ));
                  };
                },
                initialCameraPosition: CameraPosition(
                  target: _center!,
                  zoom: 19.0,
                ),
                markers: {
                   Marker(
                    markerId: MarkerId("U. De Los Andes"),
                    position: LatLng(_center!.latitude, _center!.longitude),
                   )
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



