import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotifikasiScreen extends StatefulWidget {
  final User? user;

  NotifikasiScreen({required this.user});

  @override
  _NotifikasiScreenState createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  List<Map<String, dynamic>> _notifikasi = [];
  double _totalPrice = 0;
  Map<String, List<Map<String, dynamic>>> _notifikasiBySeller = {};
  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _fetchNotifikasiData();
    }
  }

  double _calculateTotalPriceForPenjual(String idPenjual) {
    double totalPrice = 0.0;

    for (var notifikasi in _notifikasi) {
      if (notifikasi['idpenjual'] == idPenjual && notifikasi['price'] is num) {
        totalPrice += notifikasi['price'];
      }
    }

    return totalPrice;
  }

  void _clearCartData(String sellerName) async {
    try {
      print('Berhasil hapus ${sellerName}');
      String uid = widget.user!
          .uid; // Mendapatkan daftar produk dari keranjang belanja dengan nama penjual yang sama
      QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifikasi_pembeli')
          .doc('pembeli')
          .collection(uid)
          .where('idpenjual', isEqualTo: sellerName)
          .get();

      // Menghapus semua produk dari keranjang belanja dengan nama penjual yang sama
      for (var doc in cartSnapshot.docs) {
        await doc.reference.delete();
      }
      for (var doc in cartSnapshot.docs) {
        await doc.reference.delete();
      }

      // Mengambil data keranjang belanja terbaru
      _fetchNotifikasiData();
    } catch (e) {
      print('Terjadi kesalahan saat membersihkan data keranjang belanja: $e');
    }
  }

  void _fetchNotifikasiData() async {
    try {
      String uid = widget.user!.uid;
      QuerySnapshot notifikasiSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifikasi_pembeli')
          .doc('pembeli')
          .collection(uid)
          .get();

      List<Map<String, dynamic>> notifikasi =
          notifikasiSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['notifikasiId'] = doc.id;
        return data;
      }).toList();
      _notifikasiBySeller.clear();
      _notifikasi.clear();
      for (var notifikasi in notifikasi) {
        String sellerName = notifikasi['namapenjual'];
        if (_notifikasiBySeller.containsKey(sellerName)) {
          _notifikasiBySeller[sellerName]!.add(notifikasi);
        } else {
          _notifikasiBySeller[sellerName] = [notifikasi];
        }
      }
      setState(() {
        _notifikasi = notifikasi;
        _calculateTotalPrice();
      });
    } catch (e) {
      print('Terjadi kesalahan saat mengambil data notifikasi: $e');
    }
  }

  void _calculateTotalPrice() {
    _totalPrice = 0;
    for (var notifikasi in _notifikasi) {
      _totalPrice += notifikasi['price'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifikasi'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _notifikasiBySeller.length,
              itemBuilder: (context, index) {
                String notifikasiName =
                    _notifikasiBySeller.keys.elementAt(index);
                List<Map<String, dynamic>> notifikasiProducts =
                    _notifikasiBySeller[notifikasiName]!;
                double sellerTotalPrice =
                    _calculateTotalPriceForSeller(notifikasiProducts);

                // Cek apakah notifikasi sebelumnya memiliki idPenjual yang sama
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Penjual: $notifikasiName',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: notifikasiProducts.length,
                      itemBuilder: (context, notifikasiIndex) {
                        var notifikasi = notifikasiProducts[notifikasiIndex];
                        return ListTile(
                          title: Text(notifikasi['productName'] ?? ''),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Harga: Rp${notifikasi['price'] ?? ''}'),
                              Text('jumlah: ${notifikasi['stok'] ?? ''}'),
                              Text(
                                  'Total Harga untuk Penjual: Rp${_calculateTotalPriceForPenjual(notifikasi['idpenjual'])}'),
                              // Tambahkan data lainnya sesuai kebutuhan
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 8.0),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                  'deta belanjaan anda di penjual $notifikasiName '),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: notifikasiProducts.map((notifikas) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Nama Produk: ${notifikas['productName']}'),
                                        Text('Harga: Rp${notifikas['price']}'),
                                        Text(
                                            'jumlah: ${notifikas['stok'] ?? ''}'),
                                        Text('Alamat: ${notifikas['address']}'),
                                        Text(
                                            'Nama Penjual: ${notifikas['namapenjual']}'),
                                        Text(
                                            'Keadaan Pesanan: Proses ${notifikas['isConfirmed']}'),
                                        SizedBox(height: 8),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                              actions: [
                                Text('Total Harga: Rp$sellerTotalPrice'),
                                Text(
                                    'hapus notifikasi tidak mengubah pesanan anda'),
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

                                        for (var notifikas
                                            in notifikasiProducts) {
                                          String idPenjual =
                                              notifikas['idpenjual'];
                                          String isConfirmed = 'Barang Diantar';
                                          print(
                                              'Berhasil menambahkan notifikasi untuk produk ${notifikas['namapenjual']}');
                                          _clearCartData(idPenjual);

                                          // Membersihkan data keranjang belanja untuk penjual ini
                                        }
                                      }
                                      Navigator.pop(context);
                                      _fetchNotifikasiData();
                                    }
                                  },
                                  child: Text('hapus notifikasi'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Column(
                        children: [
                          Text('notifikasi dari Pembelian - $notifikasiName'),
                          Text('Total Harga: Rp$sellerTotalPrice'),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.0),
                  ],
                );
              },
            ),
          ),
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
