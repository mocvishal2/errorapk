import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jll/services/firestore_service.dart';
import 'package:jll/models/user.dart';

class AddProductScreen extends StatefulWidget {
  final User? user;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AddProductScreen({required this.user});

  @override
  _AddProductScreenState createState() => _AddProductScreenState(user: user);
}

class _AddProductScreenState extends State<AddProductScreen> {
  final User? user;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController ProductNameController = TextEditingController();
  TextEditingController PriceController = TextEditingController();
  TextEditingController DescriptionController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController namapenjualController = TextEditingController();
  TextEditingController stokController = TextEditingController();
  _AddProductScreenState({required this.user});

  // Implementasi Stateful widget diletakkan di sini
  String? validateStok(String value) {
    if (value.isEmpty) {
      return 'Jumlah stok tidak boleh kosong';
    }

    int stokValue = int.tryParse(value) ?? 0;
    if (stokValue > 10) {
      return 'Jumlah stok tidak boleh melebihi 10';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: ProductNameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: PriceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: stokController,
              decoration: InputDecoration(labelText: 'stok'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: DescriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                String productName = ProductNameController.text;
                double price = double.parse(PriceController.text);
                String description = DescriptionController.text;
                String userId = user?.uid ?? '';
                int stok = int.parse(stokController.text);
                // TODO: Add product to seller's list
                DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .get();
                if (userSnapshot.exists) {
                  String address = userSnapshot['address'] ??
                      ''; // Menggunakan operator '??' untuk menangani jika data tidak ada
                  String phoneNumber = userSnapshot['phoneNumber'] ??
                      ''; // Menggunakan operator '??' untuk menangani jika data tidak ada
                  String namapenjual = userSnapshot['username'] ?? '';

                  // TODO: Lakukan sesuatu dengan alamat dan nomor telepon
                  await FirebaseFirestore.instance
                      .collection('users') // Koleksi "users"
                      .doc(user?.uid) // Dokumen user saat ini
                      .collection(
                          'products') // Koleksi "products" di bawah dokumen user
                      .add({
                    'productName': productName,
                    'price': price,
                    'description': description,
                    'address': address,
                    'phoneNumber': phoneNumber,
                    'namapenjual': namapenjual,
                    'idpenjual': userId,
                    'stok': stok,

                    // Tambahan informasi produk lainnya sesuai kebutuhan
                  });

                  // Menampilkan snackbar atau pesan sukses
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Product added successfully')),
                  );

                  // Reset nilai controller setelah menambahkan produk
                  ProductNameController.clear();
                  PriceController.clear();
                  DescriptionController.clear();
                  addressController.clear();
                  phoneNumberController.clear();
                  namapenjualController.clear();
                } else {
                  // Dokumen user tidak ditemukan, mungkin ada tindakan yang ingin Anda lakukan dalam kasus ini
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Pendaftaran gagal. Silakan coba lagi.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
