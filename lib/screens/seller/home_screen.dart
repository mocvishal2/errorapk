import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jll/models/product.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:jll/screens/seller/add_product_screen.dart';
import 'package:jll/screens/seller/manage_products_screen.dart';
import 'package:jll/widgets/drawer.dart';
import 'package:jll/models/user.dart';
import 'package:jll/screens/authentication/SigninPage.dart';
import 'package:jll/services/firestore_service.dart';

class SellerHomeScreen extends StatefulWidget {
  final User? user;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SellerHomeScreen({required this.user});

  @override
  _SellerHomeScreenState createState() => _SellerHomeScreenState(user: user);
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  final User? user;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController ProductNameController = TextEditingController();
  TextEditingController PriceController = TextEditingController();
  TextEditingController stokController = TextEditingController();
  _SellerHomeScreenState({required this.user});
  late CollectionReference _productsCollection;
  List<Product> _products = [];
  Future<void> _showDeleteConfirmation(
      BuildContext context, String productId) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Product'),
          content: Text('Are you sure you want to delete this product?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Hapus produk dari Firestore
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .collection('products')
                    .doc(productId)
                    .delete();

                Navigator.of(context).pop(); // Tutup dialog konfirmasi
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seller Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddProductScreen(user: user)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NotifikasiScreenPenjual(
                          user: user,
                        )),
              );
            },
          ),
        ],
      ),
      drawer: CustomDrawer(user: user),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('products')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Map<String, dynamic>> products = snapshot.data!.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();

            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                var product = products[index];
                return ListTile(
                  title: Text(product['productName']),
                  subtitle: Text('Harga: Rp${product['price']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Edit Produk'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextFormField(
                                        controller:
                                            PriceController, // Tambahkan field dan controller untuk edit harga produk
                                        decoration:
                                            InputDecoration(labelText: 'Harga'),
                                      ),
                                      TextField(
                                        controller: stokController,
                                        decoration:
                                            InputDecoration(labelText: 'stok'),
                                        keyboardType: TextInputType.number,
                                      ),
                                      SizedBox(height: 16.0),
                                      // Tambahkan field lain yang ingin Anda edit
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(
                                          context); // Tutup AlertDialog
                                    },
                                    child: Text('Batal'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      String productId =
                                          snapshot.data!.docs[index].id;
                                      DocumentReference productRef =
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(user?.uid)
                                              .collection('products')
                                              .doc(productId);
                                      double priceValue = double.tryParse(
                                              PriceController.text) ??
                                          0.0;
                                      await productRef.update({
                                        'price': priceValue,
                                        'stok':
                                            int.tryParse(stokController.text) ??
                                                0,

                                        // tambahkan field lain yang ingin Anda ubah
                                      }); // Tambahkan logika untuk menyimpan perubahan
                                      Navigator.pop(
                                          context); // Tutup AlertDialog setelah menyimpan
                                    },
                                    child: Text('Simpan'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          _showDeleteConfirmation(
                              context, snapshot.data!.docs[index].id);
                          // Tambahkan logika untuk menghapus produk
                          // Misalnya, tampilkan konfirmasi dialog dan hapus produk jika dikonfirmasi.
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
