import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

import '../auth/auth_util.dart';
import '../helper/toast_helper.dart';
import '../screens/edit_link_page.dart';

class UserFunctionService {
  final DatabaseReference _userRef =
  FirebaseDatabase.instance.reference().child('users');

  // Callback function to notify the parent widget (HomePage) of data changes
  final void Function() onDataChanged;

  // Callback function to update the state
  final void Function(VoidCallback) setStateCallback;

  UserFunctionService({
    required this.onDataChanged,
    required this.setStateCallback,
  });
  Future<void> launchURL(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launch(uri.toString(), forceSafariVC: false, forceWebView: false)) {
      throw "Can not launch URL";
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      // Sign-out successful
      ToastHelper.showShortToast('Sign-out successful');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthPage()),
      );
    } catch (e) {
      // Sign-out failed
      ToastHelper.showShortToast('Error, check connection');
    }
  }

  String getGreeting() {
    final currentTime = DateTime.now();
    final int hour = currentTime.hour;

    if (hour >= 0 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
// Callback function to notify the parent widget (HomePage) of data changes
  Future<void> loadLinks(User? user, DatabaseReference _userRef, Map<String, String> _links) async {
    if (user != null) {
      final userId = user.uid;
      try {
        // Retrieve links from Firebase Realtime Database
        DatabaseEvent event = await _userRef.child(userId).child('links').once();
        DataSnapshot snapshot = event.snapshot;

        final dynamic data = snapshot.value;
        if (data != null && data is Map<dynamic, dynamic>) {
          _links = Map<String, String>.from(data.cast<String, dynamic>());
          onDataChanged(); // Notify the parent widget (HomePage) of data changes
        }
      } catch (e) {
        // Handle any errors, e.g., no internet connection, database errors
        print('Error loading links: $e');
      }
    }
  }
  void shareLinks(List<String> linksToShare) async {
    final String textToShare = "Check out my socials:\n${linksToShare.join('\n\n')}";

    // Use the `share` function from the `url_launcher` package to share the links
    await Share.share(textToShare);
  }

  void editLink(BuildContext context, String socialMedia, String currentLink) {
    print('Editing $socialMedia link: $currentLink');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditLinksPage(
          socialMedia: socialMedia,
          currentLink: currentLink,
        ),
      ),
    );
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      // Delete user data from Firebase Realtime Database
      final DatabaseReference databaseReference =
      FirebaseDatabase.instance.reference().child('users/${FirebaseAuth.instance.currentUser?.uid}');
      await databaseReference.remove();

      // Delete the user account
      await FirebaseAuth.instance.currentUser?.delete();

      // Sign the user out
      // Use the callback to update the state
      setStateCallback(() {
        signOut(context);
      });
    } catch (e) {
      // Account deletion failed
      ToastHelper.showShortToast('Error deleting account: $e');
    }
  }
}
