import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:test_drive/restaurantcarrousel.dart';
//import 'package:fooddeliveryapp/pages/home.dart';
//import 'package:fooddeliveryapp/pages/order.dart';
//import 'package:fooddeliveryapp/pages/profile.dart';
//import 'package:fooddeliveryapp/pages/wallet.dart';
import 'package:test_drive/splash.dart';
import 'package:test_drive/body.dart';
import 'package:test_drive/coupon.dart';
import 'package:test_drive/profile.dart';
class BottomNav extends StatefulWidget {
  final List<Restaurant> restaurants;
  final String username;

  const BottomNav({super.key, required this.restaurants, required this.username});




  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentTabIndex = 0;

  late List<Widget> pages;
  //late Widget currentPage;
  late HomeScreen homepage;
  late CouponPage couponPage;
  late SplashScreen splash;
  //late Profile profile;
  late ProfilePage profilePage;
  //late Order order;
  //late Wallet wallet;

  @override
  void initState() {
    homepage = HomeScreen(restaurants: widget.restaurants,);
    couponPage = CouponPage();
    splash = SplashScreen();
    //order = Order();
    //profile = Profile();
    //orderPage = OrderPage();
    profilePage = ProfilePage(user: widget.username);
    //wallet = Wallet();
    pages = [homepage,couponPage, profilePage];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
          height: 65,
          backgroundColor: Colors.white,
          color: Color.fromRGBO(249, 122, 7, 1.0),
          animationDuration: Duration(milliseconds: 500),
          onTap: (int index) {
            setState(() {
              currentTabIndex = index;
            });
          },
          items: [
            Icon(
              Icons.home_outlined,
              color: Colors.white,
            ),
            Icon(
              Icons.discount,
              color: Colors.white,
            ),
            //Icon(
            //  Icons.wallet_outlined,
            //  color: Colors.white,
            //),
            Icon(
              Icons.person_outline,
              color: Colors.white,
            )
          ]),
      body: pages[currentTabIndex],
    );
  }
}