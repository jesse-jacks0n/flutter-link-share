import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:soci/theme/theme.dart';
import 'package:soci/utils/app_colors.dart';
import 'home_screen.dart';

class EditLinksPage extends StatefulWidget {
  final String socialMedia;
  final String currentLink;


  EditLinksPage({
    required this.socialMedia,
    required this.currentLink,

  });

  @override
  _EditLinksPageState createState() => _EditLinksPageState();
}

class _EditLinksPageState extends State<EditLinksPage> {
  final TextEditingController linkController = TextEditingController();
  late String userId; // Define the userId variable

  @override
  void initState() {
    super.initState();
    linkController.text = widget.currentLink;

    // Get the current user's ID
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
    }
  }

  @override
  Widget build(BuildContext context) {
    //const Color socialMediaGradients = socialMediaGradients;
    var labelStyle = TextStyle(fontSize: 17.sp);
    var backgroundColor = Theme.of(context).colorScheme.background;
    var contentPadding =
    EdgeInsets.symmetric(vertical: 13.0.h, horizontal: 10.w);
    var borderRadius = BorderRadius.circular(50.0);
    return Scaffold(
      backgroundColor:backgroundColor,
      appBar: AppBar(
        backgroundColor:backgroundColor,
        title: Text(
            'Edit ${widget.socialMedia} Link'), // Use the widget.socialMedia variable
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(

              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: linkController,
                    decoration: InputDecoration(
                      labelText: 'Edit ${widget.socialMedia} Link',
                        border: OutlineInputBorder(
                          borderRadius: borderRadius,
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: borderRadius, borderSide: BorderSide.none),
                        labelStyle: labelStyle,
                        contentPadding: contentPadding,
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.4)
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your link';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      ElevatedButton(
                        style:ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(AppColors.accentColor),
                        ),

                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                title: Text('Clear'),
                                content: Text('Are you sure you want to clear this link?', style: TextStyle(color: Theme.of(context).colorScheme.tertiary),),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 15,vertical: 7),
                                      decoration:BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                      borderRadius: borderRadius),
                                        child: Text('Cancel',style: TextStyle(color: AppColors.cancel))),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      linkController.clear();
                                      Navigator.of(context).pop(); // Close the dialog
                                    },
                                    child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 15,vertical: 7),
                                        decoration:BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                        borderRadius: borderRadius),
                                        child: Text('Clear ${widget.socialMedia}',style: TextStyle(color: AppColors.accentColor),)),
                                  ),
                                ],
                              );
                            },
                          );
                          // Pass userId as an argument
                        },
                        child: Text('Clear Link', style: TextStyle()),),

                      SizedBox(
                        width: 20.sp,
                      ),
                      ElevatedButton(
                        style:ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(AppColors.accentColor),
                        ),
                        onPressed: () {
                          if (linkController.text.isEmpty) {
                            // Show an error message if the link field is empty
                            Fluttertoast.showToast(
                              msg: 'Link can not be empty',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                            );

                          } else {
                            // Show a confirmation dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  title: Text('Confirm Update'),
                                  content: Text('Are you sure you want to update this link?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                         },
                                      child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 15,vertical: 7),
                                          decoration:BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                              borderRadius: borderRadius),
                                          child: Text('Cancel',style: TextStyle(color: AppColors.cancel))),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close the dialog
                                        _updateLink(context, linkController, userId, widget.socialMedia);
                                        Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) =>  HomePage()));// Close the dialog

                                      },
                                      child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 15,vertical: 7),
                                decoration:BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                borderRadius: borderRadius),
                                child: Text('Update ${widget.socialMedia}',style: TextStyle(color: AppColors.accentColor),)),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        child: Text('Update Link', style: TextStyle()),
                      ),

                    ],
                  ),

                ],
              ),
            ),
            GestureDetector(
              onTap: (){
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirm Deletion'),
                      content: Text('Are you sure you want to delete ${widget.socialMedia}?\nThis action can\'t be undone' ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                            _deleteLink(userId, widget.socialMedia); // Execute the delete action
                          },
                          child: Text('Delete'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Container(
                //alignment: Alignment(0,0.75),
                padding: EdgeInsets.symmetric(vertical:15.h ),
                width: double.infinity,
                decoration: BoxDecoration(
                    color:Colors.red[400],
                  borderRadius:borderRadius
                ),
                child: Center(child: Text('Delete ${widget.socialMedia}', style: TextStyle(color: Colors.white,fontSize: 18.sp))),
              ),
            ),
            SizedBox(height: 20.sp,)
          ],
        ),
      ),
    );
  }

  void _updateLink(BuildContext context, TextEditingController linkController,
      String userId, String socialMedia) async {
    String updatedLink = linkController.text;

    // Initialize Firebase Realtime Database reference
    final DatabaseReference _userRef =
        FirebaseDatabase.instance.reference().child('users');

    // Create a map to update the link for the specific social media
    Map<String, dynamic> linkData = {
      socialMedia: updatedLink,
    };

    try {
      // Update the link in the database under the user's ID
      await _userRef.child(userId).child('links').update(linkData);

      Fluttertoast.showToast(
        msg: 'Link update successful',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade100,
        textColor: Colors.black,
      );

      // Reload the home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } catch (error) {
      // Handle any errors that occur during the update process
      print('Error updating link: $error');
      // You can show an error message to the user if needed
    }
  }

  void _deleteLink(String userId, String socialMedia) async {
    // Initialize Firebase Realtime Database reference
    final DatabaseReference _userRef =
        FirebaseDatabase.instance.reference().child('users');

    try {
      // Remove the link from the database under the user's ID and social media key
      await _userRef.child(userId).child('links').child(socialMedia).remove();

      Fluttertoast.showToast(
        msg: 'Link deleted successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade100,
        textColor: Colors.black,
      );

      // Navigate back to the home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } catch (error) {
      // Handle any errors that occur during the delete process
      print('Error deleting link: $error');
      // You can show an error message to the user if needed
    }
  }

  @override
  void dispose() {
    linkController.dispose();
    super.dispose();
  }
}
