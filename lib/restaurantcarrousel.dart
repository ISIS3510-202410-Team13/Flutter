import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'mapView.dart';


class Restaurant {
  final String name;
  final String imageUrl;
  final String description;

  Restaurant({
    required this.name,
    required this.imageUrl,
    required this.description,
  });
}

class RestaurantCarousel extends StatelessWidget {
  // Lista de restaurantes

  

  final List<Restaurant> restaurants;

  // Constructor
  RestaurantCarousel({required this.restaurants});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 300.0, // Altura del carrusel
        enableInfiniteScroll: true, // Habilita el desplazamiento infinito
        autoPlay: true, // Habilita la reproducción automática
      ),
      items: restaurants.map((restaurant) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              child: Card(
                elevation: 4.0, // Elevación de la tarjeta
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Bordes redondeados
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Imagen del restaurante
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                      child: Image.network(
                        restaurant.imageUrl,
                        height: 150.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Nombre del restaurante
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        restaurant.name,
                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Descripción del restaurante
                    Flexible(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        restaurant.description,
                        style: TextStyle(fontSize: 13.0),
                      ),
                    )
                    ),
                    // Botón para ver el restaurante en el mapa
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Aquí puedes implementar la navegación al mapa o cualquier acción que desees
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MapView()),
                          );
                        },
                        child: Text('Ver en el mapa'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}