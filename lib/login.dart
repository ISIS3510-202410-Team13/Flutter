

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:test_drive/global/common/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_drive/body.dart';
import 'package:test_drive/main.dart';
import 'package:test_drive/user_auth/firebase_auth.dart';
import 'mapView.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _user = "";
  String _pass = ""; 

  final FirebaseAuthService _auth = FirebaseAuthService();
  
  final _formkey= GlobalKey<FormState>();

  TextEditingController useremailcontroller = new TextEditingController();
  TextEditingController userpasswordcontroller = new TextEditingController();


  @override
  void initState() {
    checkCache();
    super.initState();
  }
    userLogin() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _user, password: _pass);
          Navigator.push(context, MaterialPageRoute(builder: (context)=> const MapView(lat: 0, long: 0,)));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          "No User Found for that Email",
          style: TextStyle(fontSize: 18.0, color: Colors.black),
        )));
      }else if(e.code=='wrong-password'){
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          "Wrong Password Provided by User",
          style: TextStyle(fontSize: 18.0, color: Colors.black),
        )));
      }
    }
  }
  
  checkCache() async {
    _auth.signUpWithEmailAndPassword("", "");
    showToast(message: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? check = prefs.getBool("registroPendiente");
    if (check != null) {
      if (!check) {
        showToast(message: "No hay registro pendiente.");
        return;
      }
    }
    String? email = prefs.getString("emailRegistro");
    String? password = prefs.getString("passwordRegistro");
    await prefs.setBool("registroPendiente", false);

    showToast(message: "Registrando...");
    User? user = await _auth.signUpWithEmailAndPassword(email!, password!);

    if (user != null) {
      showToast(message: "User is successfully created");
    } else {
      showToast(message: "Some error happend");
    }

    await prefs.remove("emailRegistro");
    await prefs.remove("passwordRegistro");
    
  }

  void showToast({required String message}){
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 16.0
  );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    
    
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Center(child: Text(widget.title)),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Column(
            key: _formkey,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Inicia Sesión',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              
              const SizedBox(height: 16),
               Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: TextFormField(
                  controller: useremailcontroller,
                  validator: (value){
                    if(value==null || value.isEmpty){
                      return "Please Enter Email";
                    }
                    return null;
                  
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Correo Electrónico',
                  ),
                ),
              ),
               Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: TextFormField(
                  controller: userpasswordcontroller,
                  validator: (value){
                    if(value==null || value.isEmpty){
                      return "Please Enter Email";
                    }
                    return null;
                  
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Contraseña',
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'No tienes una cuenta? Regístrate',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await checkCache();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>  HomeScreen(restaurants: [],)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Inicia Sesión'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
