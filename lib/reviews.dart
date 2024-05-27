import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_drive/singleReview.dart';

class Reviews extends StatefulWidget {
  const Reviews({
    Key? key,
    required this.name,
    required this.url,
  }) : super(key: key);

  final String name;
  final String url;

  @override
  _ReviewsState createState() => _ReviewsState();
}

class Review{
  final String restaurant;
  final String text;
  final String user;

  Review({
    required this.restaurant,
    required this.text,
    required this.user,
  });

  Map<String, dynamic> toJson() {
                            return {
                              'restaurant': restaurant,
                              'text': text,
                              'user': user,
                            };
                          }

}

class _ReviewsState extends State<Reviews> {

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
      body: SingleChildScrollView(
  child: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Reseñas",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Text(
          widget.name ?? "",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Image.network(
          widget.url ?? "",
          width: 200,
          height: 200,
        ),
          
          StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('reviews')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator(); // Muestra un indicador de carga mientras se cargan los datos
                        }
                        if (snapshot.hasError) {
                          return Text(
                              'Error al obtener los datos: ${snapshot.error}');
                        }
                        final List<Review> restaurants =
                            snapshot.data!.docs.map((doc) {
                          return Review(
                            restaurant: doc['restaurant'],
                            text: doc['text'],
                            user: doc['user'],
                          );
                        }).toList();
                      
                        // Convert the list of restaurants to JSON
                        final restaurantsJson = jsonEncode(restaurants);
                        
                        final file = File('restaurants.json');
                        file.writeAsString(restaurantsJson);
                        // Write the JSON data to a file

                        List<Review> filteredRestaurants =
                            restaurants.where((restaurant) {
                          bool typeMatch = widget.name == restaurant.restaurant;
                          return typeMatch;
                        }).toList();
                        return SingleReview(reviews: filteredRestaurants);
                      })

          ],
        ),
      ),
    )
    );
  }
}