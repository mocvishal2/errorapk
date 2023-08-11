import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String productName;
  final double price;
  final String description;
  final String address;
  final String phoneNumber;
  final String namapenjual;
  final String idpenjual;
  final int stok;

  Product({
    required this.id,
    required this.productName,
    required this.price,
    required this.description,
    required this.address,
    required this.phoneNumber,
    required this.namapenjual,
    required this.idpenjual,
    required this.stok,
  });
  factory Product.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    return Product(
      productName: documentSnapshot['productName'],
      price: documentSnapshot['price'],
      description: documentSnapshot['description'],
      address: documentSnapshot['address'],
      namapenjual: documentSnapshot['namapenjual'],
      id: documentSnapshot['id'],
      phoneNumber: documentSnapshot['phoneNumber'],
      idpenjual: documentSnapshot['idpenjual'],
      stok: documentSnapshot['stok'],
    );
  }
}
