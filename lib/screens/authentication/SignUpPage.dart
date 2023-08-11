import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  bool _isPasswordHidden = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mendaftar'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Field untuk memasukkan username
            TextFormField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Usenama Penguna'),
            ),

            SizedBox(height: 16.0),

            // Field untuk memasukkan email
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),

            SizedBox(height: 16.0),

            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: _isPasswordHidden
                      ? Icon(Icons.visibility_off)
                      : Icon(Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _isPasswordHidden = !_isPasswordHidden;
                    });
                  },
                ),
              ),
              obscureText: _isPasswordHidden,
            ),
            SizedBox(height: 16.0),
            // Field untuk memasukkan alamat
            TextFormField(
              controller: addressController,
              decoration: InputDecoration(labelText: 'Alamat'),
              maxLines: 3, // Untuk mengizinkan lebih dari satu baris teks
            ),

            SizedBox(height: 16.0),

            // Field untuk memasukkan nomor telepon (no HP)
            TextFormField(
              controller: phoneNumberController,
              decoration: InputDecoration(labelText: 'Nomor Telepon (No HP)'),
              keyboardType: TextInputType.phone,
            ),

            SizedBox(height: 24.0),

            ElevatedButton(
              onPressed: () async {
                // Ambil nilai dari field-field yang diisi oleh pengguna
                String username = usernameController.text;
                String email = emailController.text;
                String password = passwordController.text;
                String address = addressController.text;
                String phoneNumber = phoneNumberController.text;

                // Simulasikan pendaftaran pengguna

                try {
                  // Register user dengan email dan password
                  UserCredential userCredential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                    email: email,
                    password: password,
                  );
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userCredential.user!.uid)
                      .set({
                    'username': username,
                    'email': email,
                    'address': address,
                    'phoneNumber': phoneNumber,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Pendaftaran berhasil'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  // Jika pendaftaran berhasil, arahkan ke halaman SignIn
                  Navigator.pushReplacementNamed(context, '/login2');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Pendaftaran gagal. Silakan coba lagi.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
