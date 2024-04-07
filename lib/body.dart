import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:test_drive/category.dart';
import 'package:test_drive/itemss.dart';
import 'package:test_drive/location.dart';
import 'package:test_drive/nearme.dart';
import 'package:test_drive/restaurantcarrousel.dart';
import 'package:test_drive/titlemenu.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class HomeScreen extends StatelessWidget {
   HomeScreen({super.key});

    final List<Restaurant> restaurants = [
    Restaurant(
      name: "Toninos Pasta",
      imageUrl: "https://images.rappi.com/restaurants_logo/formevfdgfxato-logo-1614191489436.png",
      description: "Pastas unicas y deliciosas.",
    ),
    Restaurant(
      name: "OneBurrito",
      imageUrl: "https://images.rappi.com/restaurants_logo/oneburrito-logo-1614191489436.png",
      description: "Comida mexicana, tacos y burritos, siempre a la orden del dia.",
    ),
    // Agrega más restaurantes según lo necesites
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            Container(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 25),
                    margin: EdgeInsets.all(15),
                    width: MediaQuery.of(context).size.width,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Color.fromARGB(0, 255, 251, 3),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        icon: Icon(Icons.toc_outlined),
                        hintText: 'U. de los Andes',
                        hintStyle: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                  //location(),

                  //itemss(),
                  titlemenu(
                    text: "Lo más buscado",
                  ),
                  //nearmeitem(),
                 StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('restaurants').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // Muestra un indicador de carga mientras se cargan los datos
                  }
                  if (snapshot.hasError) {
                    return Text('Error al obtener los datos: ${snapshot.error}');
                  }
                  final List<Restaurant> restaurants = snapshot.data!.docs.map((doc) {
                    return Restaurant(
                      name: doc['name'],
                      imageUrl: doc['url'],
                      description: doc['description'],
                    );
                  }).toList();
                  return RestaurantCarousel(restaurants: restaurants);
                }
              ),
              titlemenu(
                    text: "Opciones veganas",
                  ),
                StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('veganrestaurants').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // Muestra un indicador de carga mientras se cargan los datos
                  }
                  if (snapshot.hasError) {
                    return Text('Error al obtener los datos: ${snapshot.error}');
                  }
                  final List<Restaurant> restaurants = snapshot.data!.docs.map((doc) {
                    return Restaurant(
                      name: doc['name'],
                      imageUrl: doc['url'],
                      description: doc['description'],
                    );
                  }).toList();
                  return RestaurantCarousel(restaurants: restaurants);
                }
              ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
