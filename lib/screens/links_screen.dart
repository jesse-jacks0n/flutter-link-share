import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soci/screens/home_screen.dart';

import '../utils/app_colors.dart';

class LinksPage extends StatefulWidget {
  @override
  _LinksPageState createState() => _LinksPageState();
}

class _LinksPageState extends State<LinksPage> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseReference _userRef = FirebaseDatabase.instance.reference().child('users');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _instagramLink = '';
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    var borderRadius = BorderRadius.circular(15.0);
    var labelStyle =  TextStyle(fontSize: 17.sp);
    var style =  TextStyle(fontSize: 17.sp);
    var contentPadding =  EdgeInsets.symmetric(vertical: 13.0.h,horizontal: 10.w);

    return Scaffold(
      appBar: AppBar(
      ),
      body: SafeArea(
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 20.0.w),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Let's get you started with one",style: TextStyle(fontSize: 20.sp,fontWeight: FontWeight.w600),),
                    SizedBox(height: 16.h),

                    TextFormField(
                      style:  style,
                      decoration: InputDecoration(
                          labelText: 'Instagram profile link',
                          border: OutlineInputBorder(
                            borderRadius: borderRadius,
                          ),

                          labelStyle:  labelStyle,
                          contentPadding:contentPadding
                      ),
                      onChanged: (value) {
                        setState(() {
                          _instagramLink = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a valid Instagram link';
                        }
                        return null;
                      },
                    ),
                  ],
                ),

                SizedBox(height: 16.h),
                GestureDetector(
                  onTap: _isLoading ? null :  _submitLinks,
                  child:Container(
                    decoration: BoxDecoration(
                      color: AppColors.accentColor,
                      borderRadius: borderRadius,
                    ),
                    padding:  EdgeInsets.symmetric(
                      horizontal: 35.w,
                      vertical: 10.h,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    )
                        :  Text(
                      'Submit',
                      style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      ),
                    ),

                  ),
                ),
                // ElevatedButton(
                //   onPressed: () {
                //     _submitLinks();
                //   },
                //   child: Text('Submit'),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitLinks() async {
    if (_formKey.currentState!.validate()) {
      final user = _auth.currentUser;
      if (user != null) {
        final userId = user.uid;

        // Create a map to store the social media links
        Map<String, String> links = {
          'Instagram': _instagramLink,
        };

        // Store the links in the Firebase Realtime Database under the user's ID
        await _userRef.child(userId).child('links').set(links);

        // Navigate back or show a success message
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      }
    }
  }
}
