import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:soci/auth/signup_page.dart';
import 'package:soci/screens/intro_screens/intro_page1.dart';
import 'package:soci/screens/intro_screens/intro_page3.dart';
import 'package:soci/utils/app_colors.dart';

import 'intro_screens/intro_page2.dart';

class onBoardingScreen extends StatefulWidget {
  const onBoardingScreen({super.key});

  @override
  State<onBoardingScreen> createState() => _onBoardingScreenState();
}

class _onBoardingScreenState extends State<onBoardingScreen> {
  PageController _controller = PageController();

  bool onLastPage = false;
  @override
  Widget build(BuildContext context) {
    double fontSize = 20.sp;
    return Scaffold(
        body: Stack(
      children: [
        PageView(
          controller: _controller,
          onPageChanged: (index){
            setState(() {
              onLastPage = (index == 2);
            });
          },
          children: [
            IntroPage1(),
            IntroPage2(),
            IntroPage3(),
          ],
        ),
        Container(
            alignment: Alignment(0, 0.75),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                onLastPage
                    ?GestureDetector(
                    onTap: () {
                      _controller.previousPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeIn,
                      );
                    },
                    child: Text('back',style: TextStyle(fontSize: fontSize))
                )
                    :GestureDetector(
                    onTap: () {
                      _controller.jumpToPage(2);
                    },
                    child: Text('skip',style: TextStyle(fontSize:fontSize))
                ),

                SmoothPageIndicator(controller: _controller, count: 3,effect: ExpandingDotsEffect(activeDotColor: AppColors.accentColor,dotWidth: 12,dotHeight: 12),),

                onLastPage
                    ?GestureDetector(
                    onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (context){
                       return SignupPage();
                     }));
                    },
                    child: Text('done',style: TextStyle(fontSize: fontSize))
                )
                    :GestureDetector(
                    onTap: () {
                      _controller.nextPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeIn,
                      );
                    },
                    child: Text('next',style: TextStyle(fontSize: fontSize))
                )
              ],
            ))
      ],
    ));
  }
}
