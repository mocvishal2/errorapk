import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jll/screens/buyer/home_screen.dart';
import 'screens/seller/home_screen.dart';
import 'models/product.dart';
import 'package:flutter/material.dart';
import 'package:jll/routes.dart';
import 'firebase_options.dart';
import 'screens/authentication/SignInPage.dart';
import 'screens/authentication/signup_screen.dart';

//import 'screens/cart_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JLL',

      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: Routes.loginpage, // Ganti dengan rute awal yang sesuai
      routes: Routes.routes,
    );
  }
}
