import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jll/screens/authentication/SignInPage.dart';
import 'package:jll/screens/authentication/signup_screen.dart';
import 'package:jll/screens/buyer/home_screen.dart';
import 'package:jll/screens/buyer/product_details_screen.dart';
import 'package:jll/screens/buyer/cart_screen.dart';
import 'package:jll/screens/home.dart';
import 'package:jll/screens/seller/home_screen.dart';
import 'package:jll/screens/seller/add_product_screen.dart';
import 'package:jll/screens/seller/manage_products_screen.dart';
import 'package:jll/screens/authentication/SignUpPage.dart';
import 'package:jll/screens/authentication/SignInPage.dart';

class Routes {
  static const String signin = '/signin';
  static const String signup = '/signup';
  static const String homeBuyer = '/home/buyer';
  static const String productDetails = '/product/details';
  static const String cart = '/cart';
  static const String homeSeller = '/home/seller';
  static const String addProduct = '/seller/product/add';
  static const String manageProducts = '/seller/products/manage';
  static const String loginpage = '/login';
  static const String homepage = '/home';

  static final Map<String, WidgetBuilder> routes = {
    signin: (context) => SignInPage(),
    signup: (context) => SignUpPage(),
    homeBuyer: (context) =>
        BuyerHomeScreen(user: FirebaseAuth.instance.currentUser),
    loginpage: (context) => SignUpScreen(),
    //   homepage: (context) => HomePage(user: FirebaseAuth.instance.currentUser),
    homeSeller: (context) =>
        SellerHomeScreen(user: FirebaseAuth.instance.currentUser),
    addProduct: (context) =>
        AddProductScreen(user: FirebaseAuth.instance.currentUser),

//    manageProducts: (context) => ManageProductsScreen(),
  };
}
