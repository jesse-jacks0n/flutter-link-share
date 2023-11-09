import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soci/utils/app_colors.dart';

class IntroPage1 extends StatelessWidget {
  const IntroPage1({super.key});

  @override
  Widget build(BuildContext context) {
    String title = 'Welcome to [app name]';
    String description = 'Share all your social media profiles with just one link. Connect with friends, family, and followers like never before';
    String subtitle = 'Simplify Your Social Sharing';
    return  Container(
      color: AppColors.intro1bg,
      child:  Padding(
        padding:  EdgeInsets.symmetric(horizontal: 15.0.w),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 100.h,),
              Text(title,style: TextStyle(fontSize: 30.sp),),
              SizedBox(height: 20.h,),
              Text(subtitle,style: TextStyle(fontSize: 22.sp),),

              Image.asset(
                  'assets/intro1.png',
              ),
              SizedBox(height: 20.h,),
              Text(description,style: TextStyle(fontSize: 18.sp),textAlign: TextAlign.center,),
            ],
          ),
        ),
      ),
    );
  }
}
