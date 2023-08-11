import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  // Metode untuk mendaftarkan pengguna dengan email dan password
  Future<void> signUpWithEmailAndPassword(
      String email, String password, String displayName) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User user = userCredential.user!;

      // Simpan data pengguna ke Firestore
      await _usersCollection.doc(user.uid).set({
        'displayName': displayName,
        'email': email,
      });
    } catch (e) {
      print('Terjadi kesalahan saat mendaftarkan pengguna: $e');
      // Di sini Anda dapat menampilkan pesan kesalahan atau melakukan penanganan kesalahan lainnya
    }
  }

  // Metode untuk masuk (login) dengan email dan password
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Terjadi kesalahan saat masuk dengan email dan password: $e');
      // Di sini Anda dapat menampilkan pesan kesalahan atau melakukan penanganan kesalahan lainnya
    }
  }

  // Metode untuk sign in dengan Google

  // Metode untuk keluar (logout)
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Terjadi kesalahan saat keluar (logout): $e');
    }
  }
}
