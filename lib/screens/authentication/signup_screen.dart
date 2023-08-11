import 'package:flutter/material.dart';
import 'package:jll/screens/authentication/SignInPage.dart';
import 'package:jll/services/authentication_service.dart';
import 'package:jll/screens/authentication/SignUpPage.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final AuthenticationService _authenticationService = AuthenticationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Masuk'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TextField untuk masukkan displayName, email, dan password (seperti sebelumnya)
            // ...

            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignInPage()),
                ); // Metode SignInWithEmailAndPassword (seperti sebelumnya)
              },
              child: Text(
                'Masuk',
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              "Belum punya akun? Mendaftar!",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SignUpPage()), // Metode SignUpWithEmailAndPassword (seperti sebelumnya)
                );
              },
              child: Text(
                'Mendaftar',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
