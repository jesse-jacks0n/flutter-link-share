import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:soci/auth/auth_service.dart';
import 'package:soci/screens/intro_screens/intro_page3.dart';
import 'package:soci/screens/links_screen.dart';
import 'package:soci/screens/on_boarding_screen.dart';
import '../helper/toast_helper.dart';
import '../screens/home_screen.dart';
import '../utils/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  bool _obscurePassword = true;

  Future<void> signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          if (user.emailVerified) {
            // Email is already verified, navigate to the appropriate screen
            navigateToHomePage();
            ToastHelper.showShortToast('Sign-in successful');
          } else {
            // Email is not verified, send a verification email
            await user.sendEmailVerification();
            ToastHelper.showShortToast(
              'Verification email sent, please verify your email',
            );
          }
        }
      }  catch (e) {
        if (e is FirebaseAuthException && e.code == 'user-not-found') {
          // Handle the case where the user is not found
          ToastHelper.showShortToast('User not found');
        } else if (e is FirebaseAuthException && e.code == 'wrong-password') {
          // Handle the case where the password is incorrect
          ToastHelper.showShortToast('Incorrect password');
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void navigateToHomePage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.emailVerified) {
      // User is signed in and email is verified
      // Navigate to the appropriate screen based on your logic
      final databaseReference = FirebaseDatabase.instance.reference();
      final userLinksRef = databaseReference.child('users/${user.uid}/links');
      final linksSnapshot = await userLinksRef.once();

      if (linksSnapshot.snapshot != null) {
        // Links data exists, navigate to HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        // Links data doesn't exist, navigate to LinksPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LinksPage()),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    var borderRadius = BorderRadius.circular(50.0);
    var labelStyle = TextStyle(fontSize: 17.sp);
    var floatingLabelStyle =  TextStyle(fontSize: 15.sp,color: Theme.of(context).colorScheme.tertiary);
    var style = TextStyle(fontSize: 17.sp);
    var contentPadding =
        EdgeInsets.symmetric(vertical: 13.0.h, horizontal: 15.w);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 35.h),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'LOGIN',
                  style: TextStyle(
                      fontSize: 25.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentColor),
                ),
                SizedBox(height: 30.h),
                TextFormField(
                  controller: emailController,
                  style: style,
                  decoration: InputDecoration(
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
                    labelStyle: labelStyle,
                    contentPadding: contentPadding,
                    filled: true,
                    floatingLabelStyle: floatingLabelStyle,
                    // Fill the background with color
                    border: OutlineInputBorder(
                      borderRadius: borderRadius,
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: borderRadius,
                        borderSide: BorderSide.none),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () async {
                        if (emailController.text.trim().isEmpty) {
                          // Show a toast message if the email field is empty
                          ToastHelper.showShortToast('Please enter your email');
                          return;
                        }

                        try {
                          await FirebaseAuth.instance.sendPasswordResetEmail(
                            email: emailController.text,
                          );
                          ToastHelper.showShortToast('Password reset email sent');
                        } catch (e) {
                          ToastHelper.showShortToast(
                            'Password reset failed, check connection',
                          );
                        }
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: AppColors.accentColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  ],
                ),
                GestureDetector(
                  onTap: _isLoading ? null : signIn,
                  child: _isLoading
                      ? Image.asset(
                          'assets/Spin.gif',
                          // Replace with the actual path to your GIF image
                          width: 70,
                          height: 70,
                        )
                      : ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                AppColors.accentColor),
                            // padding:
                            //     MaterialStateProperty.all<EdgeInsetsGeometry>(
                            //   const EdgeInsets.symmetric(horizontal: 8),
                            // ),

                          ),
                          onPressed: _isLoading ? null : signIn,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'Sign in',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 30.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(
                        fontSize: 16.sp,
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const IntroPage3(),
                            ),
                          );
                        },
                        child: Shimmer.fromColors(
                          baseColor: AppColors.accentColor,
                          highlightColor: Colors.green.shade50,
                          period: const Duration(milliseconds: 2400),
                          child: Text(
                            'Sign up',
                            style: TextStyle(
                              fontSize: 16.0.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 40.0),
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
                const SizedBox(height: 40.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => AuthService().signInWithGoogle() ,
                      child: Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: borderRadius
                        ),
                        child: Image.asset('assets/google.png',scale: 15,),
                      ),
                    ),
                  ],
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }
}
