import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../screens/profile_screen.dart';
import '../services/user_function_service.dart';
import '../utils/app_colors.dart';

class MySettings extends StatelessWidget {
  const MySettings({
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

  @override
  Widget build(BuildContext context) {
     var trailing = Icon(Icons.arrow_forward_ios_rounded,size: 20,color: Colors.grey.shade500,);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        height: 200.h,
        child: Column(
          children: [
            Column(
              children: [
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
                  ],
                ),
              ],
            ),
            SizedBox(height: 10.h,),
            Padding(
              padding: EdgeInsets.only(bottom: 10.0.h),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        title: const Text('Log out'),
                        content:  Text(
                            'Are you sure you want to Log out?',style: TextStyle(fontSize: 14.sp),),
                        actions: [
                          GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: const Text('Cancel',
                                  style: TextStyle())),
                          TextButton(
                            onPressed: () {
                              _userFunctionService.signOut(context);
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Log Out',
                              style: TextStyle(color: AppColors.accentColor),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text(
                  'Log out',
                  style:
                      TextStyle(fontSize: 17.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
