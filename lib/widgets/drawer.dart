import 'package:flutter/material.dart';
import 'package:jll/models/user.dart';
import 'package:jll/routes.dart';
import 'package:jll/screens/authentication/SigninPage.dart';
import 'package:jll/screens/buyer/home_screen.dart'; // Ganti dengan halaman Buyer Home
import 'package:jll/screens/seller/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jll/services/firestore_service.dart';

class CustomDrawer extends StatelessWidget {
  final User? user;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CustomDrawer({required this.user});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${userData.username}',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                );
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.add_business_sharp),
            title: Text('Beli'),
            onTap: () {
              // TODO: Navigate to profile page or show profile information here
              Navigator.pushReplacementNamed(
                  context, Routes.homeBuyer); // Close the drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.add_business_sharp),
            title: Text('Toko'),
            onTap: () {
              // TODO: Navigate to settings page or handle settings action here
              Navigator.pushReplacementNamed(context, Routes.homeSeller);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
