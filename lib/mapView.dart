import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class MapView extends StatefulWidget {
  
  const MapView({Key? key}) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();

}

class _MapViewState extends State<MapView> {
  
  Completer<GoogleMapController> _controller = Completer();

  static const LatLng _center = LatLng(4.6029286, -74.0653713);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Center(child: Text("SEXOOOOO")),
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
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: GoogleMap( 
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 19.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

