import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserDataService {
  final DatabaseReference _userRef =
  FirebaseDatabase.instance.reference().child('users');

  Future<Map<String, dynamic>?> fetchUserData(String uid) async {
    DatabaseReference userRef =
    FirebaseDatabase.instance.reference().child('users').child(uid);

    try {
      // Wait for the event to complete and extract the DataSnapshot
      DatabaseEvent event = await userRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null && snapshot.value is Map<dynamic, dynamic>) {
        // Return the snapshot value as a Map<String, dynamic>
        return (snapshot.value as Map<dynamic, dynamic>)
            .cast<String, dynamic>();
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<String?> getProfileImageUrlStream() {
    final User? user = FirebaseAuth.instance.currentUser;
    return FirebaseDatabase.instance
        .ref()
        .child('users/${user?.uid}/imageUrl')
        .onValue
        .map((event) => event.snapshot.value as String?);
  }


  // Future<String?> fetchImageUrl() async {
  //   try {
  //     final User? user = FirebaseAuth.instance.currentUser;
  //     final storage = FirebaseStorage.instance;
  //     final Reference ref =
  //     storage.ref().child('users/${user?.uid}/profile.jpg');
  //
  //     String? imageUrl = await ref.getDownloadURL();
  //     return imageUrl; // Return the fetched imageUrl
  //   } catch (e) {
  //     print('Error fetching image URL: $e');
  //     return null;
  //   }
  // }
}
