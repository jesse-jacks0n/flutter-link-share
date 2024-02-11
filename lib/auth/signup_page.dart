import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shimmer/shimmer.dart';
import 'package:soci/helper/toast_helper.dart';
import 'package:soci/utils/app_colors.dart';

import 'auth_service.dart';
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
    var borderRadius = BorderRadius.circular(15.0);
    var labelStyle =  TextStyle(fontSize: 17.sp);
    var floatingLabelStyle =  TextStyle(fontSize: 15.sp,color: Theme.of(context).colorScheme.tertiary);
    var style =  TextStyle(fontSize: 17.sp);
    var contentPadding =  EdgeInsets.symmetric(vertical: 13.0.h,horizontal: 20.w);
    return  Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin:  EdgeInsets.only(top: 10.h),
          padding:  EdgeInsets.symmetric(horizontal: 20.w),
          child: Form(
            key: personalFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                   Text(
                    'Create an account',
                    style: TextStyle(
                      fontSize: 25.sp,
                      fontWeight: FontWeight.normal,

                    ),
                  ),
                   SizedBox(height: 30.h),
                  TextFormField(
                    controller: nameController,
                    style:  style,

                    decoration:  InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Image.asset('assets/person.png',scale: 18,),
                      ),

                      labelText: 'Full name',
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
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Image.asset('assets/telephone.png',scale: 18,),
                        ),
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
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Image.asset('assets/mail.png',scale: 18,),
                        ),
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
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Image.asset('assets/padlock.png',scale: 18,),
                      ),
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
                   SizedBox(height: 20.0.h),
                  Container(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: _isLoading ? null : _validateAndFinish,
                      child: _isLoading
                          ? Image.asset(
                        'assets/Spin.gif',
                        // Replace with the actual path to your GIF image
                        width: 70,
                        height: 70,
                      )
                          :ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              AppColors.accentColor),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: borderRadius, // Set the border radius here
                            ),
                          ),
                        ),
                        onPressed: _isLoading ? null : _validateAndFinish,
                        child:  Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0.h),
                          child: Text(
                            'Sign up',
                            style: TextStyle(
                              fontSize: 20.sp,
                              color: Colors.white
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h,),
                  Row(
                    children: [
                      Expanded(child: Divider(thickness: 1,color: Theme.of(context).colorScheme.primary,)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text('Or continue with'),
                      ),
                      Expanded(child: Divider(thickness: 1,color: Theme.of(context).colorScheme.primary,)),
                    ],
                  ),
                  SizedBox(height: 20.h,),
                  GestureDetector(
                    onTap: () => AuthService().signInWithGoogle()  ,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: borderRadius
                      ),
                      child: Image.asset('assets/google.png',scale: 15,),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
