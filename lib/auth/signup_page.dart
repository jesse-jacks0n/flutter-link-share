import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shimmer/shimmer.dart';
import 'package:soci/helper/toast_helper.dart';
import 'package:soci/utils/app_colors.dart';

import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final personalFormKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<bool> registerUser() async {
    if (personalFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        User? user = userCredential.user;

        // Send email verification
        await user?.sendEmailVerification();

        // Update the user's display name
        await user?.updateDisplayName(nameController.text);

        await FirebaseDatabase.instance
            .reference()
            .child('users')
            .child(userCredential.user!.uid)
            .set({
          'name': nameController.text,
          'phone': phoneController.text,
          'email': emailController.text,
        });

        ToastHelper.showShortToast(
            'Registration successful. Please check your email for verification.');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );

        setState(() {
          _isLoading = false;
        });

        return true; // Registration was successful
      } catch (e) {
        if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
          // Email already exists
          ToastHelper.showShortToast('Email already exists');
        } else {
          // Other registration failure
          ToastHelper.showShortToast('Registration failed');
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      // Some fields are not filled correctly, do not proceed with registration
      ToastHelper.showShortToast(
          'Please fill all required fields correctly');

      return false; // Registration was not successful
    }

    return false; // Registration was not successful (default fallback)
  }

  void _validateAndFinish() async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool isRegistered = await registerUser();

      if (isRegistered) {
        // Registration was successful, you can navigate to the next screen here
        ToastHelper.showShortToast('Registration successful');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        // Registration was not successful, you can handle the error here
        ToastHelper.showShortToast('Registration failed');
      }
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
        // Email already exists
        ToastHelper.showShortToast('Email already exists');

      } else {
        // Other registration failure
        ToastHelper.showShortToast('Registration failed');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var borderRadius = BorderRadius.circular(50.0);
    var labelStyle =  TextStyle(fontSize: 17.sp);
    var floatingLabelStyle =  TextStyle(fontSize: 15.sp,color: Theme.of(context).colorScheme.tertiary);
    var style =  TextStyle(fontSize: 17.sp);
    var contentPadding =  EdgeInsets.symmetric(vertical: 13.0.h,horizontal: 15.w);
    return  Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin:  EdgeInsets.only(top: 50.h),
          padding:  EdgeInsets.symmetric(horizontal: 20.w),
          child: Form(
            key: personalFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text(
                    'SIGNUP',
                    style: TextStyle(
                      fontSize: 25.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentColor
                    ),
                  ),
                   SizedBox(height: 30.h),
                  TextFormField(
                    controller: nameController,
                    style:  style,

                    decoration:  InputDecoration(
                      labelText: 'Name',
                        filled: true,
                        floatingLabelStyle: floatingLabelStyle,
                        border: OutlineInputBorder(
                          borderRadius: borderRadius,
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: borderRadius,
                            borderSide: BorderSide.none),
                        labelStyle: labelStyle,
                        contentPadding: contentPadding),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                   SizedBox(height: 20.0.h),
                  TextFormField(
                    controller: phoneController,
                    style: style,
                    decoration:  InputDecoration(
                      labelText: 'Phone',
                        filled: true,
                        floatingLabelStyle: floatingLabelStyle,
                        border: OutlineInputBorder(
                          borderRadius: borderRadius,
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: borderRadius,
                            borderSide: BorderSide.none),
                        labelStyle: labelStyle,
                        contentPadding: contentPadding),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                   SizedBox(height: 20.0.h),
                  TextFormField(
                    controller: emailController,
                    style: style,
                    decoration:  InputDecoration(
                      labelText: 'Email',
                        filled: true,
                        floatingLabelStyle: floatingLabelStyle,
                        border: OutlineInputBorder(
                          borderRadius: borderRadius,
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: borderRadius,
                            borderSide: BorderSide.none),
                        labelStyle: labelStyle,
                        contentPadding: contentPadding),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                   SizedBox(height: 20.0.h),
                  TextFormField(
                    controller: passwordController,
                    style: style,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle:  labelStyle,
                      floatingLabelStyle: floatingLabelStyle,
                      filled: true,
                        border: OutlineInputBorder(
                          borderRadius: borderRadius,
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: borderRadius,
                            borderSide: BorderSide.none),
                        contentPadding: contentPadding,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),

                   SizedBox(height: 20.0.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Text(
                        "Already have an account?",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                          child:Shimmer.fromColors(
                            baseColor: AppColors.accentColor,
                            highlightColor: Colors.green.shade50,
                            period : const Duration(milliseconds: 2400),
                            child:  Text(
                              ' Log in',
                              style: TextStyle(
                                fontSize: 16.0.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  GestureDetector(
                    onTap: _isLoading ? null : _validateAndFinish,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.accentColor,
                        borderRadius: borderRadius,
                      ),
                      padding:  EdgeInsets.symmetric(
                          horizontal: 35.w,
                          vertical: 10.h
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      )
                          :  Text(
                        'Signup',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
