import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_drive/restaurantcarrousel.dart';
import 'package:test_drive/user_auth/pages/login_auth.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('restaurants').get();
      List<Restaurant> restaurants = snapshot.docs.map((doc) {
        return Restaurant(
          name: doc['name'],
          imageUrl: doc['url'],
          description: doc['description'],
          lat: doc['lat'],
          long: doc['long'],
          price: doc['price'],
          type: doc['type'],
        );
      }).toList();

      // Una vez cargados los datos, navega a la pantalla de inicio de sesión
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(restaurants: restaurants),
        ),
      );
    } catch (e) {
      print('Error loading data: $e');
      // Manejo del error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Puedes personalizar el splash
      ),
    );
  }
}
