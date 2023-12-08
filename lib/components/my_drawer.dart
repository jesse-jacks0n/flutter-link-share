import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../screens/profile_screen.dart';
import '../services/user_function_service.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({
    super.key,
    required String? imageUrl,
    required this.name,
    required this.email,
    required UserFunctionService userFunctionService,
  }) : _imageUrl = imageUrl, _userFunctionService = userFunctionService;

  final String? _imageUrl;
  final String? name;
  final String? email;
  final UserFunctionService _userFunctionService;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: _imageUrl != null && _imageUrl!.isNotEmpty
                      ? CachedNetworkImageProvider(_imageUrl!)
                      : const AssetImage('assets/bgdrw.jpg') as ImageProvider, // Cast to ImageProvider
                  fit: BoxFit.cover,
                ),
                color: Colors.black.withOpacity(0.7), // Black color with 70% opacity
              ),
              child: ClipRect(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent, // Transparent color at the top
                        Colors.black.withOpacity(0.6), // Black color with 70% opacity at the bottom
                      ],
                    ),
                  ),
                  child: UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(
                      color: Colors.transparent, // Set the background color to transparent
                    ),
                    accountName: Text(name ?? ''),
                    accountEmail: Text(email ?? ''),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Edit Profile'),
                  onTap:(){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Sign Out'),
                  onTap: () {
                    _userFunctionService.signOut(context); // Call the signOut method with the current BuildContext
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Delete Account'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Delete Account'),
                          content: const Text('Are you sure you want to delete your account? This action can not be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                // Call the function to delete the user account and data
                                _userFunctionService.deleteAccount(context);
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}