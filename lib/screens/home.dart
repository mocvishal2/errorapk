import 'package:flutter/material.dart';
import 'package:jll/models/user.dart';
import 'package:jll/screens/authentication/SigninPage.dart';
import 'package:jll/screens/buyer/home_screen.dart'; // Ganti dengan halaman Buyer Home
import 'package:jll/screens/seller/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jll/services/firestore_service.dart';

class HomePage extends StatelessWidget {
  final User? user;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  HomePage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection('users').doc(user!.uid).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }
            var userData = UserModel.fromMap(
                snapshot.data!.data() as Map<String, dynamic>);
            print("Snapshot Data: ${snapshot.data?.data()}");
            print("User Data: ${userData.username}");
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Welcome ${userData.username}'),
                SizedBox(height: 20),
                Text('Email: ${user!.email}')
              ],
            );
          },
        ),
      ),
    );
  }
}
