import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jll/screens/buyer/home_screen.dart';

class CartScreen extends StatefulWidget {
  final User? user;

  CartScreen({required this.user});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> _products = [];
  double _totalPrice = 0;
  bool isLoading = true;
  Map<String, List<Map<String, dynamic>>> _productsBySeller = {};
  @override
  void initState() {
    super.initState();
    _fetchCartData();
  }

  void _clearCartData(String sellerName) async {
    try {
      // Mendapatkan daftar produk dari keranjang belanja dengan nama penjual yang sama
      QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user?.uid)
          .collection('cart')
          .doc('cart_data')
          .collection('products')
          .where('namapenjual', isEqualTo: sellerName)
          .get();

      // Menghapus semua produk dari keranjang belanja dengan nama penjual yang sama
      for (var doc in cartSnapshot.docs) {
        await doc.reference.delete();
      }

      // Mengambil data keranjang belanja terbaru
      _fetchCartData();
    } catch (e) {
      print('Terjadi kesalahan saat membersihkan data keranjang belanja: $e');
    }
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, String? productId) async {
    if (productId == null) {
      print('ID Produk kosong. Tidak dapat menghapus dari keranjang.');
      return;
    }

    print('Product ID yang akan dihapus: $productId');

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Batalkan Pembelian'),
          content: Text('Apakah Anda yakin ingin menghapus produk ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.user?.uid)
                    .collection('cart')
                    .doc('cart_data')
                    .collection('products')
                    .doc(productId)
                    .delete();
                _fetchCartData();
                Navigator.of(context).pop();
              },
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _fetchCartData() async {
    QuerySnapshot productsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user?.uid)
        .collection('cart')
        .doc('cart_data')
        .collection('products')
        .get();

    List<Map<String, dynamic>> products = productsSnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['productId'] = doc.id; // Assuming the product ID is the document ID
      return data;
    }).toList();
    _productsBySeller.clear();
    _products.clear();

    for (var product in products) {
      String sellerName = product['namapenjual'];
      if (_productsBySeller.containsKey(sellerName)) {
        _productsBySeller[sellerName]!.add(product);
      } else {
        _productsBySeller[sellerName] = [product];
      }
    }

    setState(() {
      isLoading = false;
      _products = products;
      _calculateTotalPrice();
    });
  }

  void _calculateTotalPrice() {
    _totalPrice = 0;
    for (var product in _products) {
      _totalPrice += product['price'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Keranjang'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _productsBySeller.length,
              itemBuilder: (context, index) {
                String sellerName = _productsBySeller.keys.elementAt(index);
                List<Map<String, dynamic>> sellerProducts =
                    _productsBySeller[sellerName]!;
                double sellerTotalPrice =
                    _calculateTotalPriceForSeller(sellerProducts);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Penjual: $sellerName',
                        style: TextStyle(
                          fontSize: 24, // Ukuran teks lebih besar
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: sellerProducts.length,
                      itemBuilder: (context, productIndex) {
                        var product = sellerProducts[productIndex];

                        return ListTile(
                          title: Text(
                            product['productName'],
                            style: TextStyle(
                              fontSize: 18, // Ukuran teks produk lebih besar
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Price: Rp${product['price']}',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                'jumlah: ${product['stok']}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          trailing: TextButton(
                            onPressed: () async {
                              User? user = FirebaseAuth.instance.currentUser;
                              if (product['productId'] != null &&
                                  product['productId'].isNotEmpty) {
                                await _showDeleteConfirmation(
                                    context, product['productId']);
                              } else {
                                print(
                                    'Product ID is null or empty. Cannot remove from cart.');
                              }
                              _fetchCartData();
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Batal Membeli',
                                  style: TextStyle(
                                    fontSize:
                                        16, // Ukuran teks tombol lebih besar
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Icon(Icons.cancel),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 8.0),
                    ElevatedButton(
                      onPressed: () {
                        // Tampilkan popup yang berisi semua data produk milik penjual
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Data Produk - $sellerName'),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: sellerProducts.map((product) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Nama Produk: ${product['productName']}'),
                                        Text('Harga: Rp${product['price']}'),
                                        Text(
                                            'Deskripsi: ${product['description']}'),
                                        Text('Alamat: ${product['address']}'),
                                        Text(
                                            'Nama Penjual: ${product['namapenjual']}'),
                                        Text(
                                            'Nomor Telepon: ${product['phoneNumber']}'),
                                        Text('jumlah: ${product['stok']}'),
                                        SizedBox(height: 8),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                              actions: [
                                Text('Total Harga: Rp$sellerTotalPrice'),
                                Text(
                                    'Pembelian yang akan digunakan adalah bayar langsung ditempat'),
                                TextButton(
                                  onPressed: () async {
                                    User? user =
                                        FirebaseAuth.instance.currentUser;

                                    if (user != null) {
                                      String pembeliCollection = '${user.uid}';
                                      DocumentSnapshot userSnapshot =
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(user.uid)
                                              .get();

                                      if (userSnapshot.exists) {
                                        String username =
                                            userSnapshot.get('username');

                                        for (var product in sellerProducts) {
                                          String idProduct =
                                              product['productId'];
                                          String idPenjual =
                                              product['idpenjual'];
                                          String isConfirmed = 'Barang Diantar';
                                          try {
                                            // Menambahkan notifikasi ke koleksi notifikasi penjual
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(idPenjual)
                                                .collection(
                                                    'notifikasi_penjual')
                                                .doc('pembeli')
                                                .collection(idPenjual)
                                                .add({
                                              'productName':
                                                  product['productName'],
                                              'price': product['price'],
                                              'description':
                                                  product['description'],
                                              'address': product['address'],
                                              'namapenjual':
                                                  product['namapenjual'],
                                              'namapembeli': username,
                                              'idpembeli': pembeliCollection,
                                              'idpenjual': idPenjual,
                                              'idproduct': idProduct,
                                              'phoneNumber':
                                                  product['phoneNumber'],
                                              'isConfirmed': isConfirmed,
                                              'stok': product['stok'],
                                              // tambahkan data lainnya sesuai kebutuhan
                                            });

                                            print(
                                                'Berhasil menambahkan notifikasi untuk produk ${product['productName']} pada penjual');

                                            // Menambahkan notifikasi ke koleksi notifikasi pembeli
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(user.uid)
                                                .collection(
                                                    'notifikasi_pembeli')
                                                .doc('pembeli')
                                                .collection(user
                                                    .uid) // Gunakan nama koleksi pembeli dengan id user saat ini
                                                .add({
                                              'productName':
                                                  product['productName'],
                                              'price': product['price'],
                                              'description':
                                                  product['description'],
                                              'address': product['address'],
                                              'namapenjual':
                                                  product['namapenjual'],
                                              'idpenjual': idPenjual,
                                              'idpembeli': user.uid,
                                              'idproduct': idProduct,
                                              'namapembeli': username,
                                              'phoneNumber':
                                                  product['phoneNumber'],
                                              'isConfirmed': isConfirmed,
                                              'stok': product['stok'],
                                              // tambahkan data lainnya sesuai kebutuhan
                                            });

                                            print(
                                                'Berhasil menambahkan notifikasi untuk pembeli ${product['productName']}');
                                            _clearCartData(
                                                product['namapenjual']);
                                          } catch (e) {
                                            print(
                                                'Terjadi kesalahan saat menambahkan notifikasi untuk produk ${product['productName']}: $e');
                                          }
                                        }
                                      } else {
                                        print(
                                            'User tidak terautentikasi atau belum login');
                                      }
                                    }
                                    Navigator.pop(context);
                                    _fetchCartData();
                                  },
                                  child: Text('barang diantar'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    User? user =
                                        FirebaseAuth.instance.currentUser;

                                    if (user != null) {
                                      String pembeliCollection = '${user.uid}';
                                      DocumentSnapshot userSnapshot =
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(user.uid)
                                              .get();

                                      if (userSnapshot.exists) {
                                        String username =
                                            userSnapshot.get('username');

                                        for (var product in sellerProducts) {
                                          String idProduct =
                                              product['productId'];
                                          String idPenjual =
                                              product['idpenjual'];
                                          String isConfirmed = 'Barang Diambil';

                                          try {
                                            // Menambahkan notifikasi ke koleksi notifikasi penjual
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(idPenjual)
                                                .collection(
                                                    'notifikasi_penjual')
                                                .doc('pembeli')
                                                .collection(idPenjual)
                                                .add({
                                              'productName':
                                                  product['productName'],
                                              'price': product['price'],
                                              'description':
                                                  product['description'],
                                              'address': product['address'],
                                              'namapenjual':
                                                  product['namapenjual'],
                                              'namapembeli': username,
                                              'idpembeli': pembeliCollection,
                                              'idpenjual': idPenjual,
                                              'idproduct': idProduct,
                                              'phoneNumber':
                                                  product['phoneNumber'],
                                              'isConfirmed': isConfirmed,
                                              'stok': product['stok'],
                                              // tambahkan data lainnya sesuai kebutuhan
                                            });

                                            print(
                                                'Berhasil menambahkan notifikasi untuk produk ${product['productName']} pada penjual');

                                            // Menambahkan notifikasi ke koleksi notifikasi pembeli
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(user.uid)
                                                .collection(
                                                    'notifikasi_pembeli')
                                                .doc('pembeli')
                                                .collection(user
                                                    .uid) // Gunakan nama koleksi pembeli dengan id user saat ini
                                                .add({
                                              'productName':
                                                  product['productName'],
                                              'price': product['price'],
                                              'description':
                                                  product['description'],
                                              'address': product['address'],
                                              'namapenjual':
                                                  product['namapenjual'],
                                              'idpenjual': idPenjual,
                                              'idpembeli': user.uid,
                                              'namapembeli': username,
                                              'idproduct': idProduct,
                                              'phoneNumber':
                                                  product['phoneNumber'],
                                              'isConfirmed': isConfirmed,
                                              'stok': product['stok'],
                                              // tambahkan data lainnya sesuai kebutuhan
                                            });

                                            print(
                                                'Berhasil menambahkan notifikasi untuk produk ${product['productName']}');
                                            _clearCartData(
                                                product['namapenjual']);
                                          } catch (e) {
                                            print(
                                                'Terjadi kesalahan saat menambahkan notifikasi untuk produk ${product['productName']}: $e');
                                          }
                                        }
                                      } else {
                                        print(
                                            'User tidak terautentikasi atau belum login');
                                      }
                                    }
                                    Navigator.pop(context);

                                    _fetchCartData();
                                  },
                                  child: Text('ambil sendiri'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Column(
                        children: [
                          Text(
                            'Pembelian dari - $sellerName',
                            style: TextStyle(
                              fontSize: 18, // Ukuran teks lebih besar
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Seharga: Rp$sellerTotalPrice',
                            style: TextStyle(
                              fontSize: 18, // Ukuran teks lebih besar
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.0),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: 16.0),
          SizedBox(height: 16.0),
        ],
      ),
    );
  }

  double _calculateTotalPriceForSeller(
      List<Map<String, dynamic>> sellerProducts) {
    double totalPrice = 0;
    for (var product in sellerProducts) {
      double price =
          product['price'] ?? 0.0; // Harga produk (jika null, gunakan 0)
      int stok = product['stok'] ?? 0; // Stok produk (jika null, gunakan 0)
      totalPrice += price * stok;
    }
    return totalPrice;
  }
}
