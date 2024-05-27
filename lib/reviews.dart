import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
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

  static Review fromJson(String json) {
    Map<String, dynamic> data = jsonDecode(json);
    return Review(
      restaurant: data['restaurant'],
      text: data['text'],
      user: data['user'],
    );
  }

}

class _ReviewsState extends State<Reviews> {

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/restaurants.txt');
}

Future<File> writeCounter(String data) async {
  final file = await _localFile;

  return file.writeAsString(data);
}

hasConnection() async{

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    return true;

  }

Future<List<Review>> readCounter() async {
  try {
    final file = await _localFile;

    // Read the file
    final contents = await file.readAsString();

    List<Review> retornable = [];

    List<dynamic> data = jsonDecode(contents);
    for (var i = 0; i < data.length; i++) {
      retornable.add(Review.fromJson(jsonEncode(data[i])));
    }

    return retornable;
  }
  catch (e) {
    // If encountering an error, return 0
    return [];
  }
}

Future<Widget> getWirget() async{
  if (await hasConnection()) {
          return Image.network(
            widget.url ?? "",
            width: 200,
            height: 200,
          );
        } else {
          return Image.asset(
            'assets/images/image (${Random().nextInt(5) + 1}).png',
            width: 200,
            height: 200,
          );
        }
}

  @override
  Widget build(BuildContext context){
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

        FutureBuilder<Widget>(
          future: getWirget(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            return snapshot.data ?? Container();
          },
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
                        List<Review> reviews = [];
                        if (!snapshot.hasError) {
                          reviews =
                            snapshot.data!.docs.map((doc) {
                          return Review(
                            restaurant: doc['restaurant'],
                            text: doc['text'],
                            user: doc['user'],
                          );
                        }).toList();
                        }else{
                          readCounter().then((value) {
                            reviews = value;
                          });
                        }
                        
                      
                        // Convert the list of restaurants to JSON
                        final restaurantsJson = jsonEncode(reviews);
                        
                        writeCounter(restaurantsJson);
                        // Write the JSON data to a file

                        List<Review> filteredRestaurants =
                            reviews.where((restaurant) {
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