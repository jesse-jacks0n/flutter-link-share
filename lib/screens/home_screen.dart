import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:soci/screens/profile_screen.dart';
import 'package:soci/screens/test_page.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/add_social_link.dart';
import '../components/my_drawer.dart';
import '../helper/toast_helper.dart';
import '../services/user_data_service.dart';
import '../services/user_function_service.dart';
import '../utils/app_colors.dart';
import 'edit_link_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseReference _userRef =
      FirebaseDatabase.instance.reference().child('users');
  final UserDataService _userDataService =
      UserDataService(); // Create an instance of UserDataService
  final UserFunctionService _userFunctionService = UserFunctionService(
    onDataChanged: () {},
    setStateCallback: (VoidCallback callback) {},
  );

  User? user = FirebaseAuth.instance.currentUser;
  String? name;
  String? email;
  String? _imageUrl;
  String? generatedLink;
  Map<String, String> _links = {}; // Store the links

  @override
  void initState() {
    super.initState();
    //fetchAndSetUserData();
    fetchUserDataAndSetState();
    _loadLinks();
    _userDataService.fetchImageUrl().then((imageUrl) {
      setState(() {
        _imageUrl = imageUrl;
      });
    });
    super.initState();
    _userFunctionService.loadLinks(user, _userRef, _links);
  }

//start of my functions
  void fetchUserDataAndSetState() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
    Map<String, dynamic>? userData =
        await _userDataService.fetchUserData(userId);

    if (userData != null) {
      setState(() {
        name = userData['name'];
        email = userData['email'];
      });
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launch(uri.toString(),
        forceSafariVC: false, forceWebView: false)) {
      throw "Can not launch URL";
    }
  }

  void _loadLinks() async {
    if (user != null) {
      final userId = user!.uid;
      try {
        // Retrieve links from Firebase Realtime Database
        DatabaseEvent event =
            await _userRef.child(userId).child('links').once();
        DataSnapshot snapshot = event.snapshot;

        setState(() {
          final dynamic data = snapshot.value;
          if (data != null && data is Map<dynamic, dynamic>) {
            _links = Map<String, String>.from(data.cast<String, dynamic>());
          }
        });
      } catch (e) {
        // Handle any errors, e.g., no internet connection, database errors
        ToastHelper.showLongToast('Error loading links, check your connection');
      }
    }
  }

  void _shareLinks() async {
    final List<String> linksToShare = _links.values.toList();
    final String textToShare =
        "Check out my socials:\n${linksToShare.join('\n\n')}";

    // Use the `share` function from the `url_launcher` package to share the links
    await Share.share(textToShare);
  }

  void _editLink(
    String socialMedia,
    String currentLink,
  ) {
    // print('Editing $socialMedia link: $currentLink');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditLinksPage(
          socialMedia: socialMedia,
          currentLink: currentLink,
        ),
      ),
    );
  }

  //end of my functions

  Map<String, String> socialMediaIcons = {
    'Facebook': 'assets/facebook2.png',
    'Twitter': 'assets/twitter.png',
    'Youtube': 'assets/play.png',
    'Instagram': 'assets/instagram.png',
    'Tiktok': 'assets/tiktok.png',
    'Snapchat': 'assets/snapchat.png',
    'LinkedIn': 'assets/linkedin.png',
    'Pinterest': 'assets/pinterest.png',
    'Finda': 'assets/finda.png',
    // Add more social media names and their corresponding asset image paths here
  };
  Map<String, LinearGradient> socialMediaGradients = {
    'Facebook': LinearGradient(
      colors: [Colors.blue.shade800, Colors.blue.shade300],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    'Twitter': LinearGradient(
      colors: [Colors.blue.shade300, Colors.blue],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    'Instagram': const LinearGradient(
      colors: [Colors.pink, Colors.purple],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    'Tiktok': const LinearGradient(
      colors: [Colors.black, Colors.purple],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    'Youtube': const LinearGradient(
      colors: [Colors.red, Colors.black],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    'Snapchat': const LinearGradient(
      colors: [Color(0xFFFFFC00), Color(0xFFFFA500)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    'LinkedIn': const LinearGradient(
      colors: [Colors.blue, Colors.blueAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    'Pinterest': const LinearGradient(
      colors: [Colors.white, Colors.red],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    'Finda': const LinearGradient(
      colors: [Color(0xFFADD8E6), Colors.blue],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // Add more social media gradients as needed
  };

  @override
  Widget build(BuildContext context) {
    String greeting = _userFunctionService.getGreeting();

    var borderRadius = BorderRadius.circular(15.0);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Scaffold(
              // backgroundColor: Colors.transparent,
              appBar: AppBar(
                elevation: 0,
                toolbarHeight: 70.h,
                //backgroundColor: Colors.transparent,
                leadingWidth: double.infinity,
                leading: Padding(
                  padding: EdgeInsets.only(
                    left: 16.0.w,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(greeting,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: AppColors.accentColor,
                          )),
                      Text(
                        name?.isNotEmpty == true
                            ? name![0].toUpperCase() + name!.substring(1)
                            : '-',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Padding(
                    padding: EdgeInsets.only(right: 16.0.w),
                    child: Builder(
                      builder: (context) => GestureDetector(
                        onTap: () {
                          // Open the endDrawer when the IconButton is pressed
                          Scaffold.of(context).openEndDrawer();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade400,
                                width: 2,
                              )),
                          child: CircleAvatar(
                            radius: 22,
                            backgroundImage: _imageUrl != null &&
                                    _imageUrl!.isNotEmpty
                                ? NetworkImage(_imageUrl!)
                                : const AssetImage('assets/user.png')
                                    as ImageProvider, // Cast to ImageProvider
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              endDrawer: MyDrawer(
                  imageUrl: _imageUrl,
                  name: name,
                  email: email,
                  userFunctionService: _userFunctionService),
              body: Stack(
                children: [
                  FrostedGlassBackground(),
                  AnnotatedRegion<SystemUiOverlayStyle>(
                    value: SystemUiOverlayStyle.dark,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                          ),
                          child: Row(
                            children: [
                              Text(
                                'My Links',
                                style: GoogleFonts.bebasNeue(fontSize: 50.sp),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.all(16.0),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, // Number of items in each row
                              mainAxisSpacing: 16.0, // Spacing between rows
                              crossAxisSpacing: 16.0, // Spacing between columns
                              // childAspectRatio: 1/1.1
                            ),
                            itemCount: _buildLinkCardWidgets().length,
                            itemBuilder: (context, index) {
                              return _buildLinkCardWidgets()[index];
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _shareLinks(); // Call the function to share links
                            },
                            icon: const Icon(Icons.share),
                            label: const Text("Share My Links"),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0), // Adjust the radius as needed
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  List<Widget> _buildLinkCardWidgets() {
    var borderRadius = BorderRadius.circular(15.0);
    List<Widget> widgets = [];

    _links.forEach((socialMedia, link) {
      final iconPath = socialMediaIcons[socialMedia];
      final gradient = socialMediaGradients[socialMedia];

      if (iconPath != null) {
        widgets.add(
          myLinkIcons(link, socialMedia, gradient, borderRadius, iconPath),
        );
      } else {
        widgets.add(
          launchSocialLink(link, socialMedia),
        );
      }
    });

    widgets.add(
      AddSocialLink(context: context),
    );
    return widgets;
  }

  GestureDetector myLinkIcons(String link, String socialMedia,
      LinearGradient? gradient, BorderRadius borderRadius, String iconPath) {
    return GestureDetector(
      onTap: () {
        _launchURL(link); // Implement opening the link here
      },
      onLongPress: () {
        _editLink(socialMedia, link); // Implement editing the link here
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: borderRadius,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 50.w,
              height: 50.h,
            ),
            SizedBox(height: 5.h),
            Text(
              socialMedia,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector launchSocialLink(String link, String socialMedia) {
    return GestureDetector(
      onTap: () {
        _launchURL(link);
      },
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
        ),
        child: Column(
          children: [
            Text(socialMedia),
            GestureDetector(
              onTap: () {
                _launchURL(link);
              },
              child: Text(link),
            ),
          ],
        ),
      ),
    );
  }
}
