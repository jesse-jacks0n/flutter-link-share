import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../screens/profile_screen.dart';
import '../services/user_function_service.dart';
import '../utils/app_colors.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({
    super.key,
    required String? imageUrl,
    required this.name,
    required this.email,
    required UserFunctionService userFunctionService,
  })  : _imageUrl = imageUrl,
        _userFunctionService = userFunctionService;

  final String? _imageUrl;
  final String? name;
  final String? email;
  final UserFunctionService _userFunctionService;

  Future<String> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }
  @override
  Widget build(BuildContext context) {
     var trailing = Icon(Icons.arrow_forward_ios_rounded,size: 20,color: Colors.grey.shade500,);
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: _imageUrl != null && _imageUrl!.isNotEmpty
                        ? CachedNetworkImageProvider(_imageUrl!)
                        : const AssetImage('assets/bgdrw.jpg') as ImageProvider,
                    // Cast to ImageProvider
                    fit: BoxFit.cover,
                  ),
                  color: Colors.black
                      .withOpacity(0.7), // Black color with 70% opacity
                ),
                child: ClipRect(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          // Transparent color at the top
                          Colors.black.withOpacity(0.6),
                          // Black color with 70% opacity at the bottom
                        ],
                      ),
                    ),
                    child: UserAccountsDrawerHeader(
                      decoration: const BoxDecoration(
                        color: Colors
                            .transparent, // Set the background color to transparent
                      ),
                      accountName: Text(
                        name ?? '',
                        style: TextStyle(color: Colors.white),
                      ),
                      accountEmail: Text(email ?? '',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 25.h,),
              Column(
                children: [
                  ListTile(
                    leading: Image.asset(
                      'assets/person.png',
                      scale: 15.h,
                    ),
                    trailing: trailing,
                    title: Text(
                      'Profile',
                      style: TextStyle(fontSize: 17.sp),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Image.asset(
                      'assets/star.png',
                      scale: 15.h,
                    ),
                    trailing: trailing,
                    title: Text(
                      'Rate & Review',
                      style: TextStyle(fontSize: 17.sp),
                    ),
                    onTap: () {

                    },
                  ),
                  ListTile(
                    leading: Image.asset(
                      'assets/help.png',
                      scale: 14.h,
                    ),
                    trailing: trailing,
                    title: Text(
                      'Help',
                      style: TextStyle(fontSize: 17.sp),
                    ),
                    onTap: () {
                    },
                  ),
                  // ListTile(
                  //   leading: const Icon(Icons.delete),
                  //   title: const Text('Delete Account'),
                  //   onTap: () {
                  //     showDialog(
                  //       context: context,
                  //       builder: (BuildContext context) {
                  //         return AlertDialog(
                  //           backgroundColor:
                  //               Theme.of(context).colorScheme.primary,
                  //           title: const Text('Delete Account'),
                  //           content: const Text(
                  //               'Are you sure you want to delete your account? This action can not be undone.'),
                  //           actions: [
                  //             TextButton(
                  //                 onPressed: () {
                  //                   Navigator.of(context)
                  //                       .pop(); // Close the dialog
                  //                 },
                  //                 child: Text('Cancel',
                  //                     style:
                  //                         TextStyle(color: AppColors.cancel))),
                  //             TextButton(
                  //               onPressed: () {
                  //                 // Call the function to delete the user account and data
                  //                 _userFunctionService.deleteAccount(context);
                  //                 Navigator.of(context)
                  //                     .pop(); // Close the dialog
                  //               },
                  //               child: const Text(
                  //                 'Delete',
                  //                 style:
                  //                     TextStyle(color: AppColors.accentColor),
                  //               ),
                  //             ),
                  //           ],
                  //         );
                  //       },
                  //     );
                  //   },
                  // ),
                ],
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 10.0.h),
            child: TextButton(
              onPressed: () {
                _userFunctionService.signOut(
                    context); // Call the signOut method with the current BuildContext
              },
              child: Text(
                'Log out',
                style:
                    TextStyle(color: Colors.grey.shade500, fontSize: 17.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
