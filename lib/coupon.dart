import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Para formatear fechas
import 'dart:convert';

class CouponPage extends StatefulWidget {
  @override
  _CouponPageState createState() => _CouponPageState();
}

class _CouponPageState extends State<CouponPage> {
  @override
  void initState() {
    super.initState();
    _updateCouponCache();
  }

  Future<void> _updateCouponCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedCoupons = prefs.getString('coupons');

    if (cachedCoupons != null) {
      List<dynamic> coupons = jsonDecode(cachedCoupons);
      bool needsUpdate = false;

      for (var coupon in coupons) {
        if (_isCouponExpired(coupon['end_date'])) {
          needsUpdate = true;
          break;
        }
      }

      if (!needsUpdate) {
        setState(() {});
        return;
      }
    }

    FirebaseFirestore.instance
        .collection('coupons')
        .snapshots()
        .listen((snapshot) async {
      List<Map<String, dynamic>> coupons = snapshot.docs.map((doc) {
        return {
          'id': doc['id'],
          'description': doc['description'],
          'end_date': doc['end_date'],
          'is_public': doc['is_public'],
          'is_valid': doc['is_valid'],
          'restaurant': doc['restaurant'],
        };
      }).toList();

      await prefs.setString('coupons', jsonEncode(coupons));
      setState(() {});
    });
  }

  bool _isCouponExpired(String endDate) {
    final DateFormat formatter = DateFormat('dd/MM/yy');
    final DateTime expirationDate = formatter.parse(endDate);
    final DateTime now = DateTime.now();
    return expirationDate.isBefore(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('U. de los Andes'),
        backgroundColor: Colors.orange,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Menú'),
              decoration: BoxDecoration(
                color: Colors.orange,
              ),
            ),
            ListTile(
              title: Text('Item 1'),
              onTap: () {
                // Handle the tap here.
              },
            ),
            ListTile(
              title: Text('Item 2'),
              onTap: () {
                // Handle the tap here.
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                labelText: 'Ingresa tu Cupón',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Validate coupon here
              },
              child: Text('Validar'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
            SizedBox(height: 20),
            DefaultTabController(
              length: 2,
              child: Expanded(
                child: Column(
                  children: <Widget>[
                    TabBar(
                      labelColor: Colors.orange,
                      unselectedLabelColor: Colors.black,
                      tabs: [
                        Tab(text: 'Disponibles'),
                        Tab(text: 'Vencidos'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          CouponList(isValid: true),
                          CouponList(isValid: false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CouponList extends StatefulWidget {
  final bool isValid;

  CouponList({required this.isValid});

  @override
  _CouponListState createState() => _CouponListState();
}

class _CouponListState extends State<CouponList> {
  List<Map<String, dynamic>> coupons = [];

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedCoupons = prefs.getString('coupons');

    if (cachedCoupons != null) {
      List<dynamic> decodedCoupons = jsonDecode(cachedCoupons);
      List<Map<String, dynamic>> filteredCoupons = decodedCoupons
          .where((coupon) =>
              coupon['is_valid'] == widget.isValid &&
              (!_isCouponExpired(coupon['end_date']) || !widget.isValid))
          .map((coupon) => Map<String, dynamic>.from(coupon))
          .toList();

      setState(() {
        coupons = filteredCoupons;
      });
    }
  }

  bool _isCouponExpired(String endDate) {
    final DateFormat formatter = DateFormat('dd/MM/yy');
    final DateTime expirationDate = formatter.parse(endDate);
    final DateTime now = DateTime.now();
    return expirationDate.isBefore(now);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: coupons.length,
      itemBuilder: (context, index) {
        final coupon = coupons[index];
        final String endDate = coupon['end_date'];
        final bool isExpired = _isCouponExpired(endDate);

        return Card(
          child: ListTile(
            title: Text(coupon['description']),
            subtitle: Text(
                'Válido hasta: $endDate \nRestaurante: ${coupon['restaurant']}'),
            trailing: ElevatedButton(
              onPressed: isExpired ? null : () => _showQRBottomSheet(context),
              // Desactivar el botón si el cupón está vencido
              child: Text('Usar Cupón'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
          ),
        );
      },
    );
  }

  void _showQRBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Código QR"),
              SizedBox(height: 10),
              Image.asset(
                'assets/images/qr-image.jpeg'), // Reemplaza 'assets/qr_code.png' con la ruta de tu imagen de código QR
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cerrar'),
              ),
            ],
          ),
        );
      },
    );
  }
}
