import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:test_drive/category.dart';
import 'package:test_drive/filter/filter_screen.dart';
import 'package:test_drive/itemss.dart';
import 'package:test_drive/location.dart';
import 'package:test_drive/nearme.dart';
import 'package:test_drive/restaurantcarrousel.dart';
import 'package:test_drive/titlemenu.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  final List<Restaurant> restaurants;

  //HomeScreen(restaurants, {Key? key, required this.restaurants}) : super(key: key);
  const HomeScreen({super.key, required this.restaurants});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FilterOptions selectedFilters = FilterOptions(type: 'ALL', price: '');

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
                  FilterWidget(
                    onFiltersChanged: (filters) {
                      setState(() {
                        selectedFilters = filters;
                      });
                    },
                  ),
                  titlemenu(
                    text: "Lo más buscado",
                  ),
                  RestaurantCarousel(
                    restaurants: widget.restaurants.where((restaurant) {
                      bool typeMatch = selectedFilters.type == 'ALL' ||
                          restaurant.type == selectedFilters.type;
                      bool priceMatch = selectedFilters.price.isEmpty ||
                          restaurant.price == selectedFilters.price;
                      return typeMatch && priceMatch;
                    }).toList(),
                  ),
                  titlemenu(
                    text: "Opciones veganas",
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('veganrestaurants')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Error al obtener los datos: ${snapshot.error}');
                      }
                      final List<Restaurant> restaurants = snapshot.data!.docs.map((doc) {
                        return Restaurant(
                          name: doc['name'],
                          imageUrl: doc['url'],
                          description: doc['description'],
                          lat: 0,
                          long: 0,
                          price: "a",
                          type: "a",
                        );
                      }).toList();
                      return RestaurantCarousel(
                        restaurants: restaurants.where((restaurant) {
                          bool typeMatch = selectedFilters.type == 'ALL' ||
                              restaurant.type == selectedFilters.type;
                          bool priceMatch = selectedFilters.price.isEmpty ||
                              restaurant.price == selectedFilters.price;
                          return typeMatch && priceMatch;
                        }).toList(),
                      );
                    },
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
