import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jll/models/product.dart';

import 'cart_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;
  final User? user;

  ProductDetailsScreen({required this.product, required this.user});
  TextEditingController stokController = TextEditingController();
  String? validateStok(String value, int maxStok) {
    if (value.isEmpty) {
      return 'Jumlah stok tidak boleh kosong';
    }

    int stokValue = int.tryParse(value) ?? 0;
    if (stokValue <= 0) {
      return 'Jumlah stok tidak boleh bernilai 0';
    }

    if (stokValue > maxStok) {
      return 'Jumlah stok tidak boleh melebihi $maxStok';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.productName),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama Penjual: ${product.namapenjual}'),
            SizedBox(height: 16.0),
            Text('Description: ${product.description}'),
            SizedBox(height: 16.0),
            Text('Price: \$${product.price}'),
            SizedBox(height: 16.0),
            Text('nomer Hp penjual: ${product.phoneNumber}'),
            SizedBox(height: 16.0),
            Text('alamat penjual : ${product.address}'),
            SizedBox(height: 16.0),
            Text('maksimal barang : ${product.stok}'),
            SizedBox(height: 16.0),
            TextField(
              controller: stokController,
              decoration:
                  InputDecoration(labelText: 'barang yang anda inginkan '),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () async {
                if (stokController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Jumlah stok tidak boleh kosong')),
                  );
                  return;
                }

                int stokpesanan = int.parse(stokController.text);
                if (stokpesanan <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Jumlah stok tidak boleh kurang dari atau sama dengan 0')),
                  );
                  return;
                }

                if (stokpesanan > product.stok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Jumlah stok melebihi maksimal')),
                  );
                  return;
                }

                print('stok $stokpesanan');

                print('stok $stokpesanan');
                // Mendapatkan referensi dokumen pengguna (user)
                DocumentReference userDocRef = FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid);

                // Mengecek apakah koleksi "cart" sudah ada dalam dokumen pengguna
                bool isCartExists = await userDocRef
                    .collection('cart')
                    .doc('cart_data')
                    .get()
                    .then((snapshot) => snapshot.exists);

                // Jika koleksi "cart" belum ada, maka membuatnya
                if (!isCartExists) {
                  await userDocRef.collection('cart').doc('cart_data').set({});
                }

                // Menambahkan produk ke dalam koleksi "cart"
                userDocRef
                    .collection('cart')
                    .doc('cart_data')
                    .collection('products')
                    .add({
                  'productName': product.productName,
                  'price': product.price,
                  'description': product.description,
                  'address': product.address,
                  'namapenjual': product.namapenjual,
                  'phoneNumber': product.phoneNumber,
                  'idpenjual': product.idpenjual,
                  'stok': stokpesanan,

                  // Tambahkan field lain yang Anda perlukan
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Produk ditambahkan ke keranjang')),
                );
              },
              child: Text('Tambahkan ke Keranjang'),
            ),
          ],
        ),
      ),
    );
  }
}
