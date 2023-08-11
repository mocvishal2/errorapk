import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Metode untuk mendapatkan data profil pengguna berdasarkan userID
  Future<UserProfile> getUserProfile(String userID) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users').doc(userID).get();
      if (snapshot.exists) {
        // Jika data ditemukan, kembalikan objek UserProfile
        return UserProfile.fromFirestore(snapshot);
      } else {
        // Jika data tidak ditemukan, kembalikan objek UserProfile kosong dengan nilai default
        return UserProfile(id: '', name: '', email: '');
      }
    } catch (e) {
      // Tangani kesalahan jika terjadi dan kembalikan objek UserProfile kosong dengan nilai default
      print('Error getting user profile: $e');
      return UserProfile(id: '', name: '', email: '');
    }
  }
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  // Tambahkan properti lain yang dibutuhkan

  UserProfile({required this.id, required this.name, required this.email});

  // Metode untuk mengambil data dari Firestore dan membuat objek UserProfile
  factory UserProfile.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!;
    return UserProfile(
      id: doc.id,
      name: data['name'],
      email: data['email'],
      // Inisialisasi properti lain yang dibutuhkan
    );
  }
}
