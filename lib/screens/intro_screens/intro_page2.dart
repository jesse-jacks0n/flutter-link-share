import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/app_colors.dart';

class IntroPage2 extends StatelessWidget {
  const IntroPage2({super.key});

  @override
  Widget build(BuildContext context) {
    String title = 'Customize Your Profile';
    String description = 'Personalize your profile with your photo, bio, and other details. Let others get to know you better with a single click.';
    String subtitle = 'Make It Truly Yours';
    return  Container(
      color: AppColors.intro2bg,
      child:  Padding(
        padding:  EdgeInsets.symmetric(horizontal: 20.0.w),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 100.h,),
              Text(title,style: TextStyle(fontSize: 30.sp),),
              SizedBox(height: 20.h,),
              Text(subtitle,style: TextStyle(fontSize: 22.sp),),

              Image.asset(
                'assets/intro2.png',
                scale: 1.5,
              ),
              SizedBox(height: 15.h,),
              Text(description,style: TextStyle(fontSize: 18.sp),textAlign: TextAlign.center,),
            ],
          ),
        ),
      ),
    );
  }
}
