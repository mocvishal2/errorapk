import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jll/models/product.dart';
import 'package:jll/screens/buyer/notifikasi.dart';
import 'package:jll/screens/buyer/product_details_screen.dart';
import 'package:jll/screens/buyer/cart_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:jll/widgets/drawer.dart';
import 'package:jll/models/user.dart';
import 'package:jll/screens/authentication/SigninPage.dart';
import 'package:jll/services/firestore_service.dart';

class BuyerHomeScreen extends StatefulWidget {
  final User? user;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  BuyerHomeScreen({required this.user});
  @override
  _BuyerHomeScreenState createState() =>
      _BuyerHomeScreenState(user: FirebaseAuth.instance.currentUser);
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  late CollectionReference _productsCollection;
  List<Product> productList = [];
  final User? user;
  bool hasNewNotifications = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  _BuyerHomeScreenState({required this.user});

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchNotifications();
  }

  void _fetchNotifications() async {
    String uid = user!.uid;
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();

      for (var userDoc in querySnapshot.docs) {
        QuerySnapshot notificationSnapshot = await _firestore
            .collection('users')
            .doc(uid)
            .collection('notifikasi_pembeli')
            .doc('pembeli')
            .collection(uid)
            .get();
        int newNotificationsCount = 0;

        for (var notificationDoc in notificationSnapshot.docs) {
          Map<String, dynamic>? notificationData =
              notificationDoc.data() as Map<String, dynamic>?;

          // Pastikan notificationData tidak null sebelum mengaksesnya
          if (notificationData != null && notificationData['isNew'] == true) {
            newNotificationsCount++;
          }
        }

        setState(() {
          hasNewNotifications = newNotificationsCount > 0;
        });
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  void _fetchProducts() async {
    try {
      print('Fetching products...');
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();

      List<Product> products = [];

      for (var userDoc in querySnapshot.docs) {
        String userId = userDoc.id;
        print('Fetching products for user: $userId');

        QuerySnapshot productsSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('products')
            .get();

        for (var productDoc in productsSnapshot.docs) {
          Map<String, dynamic>? productData =
              productDoc.data() as Map<String, dynamic>?;
          if (productData != null) {
            Product product = Product(
              id: productDoc.id,
              productName: productData['productName'] ?? '',
              namapenjual: productData['namapenjual'] ?? '',
              price: productData['price'] ?? '',
              description: productData['description'] ?? '',
              address: productData['address'] ?? '',
              phoneNumber: productData['phoneNumber'] ?? '',
              idpenjual: productData['idpenjual'] ?? '',
              stok: productData['stok'] ?? '',
            );
            products.add(product);
            print('Product added: ${product.productName}');
          }
        }
      }

      setState(() {
        productList = products;
      });

      print('Fetching products completed.');
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  List<String> selectedProductIds = [];

  @override
  Widget build(BuildContext context) {
    // Implementasi UI halaman beranda pembeli
    // Misalnya, daftar produk ditampilkan dalam ListView.builder
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              // TODO: Pindah ke halaman keranjang
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(
                    user: user,
                  ), // Ganti dengan halaman keranjang yang sesuai
                ),
              );
            },
          ),
          IconButton(
            icon: hasNewNotifications
                ? Icon(
                    Icons.notifications_active) // Icon dengan notifikasi aktif
                : Icon(Icons.notifications), // Ikon default
            onPressed: () {
              // TODO: Pindah ke halaman keranjang
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotifikasiScreen(
                    user: user,
                  ), // Ganti dengan halaman keranjang yang sesuai
                ),
              );
            },
          ),
        ],
      ),
      drawer: CustomDrawer(user: user),
      body: ListView.builder(
        itemCount: productList.length,
        itemBuilder: (context, index) {
          Product product = productList[index];
          bool isSelected = selectedProductIds.contains(product.id);

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailsScreen(
                    product: product,
                    user: user,
                  ),
                ),
              );
            },
            child: ListTile(
              title: Text(
                product.productName,
                style: TextStyle(
                  fontSize: 18, // Increase the font size as desired
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Penjual: ${product.namapenjual}',
                    style: TextStyle(
                      fontSize: 16, // Ukuran teks tombol lebih besar
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Harga: Rp ${product.price}',
                    style: TextStyle(
                      fontSize: 16, // Ukuran teks tombol lebih besar
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(product.description),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
