import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:test_drive/reviews.dart';
import 'mapView.dart';

class Restaurant {
  final String name;
  final String imageUrl;
  final String description;
  final double lat;
  final double long;
  final String type;
  final String price;

  Restaurant({
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.lat,
    required this.long,
    required this.type,
    required this.price,
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
        height: 150.0, // Altura del carrusel (la mitad de 300.0)
        enableInfiniteScroll: true, // Habilita el desplazamiento infinito
        autoPlay: false, // Habilita la reproducción automática
      ),
      items: restaurants.map((restaurant) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width * 0.8, // Ajuste del ancho de la tarjeta
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
                        height: 75.0, // La mitad de la altura de la imagen original
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Nombre del restaurante
                    Padding(
                      padding: EdgeInsets.all(4.0), // Reducir el padding
                      child: Text(
                        restaurant.name,
                        style: TextStyle(fontSize: 9.0, fontWeight: FontWeight.bold), // Reducir el tamaño de fuente
                      ),
                    ),
                    // Descripción del restaurante
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0), // Reducir el padding
                        child: Text(
                          restaurant.description,
                          style: TextStyle(fontSize: 6.5), // Reducir el tamaño de fuente
                          overflow: TextOverflow.ellipsis, // Agregar para evitar desbordamiento de texto
                          maxLines: 3, // Limitar el número de líneas para evitar desbordamiento de texto
                        ),
                      ),
                    ),
                    // Botón para ver el restaurante en el mapa
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(4.0), // Reducir el padding
                          child: ElevatedButton(
                            onPressed: () {
                              // Aquí puedes implementar la navegación al mapa o cualquier acción que desees
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MapView(lat: restaurant.lat, long: restaurant.long)),
                              );
                            },
                            child: Text('Ver en el mapa', style: TextStyle(fontSize: 9.0)), // Reducir el tamaño de fuente
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(4.0), // Reducir el padding
                          child: ElevatedButton(
                            onPressed: () {
                              // Aquí puedes implementar la navegación al mapa o cualquier acción que desees
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Reviews(name: restaurant.name, url: restaurant.imageUrl)),
                              );
                            },
                            child: Text('Reseñas', style: TextStyle(fontSize: 9.0)), // Reducir el tamaño de fuente
                          ),
                        ),
                      ],
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
