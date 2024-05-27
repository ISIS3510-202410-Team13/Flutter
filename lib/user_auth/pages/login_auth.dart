import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_drive/body.dart';
import 'package:test_drive/bottomnav.dart';
import 'package:test_drive/user_auth/pages/signup_auth.dart';
import 'package:test_drive/user_auth/pages/login_auth.dart';
import 'package:test_drive/global/common/toast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:test_drive/user_auth/pages/form_container_widget.dart';
import 'package:test_drive/user_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:io';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isSigning = false;
  final FirebaseAuthService _auth = FirebaseAuthService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final LocalAuthentication auth = LocalAuthentication();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final FlutterSecureStorage storage = FlutterSecureStorage();

  bool userHasTouchId = false;
  bool _useTouchId = false;


  @override
  void initState() {
    checkCache();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  void getSecureStorage() async {
    final isUsingBio = await storage.read(key: 'usingBiometric');
    setState(() {
      userHasTouchId = isUsingBio == 'true';
    });
  }
void authenticate() async {
  final canCheck = await auth.canCheckBiometrics;

  if (canCheck) {
    List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();

    if (Platform.isIOS || Platform.isAndroid) {
      if (availableBiometrics.contains(BiometricType.face)) {
        // Face ID.
        final authenticated = await auth.authenticateWithBiometrics(
            localizedReason: 'Enable Face ID to sign in more easily');
        if (authenticated) {
          final userStoredEmail = await storage.read(key: 'email');
          final userStoredPassword = await storage.read(key: 'password');

          if (userStoredEmail != null && userStoredPassword != null) {
            _signInWithEmailAndPassword(
                email: userStoredEmail, password: userStoredPassword);
          }
        }
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        // Touch ID.
        final authenticated = await auth.authenticateWithBiometrics(
            localizedReason: 'Enable Touch ID to sign in more easily');
        if (authenticated) {
          final userStoredEmail = await storage.read(key: 'email');
          final userStoredPassword = await storage.read(key: 'password');

          if (userStoredEmail != null && userStoredPassword != null) {
            _signInWithEmailAndPassword(
                email: userStoredEmail, password: userStoredPassword);
          }
        }
      }
    }
  } else {
    print("Can't check biometrics");
  }
}

void _signInWithEmailAndPassword({required String email, required String password}) async {
  User? user = await _auth.signInWithEmailAndPassword(email, password);

  if (user != null) {
    showToast(message: "User is successfully signed in");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BottomNav()),
    );
  } else {
    showToast(message: "Some error occurred");
  }
}

  checkCache() async {
    _auth.signUpWithEmailAndPassword("", "");
    //showToast(message: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? check = prefs.getBool("registroPendiente");
    if (check != null) {
      if (!check) {
        //showToast(message: "No hay registro pendiente.");
        return;
      }
    }
    String? email = prefs.getString("emailRegistro");
    String? password = prefs.getString("passwordRegistro");
    await prefs.setBool("registroPendiente", false);

    if(email == null || email.isEmpty || password == null || password.isEmpty) return;

    //showToast(message: "Registrando...");
    User? user = await _auth.signUpWithEmailAndPassword(email!, password!);

    if (user != null) {
      showToast(message: "User is successfully created");
    } else {
      showToast(message: "Some error happend");
    }

    await prefs.remove("emailRegistro");
    await prefs.remove("passwordRegistro");
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Unibites"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Inicio de Sesión",
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 30,
              ),
              FormContainerWidget(
                controller: _emailController,
                hintText: "Email",
                isPasswordField: false,
              ),
              SizedBox(
                height: 10,
              ),
              FormContainerWidget(
                controller: _passwordController,
                hintText: "Password",
                isPasswordField: true,
              ),
              SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: () {
                  _signIn();
                },
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 243, 212, 33),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: _isSigning ? CircularProgressIndicator(
                      color: Colors.white,) : Text(
                      "Iniciar Sesión",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              GestureDetector(
                onTap: () {
                  _signInWithGoogle();

                },
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FontAwesomeIcons.google, color: Colors.white,),
                        SizedBox(width: 5,),
                        Text(
                          "Inicia Sesión con Google",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),


              SizedBox(
                height: 20,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("¿No tienes cuenta?"),
                  SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                            (route) => false,
                      );
                    },
                    child: Text(
                      "Registrate",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
  onTap: () {
    _authenticateWithTouchID();
  },
  child: Container(
    width: double.infinity,
    height: 45,
    decoration: BoxDecoration(
      color: Colors.transparent,
      border: Border.all(
        color: Colors.purple,
        width: 2.0,
      ),
      borderRadius: BorderRadius.circular(30.0),
    ),
    padding: EdgeInsets.all(10.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          FontAwesomeIcons.fingerprint,
          size: 30,
        ),
        SizedBox(width: 10),
        Text(
          "Inicia Sesión con Touch ID",
          style: TextStyle(
            color: Colors.purple,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  ),
),
              userHasTouchId
                  ? InkWell(
                      onTap: () => authenticate(),
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              color: Colors.purple,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          padding: EdgeInsets.all(10.0),
                          child: Icon(
                            FontAwesomeIcons.fingerprint,
                            size: 30,
                          )),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Checkbox(
                          activeColor: Colors.orange,
                          value: _useTouchId,
                          onChanged: (newValue) {
                            setState(() {
                              _useTouchId = newValue ?? false;
                            });
                          },
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Text(
                          'Use Touch ID',
                          style: TextStyle(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            fontSize: 16.0,
                          ),
                        )
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
void _signIn() async {
  setState(() {
    _isSigning = true;
  });

  String email = _emailController.text;
  String password = _passwordController.text;

  User? user = await _auth.signInWithEmailAndPassword(email, password);

  setState(() {
    _isSigning = false;
  });

  if (user != null) {
    showToast(message: "User is successfully signed in");

    if (_useTouchId) {
      // Guardar el correo electrónico y la contraseña en el almacenamiento seguro
      await storage.write(key: 'email', value: email);
      await storage.write(key: 'password', value: password);
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BottomNav()),
    );
  } else {
    showToast(message: "Some error occurred");
  }
}

  _signInWithGoogle()async{

    final GoogleSignIn _googleSignIn = GoogleSignIn();

    try {

      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();

      if(googleSignInAccount != null ){
        final GoogleSignInAuthentication googleSignInAuthentication = await
        googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );

        await _firebaseAuth.signInWithCredential(credential);
        //Navigator.pushNamed(context, "/home");
              Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>  BottomNav()),
                        );
      }

    }catch(e) {
showToast(message: "some error occured $e");
    }


  }
  void _authenticateWithTouchID() async {
  final canCheck = await auth.canCheckBiometrics;

  if (canCheck) {
    List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();

    if (Platform.isIOS || Platform.isAndroid) {
      if (availableBiometrics.contains(BiometricType.face)) {
        // Face ID.
        final authenticated = await auth.authenticateWithBiometrics(
            localizedReason: 'Enable Face ID to sign in more easily');
        if (authenticated) {
          final userStoredEmail = await storage.read(key: 'email');
          final userStoredPassword = await storage.read(key: 'password');

          if (userStoredEmail != null && userStoredPassword != null) {
            _signInWithEmailAndPassword(
                email: userStoredEmail, password: userStoredPassword);
          }
        }
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        // Touch ID.
        final authenticated = await auth.authenticateWithBiometrics(
            localizedReason: 'Enable Touch ID to sign in more easily');
        if (authenticated) {
          final userStoredEmail = await storage.read(key: 'email');
          final userStoredPassword = await storage.read(key: 'password');

          if (userStoredEmail != null && userStoredPassword != null) {
            _signInWithEmailAndPassword(
                email: userStoredEmail, password: userStoredPassword);
          }
        }
      }
    }
  } else {
    print("Can't check biometrics");
  }
}



}