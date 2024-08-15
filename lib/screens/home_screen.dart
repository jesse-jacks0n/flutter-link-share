import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';
import 'package:soci/screens/profile_screen.dart';
import 'package:soci/screens/test_page.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import '../components/add_social_link.dart';
import '../components/my_settings.dart';
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
      FirebaseDatabase.instance.ref().child('users');
  final UserDataService _userDataService =
      UserDataService(); // Create an instance of UserDataService
  final UserFunctionService _userFunctionService = UserFunctionService(
    onDataChanged: () {},
    setStateCallback: (VoidCallback callback) {},
  );
  BannerAd? _bannerAd;
  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/2934735716'
      : 'ca-app-pub-3940256099942544/2934735716';

//'ca-app-pub-1926283539123501/7638288619'
  User? user = FirebaseAuth.instance.currentUser;
  String? name;
  String? email;
  String? _imageUrl;
  Map<String, String> _links = {};

  @override
  void initState() {
    super.initState();
    //fetchAndSetUserData();
    fetchUserDataAndSetState();
    _loadLinks();
    // _userDataService.fetchImageUrl().then((imageUrl) {
    //   setState(() {
    //     _imageUrl = imageUrl;
    //   });
    // });
    super.initState();
    _userFunctionService.loadLinks(user, _userRef, _links);
    _loadAd();
  }

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

  @override
  Widget build(BuildContext context) {
    String greeting = _userFunctionService.getGreeting();
    bool isInternetAvailable = true;
    var borderRadius = BorderRadius.circular(15.0);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        toolbarHeight: 40.h,
        leadingWidth: double.infinity,
        leading: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 10.0.w),
                child: Builder(
                  builder: (context) => GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: StreamBuilder<String?>(
                        stream: _userDataService.getProfileImageUrlStream(),
                        builder: (context, snapshot) {
                          String? imageUrl = snapshot.data;
                          return CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                                ? CachedNetworkImageProvider(imageUrl)
                                : const AssetImage('assets/user.png') as ImageProvider,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                'Hello, ${name?.isNotEmpty == true ? name![0].toUpperCase() + name!.substring(1) : '-'}',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return MySettings(
                    imageUrl: _imageUrl,
                    name: name,
                    email: email,
                    userFunctionService: _userFunctionService,
                  );
                },
              );
            },
            child: Padding(
              padding: EdgeInsets.only(right: 16.0.w),
              child: Image.asset(
                'assets/setting.png',
                scale: 7,
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 10.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Social Media',
                      style: TextStyle(
                          fontSize: 24.sp, fontWeight: FontWeight.bold),
                    ),
                    AddSocialLink(context: context),
                  ],
                ),
                Divider(
                  color: Theme.of(context).colorScheme.primary,
                )
              ],
            ),
          ),
          Expanded(
            flex: 1,
            // child: GridView.builder(
            //   padding: const EdgeInsets.all(16.0),
            //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            //     crossAxisCount: 2, // Number of items in each row
            //     mainAxisSpacing: 16.0, // Spacing between rows
            //     crossAxisSpacing: 16.0, // Spacing between columns
            //     childAspectRatio: 3/1
            //   ),
            //   itemCount: _buildLinkCardWidgets().length,
            //   itemBuilder: (context, index) {
            //     return _buildLinkCardWidgets()[index];
            //   },
            // ),
            child: FutureBuilder<ConnectivityResult>(
              future: Connectivity().checkConnectivity(),
              builder: (context, connectivitySnapshot) {
                if (connectivitySnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (connectivitySnapshot.hasData &&
                    connectivitySnapshot.data == ConnectivityResult.none) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No Internet Connection',
                          style: TextStyle(fontSize: 17.sp),
                        ),
                        TextButton(
                          onPressed: () {
                            // Retry logic on button press
                            // You may want to handle retry logic based on your requirements
                            // For simplicity, you can call setState to trigger a rebuild
                            // or reload the HomePage widget.
                            setState(() {});
                          },
                          child: Text(
                            'Retry',
                            style: TextStyle(
                                color: AppColors.accentColor, fontSize: 20.sp),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Internet connection available, display the links
                  return GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Number of items in each row
                      mainAxisSpacing: 16.0, // Spacing between rows
                      crossAxisSpacing: 16.0, // Spacing between columns
                      childAspectRatio: 3 / 1,
                    ),
                    itemCount: _buildLinkCardWidgets().length,
                    itemBuilder: (context, index) {
                      return _buildLinkCardWidgets()[index];
                    },
                  );
                }
              },
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _shareLinks();
            },
            icon: const Icon(
              Icons.share,
              color: Colors.white,
            ),
            label: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Share My Links",
                style: TextStyle(color: Colors.white, fontSize: 17.sp),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: borderRadius,
              ),
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Stack(
            children: [
              if (_bannerAd != null)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
                ),
            ],
          )
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
          //gradient: gradient,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          borderRadius: borderRadius,
          border: Border.all(
            color: Colors.grey.shade700, // Set the border color to gray
            width: 1.0, // Set the border width
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12),
              child: Image.asset(
                iconPath,
                width: 40.w,
                height: 40.h,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              socialMedia,
              style: TextStyle(fontSize: 17.sp),
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

  void _loadAd() async {
    BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) {},
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) {},
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) {},
      ),
    ).load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
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

  Map<String, String> socialMediaIcons = {
    'Facebook': 'assets/facebook.png',
    'Twitter': 'assets/twitter.png',
    'Youtube': 'assets/youtube.png',
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
}
