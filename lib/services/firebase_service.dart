import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  final DatabaseReference _userRef =
  FirebaseDatabase.instance.reference().child('users');

  Future<Map<String, dynamic>?> fetchUserData(String uid) async {
    try {
      final DatabaseEvent event = await _userRef.child(uid).once();
      final DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null && snapshot.value is Map<dynamic, dynamic>) {
        return (snapshot.value as Map<dynamic, dynamic>)
            .cast<String, dynamic>();
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, String>> loadLinks(String userId) async {
    try {
      final DatabaseEvent event =
      await _userRef.child(userId).child('links').once();
      final DataSnapshot snapshot = event.snapshot;

      final Map<String, String> links = {};
      final dynamic data = snapshot.value;
      if (data != null && data is Map<dynamic, dynamic>) {
        links.addAll(Map<String, String>.from(data.cast<String, dynamic>()));
      }

      return links;
    } catch (e) {
      return {};
    }
  }

  Future<void> fetchImageUrl() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }

      final storage = FirebaseStorage.instance;
      final Reference ref =
      storage.ref().child('users/${user.uid}/profile.jpg');

      final String? imageUrl = await ref.getDownloadURL();

      // Handle the imageUrl, e.g., update state or return it
    } catch (e) {
      print('Error fetching image URL: $e');
      // Handle the error, e.g., update state or log it
    }
  }

  // Add other Firebase-related functions here as needed

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Sign-out successful
    } catch (e) {
      print('Error signing out: $e');
      // Handle the error, e.g., show an error message
    }
  }
}
