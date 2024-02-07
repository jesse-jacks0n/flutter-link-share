import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soci/auth/signup_page.dart';

import '../../utils/app_colors.dart';

class IntroPage3 extends StatelessWidget {
  const IntroPage3({super.key});

  @override
  Widget build(BuildContext context) {
    String title = 'Share Anywhere, Anytime';
    String description = 'Share your unique profile link on social media, in emails, or with a simple QR code. It\'s never been easier to connect with your audience.';
    String subtitle = 'Share Your Profile Link';
    return  Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 20.0.w),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 100.h,),
              Text(title,style: TextStyle(fontSize: 30.sp),),
              SizedBox(height: 20.h,),
              Text(subtitle,style: TextStyle(fontSize: 22.sp),),


              SizedBox(height: 10.h,),
              Text(description,style: TextStyle(fontSize: 18.sp),textAlign: TextAlign.center,),
              SizedBox(height: 10.h,),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupPage(),
                      ),
                    );
                  },
                  child: const Text('Next'))
            ],
          ),
        ),
      ),
    );
  }
}
