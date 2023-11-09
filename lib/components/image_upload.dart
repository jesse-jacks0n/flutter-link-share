import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:soci/screens/home_screen.dart';

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
  // Function to choose image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        // Compress the image
        _imageFile = File(pickedFile.path);
        _compressImage();
        Fluttertoast.showToast(msg: 'Image selected successfully.');
      } else {
        print('No image selected.');
        Fluttertoast.showToast(msg: 'No image selected.');
      }
    });
  }

  Future<void> _compressImage() async {
    String imagePath = _imageFile!.path; // Get the path of the image file

    // Perform image compression
    Uint8List? compressedImageData = await FlutterImageCompress.compressWithFile(
      imagePath,
      quality: 70, // Adjust the compression quality (0-100)
    );

    if (compressedImageData != null) {
      // Write the compressed data to a new File
      File compressedImageFile = File(imagePath + '_compressed.jpg');
      await compressedImageFile.writeAsBytes(compressedImageData);

      // Replace the original image file with the compressed one
      setState(() {
        _imageFile = compressedImageFile;
      });
    } else {
      print('Image compression failed.');
    }
  }
  // Function to upload image to Firebase Storage
  Future<void> _uploadImage() async {
    if (_imageFile == null) {
      print('No image selected to upload.');
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
          .reference()
          .child('users')
          .child(user!.uid)
          .update({'imageUrl': imageUrl});

      print('Image uploaded successfully.');
      Fluttertoast.showToast(msg: 'Image uploaded successfully.');
    } catch (e) {
      print('Error uploading image: $e');
      Fluttertoast.showToast(msg: 'Error uploading image.');
    } finally {
      setState(() {
        _uploading = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
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
          _imageFile == null
              ? (_imageUrl != null
              ? CircleAvatar(
            radius: 70,
            backgroundImage: NetworkImage(_imageUrl!) as ImageProvider<Object>?,
          )
              : const CircleAvatar(
            radius: 70,
            // backgroundImage: AssetImage('assets/user.png'),
          ))
              : CircleAvatar(
            radius: 70,
            backgroundImage: FileImage(_imageFile!) as ImageProvider<Object>?,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _pickImage,
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.photo),
                    SizedBox(width: 3),
                    Text('Choose'),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _uploading ? null : _uploadImage,
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_upload),
                    const SizedBox(width: 3),
                    _uploading ? const CircularProgressIndicator() : const Text('Upload'),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => _deleteImage(),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  // Define a RoundedRectangleBorder with border radius 10
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),

                ),
                child: const Row(
                  children: [
                    Icon(Icons.delete),
                    SizedBox(width: 3),
                    Text('Delete'),
                  ],
                ),
              ),
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
      print('Error fetching image URL: $e');
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
      DatabaseReference userRef = FirebaseDatabase.instance.reference().child('users').child(user!.uid);
      await userRef.update({'imageUrl': null});

      setState(() {
        _imageFile = null;
      });

      print('Image deleted .');
      Fluttertoast.showToast(msg: 'Image deleted');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } catch (e) {
      print('Error deleting image: $e');
      Fluttertoast.showToast(msg: 'Error deleting image.');
    }
  }
}
