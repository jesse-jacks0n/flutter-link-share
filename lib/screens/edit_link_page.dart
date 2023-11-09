import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
    return Scaffold(
      appBar: AppBar(
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
                      border: OutlineInputBorder(),
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
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Clear'),
                                content: Text('Are you sure you want to clear this link?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      linkController.clear();
                                      Navigator.of(context).pop(); // Close the dialog
                                    },
                                    child: Text('Clear ${widget.socialMedia}'),
                                  ),
                                ],
                              );
                            },
                          );
                          // Pass userId as an argument
                        },
                        child: Text('Clear Link'),
                      ),
                      SizedBox(
                        width: 20.sp,
                      ),
                      ElevatedButton(
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
                                  title: Text('Confirm Update'),
                                  content: Text('Are you sure you want to update this link?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                         },
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close the dialog
                                        _updateLink(context, linkController, userId, widget.socialMedia);
                                        Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) =>  HomePage()));// Close the dialog

                                      },
                                      child: Text('Update ${widget.socialMedia}'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        child: Text('Update Link', style: TextStyle(color: AppColors.accentColor)),
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
                    color: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(15)
                ),
                child: Center(child: Text('Delete ${widget.socialMedia}', style: TextStyle(color: Colors.white,fontSize: 22.sp))),
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
