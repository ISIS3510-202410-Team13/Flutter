import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';


class ProfilePage extends StatefulWidget {

  const ProfilePage({Key? key,
  required this.user}) : super(key: key);

  final String user;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  SharedPreferences? _prefs;

  String _email = '';

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _email = _prefs?.getString('displayUsername') ?? '';
    
  }

  void doLogout() async {
    await _prefs?.remove('displayUsername');
    await _prefs?.setBool("isLoggedIn", false);
    Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/user${Random().nextInt(4) + 1}.png'),
            ),
            SizedBox(height: 20),
            Text(
              widget.user,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                doLogout();
              },
              child: Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
