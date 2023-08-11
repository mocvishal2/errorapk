import 'package:jll/models/product.dart';
import 'package:jll/models/user.dart';

class Order {
  final String id;
  final UserModel user;
  final Product product;
  final int quantity;
  final double totalAmount;
  final DateTime timestamp;

  Order({
    required this.id,
    required this.user,
    required this.product,
    required this.quantity,
    required this.totalAmount,
    required this.timestamp,
  });
}
