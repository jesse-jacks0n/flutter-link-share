import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:soci/screens/home_screen.dart';
import 'package:soci/utils/app_colors.dart';

class ImageUploadWidget extends StatefulWidget {
  @override
  _ImageUploadWidgetState createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _uploading = false;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _fetchImageUrl();
  }


  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await _cropImage(pickedFile.path);
    } else {
      print('No image selected.');
      Fluttertoast.showToast(msg: 'No image selected.');
    }
  }

  Future<void> _cropImage(String imagePath) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      compressQuality: 70,
      maxHeight: 800,
      maxWidth: 800,
      compressFormat: ImageCompressFormat.jpg,
      uiSettings: [
        AndroidUiSettings(
          toolbarColor:Theme.of(context).colorScheme.background,
          toolbarTitle: "Crop Image",
          statusBarColor: AppColors.accentColor,
          backgroundColor: Theme.of(context).colorScheme.background,
          showCropGrid: true,
          hideBottomControls: true
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _imageFile = File(croppedFile.path);
      });
      Fluttertoast.showToast(msg: 'success');
      _uploadImage();
    } else {
      print('Image cropping failed.');
      Fluttertoast.showToast(msg: 'Image cropping failed.');
    }
  }

  // Future<void> _compressImage() async {
  //   String imagePath = _imageFile!.path; // Get the path of the image file
  //
  //   // Perform image compression
  //   Uint8List? compressedImageData = await FlutterImageCompress.compressWithFile(
  //     imagePath,
  //     quality: 70, // Adjust the compression quality (0-100)
  //   );
  //
  //   if (compressedImageData != null) {
  //     // Write the compressed data to a new File
  //     File compressedImageFile = File(imagePath + '_compressed.jpg');
  //     await compressedImageFile.writeAsBytes(compressedImageData);
  //
  //     // Replace the original image file with the compressed one
  //     setState(() {
  //       _imageFile = compressedImageFile;
  //     });
  //   } else {
  //     print('Image compression failed.');
  //   }
  // }
  // Function to upload image to Firebase Storage
  Future<void> _uploadImage() async {
    if (_imageFile == null) {
      Fluttertoast.showToast(msg: 'No image selected to upload.');
      return;
    }

    setState(() {
      _uploading = true;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      final storage = FirebaseStorage.instance;
      final Reference ref =
      storage.ref().child('users/${user?.uid}/profile.jpg');

      await ref.putFile(_imageFile!);

      // Get the image URL after uploading
      String imageUrl = await ref.getDownloadURL();

      // Save the image URL to the user's data in Firebase Realtime Database
      await FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user!.uid)
          .update({'imageUrl': imageUrl});

      Fluttertoast.showToast(msg: 'Image uploaded successfully.');
      Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => const HomePage()));
    } catch (e) {

      Fluttertoast.showToast(msg: 'Error uploading image.');
    } finally {
      setState(() {
        _uploading = false;
      });

    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8.0,right: 8,bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // Show profile image or "No Image" if no image is selected
          Container(
            child: IntrinsicWidth(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.delete,color: Colors.transparent,),
                  GestureDetector(
                    onTap: _pickImage,
                    child: _imageFile == null
                        ? (_imageUrl != null
                        ? CircleAvatar(
                      radius: 70,
                      backgroundImage: NetworkImage(_imageUrl!) as ImageProvider<Object>?,
                      child:  const Center(
                        child: Icon(Icons.edit,size: 40,),
                      ),
                    )
                        : const CircleAvatar(
                                      radius: 70,
                                       backgroundImage: AssetImage('assets/edit.png'),
                                    ))
                        : Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundImage: FileImage(_imageFile!) as ImageProvider<Object>?,
                        ),
                        const Center(
                          child: Icon(Icons.edit,color: Colors.grey,),
                        ),
                      ],
              
                        ),
                  ),
                  GestureDetector(
                    onTap: _deleteImage,
                      child: const Icon(Icons.delete,color: Colors.redAccent,)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 16),

            ],
          ),
        ],
      ),
    );
  }


  Future<void> _fetchImageUrl() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      final storage = FirebaseStorage.instance;
      final Reference ref =
      storage.ref().child('users/${user?.uid}/profile.jpg');

      String? imageUrl = await ref.getDownloadURL();
      setState(() {
        _imageUrl = imageUrl;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching image URL: $e');
      }
      setState(() {
        _imageUrl = null;
      });
    }
  }

  Future<void> _deleteImage() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      final storage = FirebaseStorage.instance;
      final Reference ref = storage.ref().child('users/${user?.uid}/profile.jpg');

      // Delete the image from Firebase Storage
      await ref.delete();

      // Update the user data in the Realtime Database to remove the URL
      DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users').child(user!.uid);
      await userRef.update({'imageUrl': null});

      setState(() {
        _imageFile = null;
      });

      if (kDebugMode) {
        print('Image deleted .');
      }
      Fluttertoast.showToast(msg: 'Profile Image removed');
      Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => const HomePage()));
    } catch (e) {

    }
  }
}
