import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/app_colors.dart';
import '../components/image_upload.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;
  String? name;
  String? email;


  Future<Map<String, dynamic>?> fetchUserData(String uid) async {
    DatabaseReference userRef =
    FirebaseDatabase.instance.reference().child('users').child(uid);

    try {
      // Wait for the event to complete and extract the DataSnapshot
      DatabaseEvent event = await userRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null && snapshot.value is Map<dynamic, dynamic>) {
        return Map<String, dynamic>.from(
            snapshot.value as Map<dynamic, dynamic>);
      }

      return null;
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  // Function to fetch and update user data
  void fetchAndSetUserData() async {
    Map<String, dynamic>? userData = await fetchUserData(user!.uid);

    setState(() {
      if (userData != null) {
        name = userData['name'];
        email = userData['email'];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUserData(user!.uid).then((userData) {
      setState(() {
        if (userData != null) {
          name = userData['name'];
          email = userData['email'];
        }
      });
    });
    refreshData();
  }

  Future<void> refreshData() async {
    try {
      Map<String, dynamic>? userData = await fetchUserData(user!.uid);
      setState(() {
        if (userData != null) {
          name = userData['name'];
          email = userData['email'];
        }
      });
    } catch (e) {
      // Handle any errors that might occur during data fetching
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var marginBottom = const EdgeInsets.only(bottom: 10);
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FutureBuilder<Map<String, dynamic>?>(
                future: fetchUserData(user!.uid),
                // The future that resolves to your user data
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // While data is loading, show a progress indicator
                    return Center(
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade700,
                        highlightColor: Colors.grey.shade100,
                        child: const Center(
                          child: Text(
                            'Loading....',
                            style: TextStyle(fontSize: 24.0),
                          ),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    // If there's an error while fetching data, display an error message
                    return Text('Error fetching data: ${snapshot.error}');
                  } else {
                    // Data has been loaded successfully, build your UI using the data
                    Map<String, dynamic>? userData = snapshot.data;
                    if (userData == null) {
                      return const Text('No user data found.');
                    } else {
                      // Your existing UI code using the fetched data
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ImageUploadWidget(),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            margin: marginBottom,
                            padding: const EdgeInsets.all(10),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.containerColor,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  // Shadow color and opacity
                                  spreadRadius: 10,
                                  // How far the shadow extends
                                  blurRadius: 20,
                                  // The intensity of the blur effect
                                  offset: const Offset(0,
                                      3), // Offset in the x and y directions (0, 3) means shadow moves down 3 pixels
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Shimmer.fromColors(
                                  baseColor: Colors.grey.shade800,
                                  period: const Duration(milliseconds: 1500),
                                  loop: 3,
                                  highlightColor: Colors.grey.shade200,
                                  child: Text('MY DETAILS',
                                      style: GoogleFonts.bebasNeue(
                                          fontSize: 20,
                                          color: Colors.grey.shade800)),
                                ),
                                Text(
                                  'Name, ${name ?? 'Guest'}',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                Text(
                                  'Email: ${email ?? ''}',
                                  style: const TextStyle(fontSize: 18),
                                ),


                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// 539128
  //  545206