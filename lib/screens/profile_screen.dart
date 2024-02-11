import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:soci/services/banner_class.dart';
import 'package:soci/services/user_function_service.dart';
import '../auth/auth_util.dart';
import '../components/image_upload.dart';
import '../helper/toast_helper.dart';
import '../utils/app_colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;
  String? name;
  String? bio;
  String? email;

  Future<Map<String, dynamic>?> fetchUserData(String uid) async {
    DatabaseReference userRef =
    FirebaseDatabase.instance.ref().child('users').child(uid);

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
        bio = userData['bio'];
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
          bio = userData['bio'];
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
          bio = userData['bio'];
        }
      });
    } catch (e) {
      // Handle any errors that might occur during data fetching
      print('Error fetching data: $e');
    }
  }

  final TextEditingController _bioController = TextEditingController();

  Future<void> _onSubmit() async {
    // This function will be called when the user submits the bio
    // Add your logic to handle the submitted bio here
    // For now, it's just closing the dialog
    Navigator.of(context).pop();
  }

  Future<void> _showEditBioDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Bio'),
          content: TextField(
            controller: _bioController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Type your bio here...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel',style: TextStyle(color: Colors.grey.shade500),),
            ),
            TextButton(
              onPressed: () {
                _onSubmit();
                // Optionally, you can pass the bio text to _onSubmit
                // _onSubmit(_bioController.text);
              },
              child: Text('Submit',style: TextStyle(color: Colors.grey.shade500)),
            ),
          ],
        );
      },
    );
  }

  void deleteAccount() async {
    try {
      // Delete user data from Firebase Realtime Database
      final DatabaseReference databaseReference =
      FirebaseDatabase.instance.reference().child('users/${FirebaseAuth.instance.currentUser?.uid}');
      await databaseReference.remove();

      // Delete the user account
      await FirebaseAuth.instance.currentUser?.delete();

      // Sign the user out
        signOut();

    } catch (e) {
      // Account deletion failed
      ToastHelper.showShortToast('Error deleting account: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    var marginBottom = const EdgeInsets.only(bottom: 10);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FutureBuilder<Map<String, dynamic>?>(
            future: fetchUserData(user!.uid),
            // The future that resolves to your user data
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // While data is loading, show a progress indicator
                return Center(
                  child:Image.asset(
                    'assets/Spin.gif', // Replace with the actual path to your GIF image
                    width: 70,
                    height: 70,
                  )
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
                          color:Theme.of(context).colorScheme.primary.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(15),

                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [

                              Text(
                                '${name ?? 'guest'}',
                                style: TextStyle(fontSize: 25.sp,color: Theme.of(context).colorScheme.tertiary),
                              ),
                              Text(
                                '${email ?? 'email'}',
                                style: TextStyle(fontSize: 18.sp,color: Theme.of(context).colorScheme.tertiary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: marginBottom,
                        padding: const EdgeInsets.all(10),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color:Theme.of(context).colorScheme.primary.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(15),

                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Shimmer.fromColors(
                                baseColor: Colors.grey.shade800,
                                period: const Duration(milliseconds: 1500),
                                loop: 3,
                                highlightColor: Colors.grey.shade200,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('My Bio',
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.grey.shade600)),
                                    IconButton(
                                      onPressed: () {
                                        _showEditBioDialog(context);
                                      },
                                      icon: Icon(Icons.edit),
                                    ), ],
                                ),
                              ),
                              Text(
                                '${bio ?? 'bio'}',
                                style: TextStyle(fontSize: 18,color: Theme.of(context).colorScheme.tertiary),
                              ),

                            ],
                          ),
                        ),
                      ),

                    ],
                  );
                }
              }
            },
          ),
          Column(
            children: [
              TextButton(
              child:  Text('Delete Account',style: TextStyle(color: Colors.grey.shade500,fontSize: 20.sp),),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor:
                      Theme.of(context).colorScheme.primary,
                      title: const Text('Delete Account'),
                      content: const Text(
                          'Are you sure you want to delete your account? This action can not be undone.'),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(); // Close the dialog
                            },
                            child: Text('Cancel',
                                style:
                                TextStyle(color: AppColors.cancel))),
                        TextButton(
                          onPressed: () {
                            deleteAccount();
                            Navigator.of(context)
                                .pop(); // Close the dialog
                          },
                          child: const Text(
                            'Delete',
                            style:
                            TextStyle(color: AppColors.accentColor),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
              SizedBox(height: 20,),
              BannerWid(),
            ],
          )
        ],
      ),
    );
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();

      // Sign-out successful
      ToastHelper.showShortToast('Sign-out successful');
// pushing to auth page after successful signout
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthPage()),
      );
    } catch (e) {
      // Sign-out failed
      ToastHelper.showShortToast('Error, check connection');
    }
  }
}
// 539128
  //  545206