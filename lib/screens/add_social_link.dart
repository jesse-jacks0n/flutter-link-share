import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:soci/helper/toast_helper.dart';
import 'package:url_launcher/url_launcher.dart';

import 'home_screen.dart';

class AddSocialLinkPage extends StatefulWidget {
  @override
  _AddSocialLinkPageState createState() => _AddSocialLinkPageState();
}

class SocialMediaOption {
  final String name;
  final String iconAsset; // Image asset path

  SocialMediaOption({
    required this.name,
    required this.iconAsset,
  });
}

class _AddSocialLinkPageState extends State<AddSocialLinkPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final TextEditingController linkController = TextEditingController();
  String selectedSocialMedia = 'Instagram'; // Default selected social media
  bool _isLoading = false;

  InterstitialAd? _interstitialAd;

  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 30.0, // Adjust the desired animation height
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut, // You can change the curve as needed
      ),
    );

    // Start the animation in a loop
    _controller.repeat(reverse: true);
    _loadAd();
  }

  @override
  void dispose() {
    _controller.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  List<SocialMediaOption> socialMediaOptions = [
    SocialMediaOption(name: 'Instagram', iconAsset: 'assets/instagram.png'),
    SocialMediaOption(name: 'Snapchat', iconAsset: 'assets/snapchat.png'),
    SocialMediaOption(name: 'LinkedIn', iconAsset: 'assets/linkedin.png'),
    SocialMediaOption(name: 'Pinterest', iconAsset: 'assets/pinterest.png'),
    SocialMediaOption(name: 'Twitter', iconAsset: 'assets/twitter.png'),
    SocialMediaOption(name: 'Facebook', iconAsset: 'assets/facebook2.png'),
    SocialMediaOption(name: 'Tiktok', iconAsset: 'assets/tiktok.png'),
    SocialMediaOption(name: 'Youtube', iconAsset: 'assets/play.png'),
    SocialMediaOption(name: 'Finda', iconAsset: 'assets/finda.png'),
    // Add more social media options and their image asset paths here
  ];

  Future<void> saveLinkToDatabase(
      String link, String selectedSocialMedia, BuildContext context) async {
    if (link.isNotEmpty) {
      try {
        // Save the link to the database using Firebase Realtime Database
        final DatabaseReference databaseReference = FirebaseDatabase.instance
            .reference()
            .child(
                'users/${FirebaseAuth.instance.currentUser?.uid}/links/$selectedSocialMedia');

        await databaseReference.set(link);

        // Navigate back to the home page and pass the link as a result
        // Navigator.pop(context, link);
      } catch (e) {
        // Handle the database save error
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(
                  'Failed to save the link to the database. Please check your connection and try again.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      // Handle the case when the link is empty
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Link cannot be empty.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Map<String, Color> socialMediaColors = {
    'Snapchat': Colors.yellow.shade600, // Define the color for Snapchat
    'LinkedIn': Colors.blue, // Define the color for LinkedIn
    'Pinterest': Colors.redAccent, // Define the color for LinkedIn
    'Twitter': Colors.black, // Define the color for LinkedIn
    'Instagram': Colors.pink.shade900, // Define the color for LinkedIn
    'Facebook': Colors.blueAccent, // Define the color for LinkedIn
    'Tiktok': Colors.deepPurple.shade900, // Define the color for LinkedIn
    'Youtube': Colors.red.shade700, // Define the color for LinkedIn
    'Finda': Colors.blue, // Define the color for LinkedIn
    // Add more social media options and their colors here
  };
  Map<String, Color> socialMediaOpenerColors = {
    'Snapchat': Colors.yellow.shade50,
    'LinkedIn': Colors.blue.shade50,
    'Pinterest': Colors.red.shade50,
    'Twitter': Colors.grey.shade200,
    'Instagram': Colors.pink.shade50,
    'Facebook': Colors.blue.shade50,
    'Tiktok': Colors.deepPurple.shade50,
    'Youtube': Colors.red.shade50,
    'Finda': Colors.blue.shade50,
    // Add more social media options and their colors here
  };

  String getIconAssetPath(String socialMedia) {
    // Define mappings from social media names to icon asset paths
    Map<String, String> socialMediaIcons = {
      'Snapchat': 'assets/snapchat.png',
      'LinkedIn': 'assets/linkedin.png',
      'Pinterest': 'assets/pinterest.png',
      'Twitter': 'assets/twitter.png',
      'Instagram': 'assets/instagram.png',
      'Facebook': 'assets/facebook2.png',
      'Tiktok': 'assets/tiktok.png',
      'Youtube': 'assets/play.png',
      'Finda': 'assets/finda.png',
      // Add more mappings here
    };

    // Get the icon asset path based on the social media name
    return socialMediaIcons[socialMedia] ??
        'assets/default_icon.png'; // Provide a default icon path if not found
  }

  @override
  Widget build(BuildContext context) {
    var borderRadius = BorderRadius.circular(50.0);
    var labelStyle = TextStyle(fontSize: 17.sp);
    var floatingLabelStyle =  TextStyle(fontSize: 17.sp,color: Theme.of(context).colorScheme.tertiary);

    var style = TextStyle(fontSize: 17.sp);
    var contentPadding =
        EdgeInsets.symmetric(vertical: 13.0.h, horizontal: 10.w);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text('Add Social Link'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              DropdownButtonFormField(
                isDense: true,
                // Reduces the size of the dropdown
                value: selectedSocialMedia,
                dropdownColor: Theme.of(context).colorScheme.primary,

                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: borderRadius,
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: borderRadius, borderSide: BorderSide.none),
                  labelStyle: labelStyle,
                  contentPadding: contentPadding,
                  filled: true,
                 // fillColor: Theme.of(context).colorScheme.primary
                ),
                items: socialMediaOptions.map((SocialMediaOption option) {
                  return DropdownMenuItem(
                    value: option.name,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            option.iconAsset, // Image asset path
                            width: 24, // Adjust the width as needed
                            height: 24, // Adjust the height as needed
                          ),
                          SizedBox(width: 8),
                          // Adjust the spacing between icon and text
                          Text(
                            option.name,
                            style: TextStyle(fontSize: 20.sp),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedSocialMedia = newValue!;
                  });
                },
              ),
              SizedBox(height: 20.0.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have a link yet? Open $selectedSocialMedia ',
                    style:
                        TextStyle(fontSize: 15.sp, color: Colors.grey.shade600),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Theme.of(context).cardColor,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.open_in_new),
                      onPressed: () async {
                        // Get the selected social media name
                        String selectedMedia =
                            selectedSocialMedia.toLowerCase();

                        // Define app URL schemes for some common social media apps
                        Map<String, String> appURLs = {
                          'snapchat': 'snapchat://',
                          'linkedin': 'linkedin://',
                          'pinterest': 'pinterest://',
                          'twitter': 'twitter://',
                          'instagram': 'instagram://',
                          'facebook': 'facebook://',
                          'tiktok': 'tiktok://',
                          'youtube': 'youtube://',
                          'finda': 'finda://',
                          // Add more social media apps and their URL schemes here
                        };

                        // Check if the selected social media has a corresponding app URL scheme
                        if (appURLs.containsKey(selectedMedia)) {
                          // Launch the app if the URL scheme is available
                          if (await canLaunch(appURLs[selectedMedia]!)) {
                            launch(appURLs[selectedMedia]!);
                          } else {
                            // If the app is not installed, open in the default browser
                            await launch('https://www.$selectedMedia.com');
                          }
                        } else {
                          // If the URL scheme is not available, try to open in the default browser
                          await launch('https://www.$selectedMedia.com');
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0.h),
              TextFormField(
                controller: linkController,
                style: style,
                decoration: InputDecoration(
                  labelText: 'Enter link',
                  floatingLabelStyle: floatingLabelStyle,
                  border: OutlineInputBorder(
                    borderRadius: borderRadius,
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: borderRadius, borderSide: BorderSide.none),
                  labelStyle: labelStyle,
                  contentPadding: contentPadding,
                  filled: true,
                  //fillColor: Theme.of(context).colorScheme.primary
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter link';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0.h),
              GestureDetector(
                onTap: () async {
                  String link = linkController.text;
                  if (link.isEmpty) {
                    // Show an error message if the link field is empty
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Attention'),
                          content: Text('Link cannot be empty.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else if (!link.startsWith("https://")) {
                    // Show an error message if the link doesn't start with "https://"
                    setState(() {
                      linkController.clear(); // Clear the text field
                    });
                    linkController..text = link;
                    linkController
                      ..selection = TextSelection.collapsed(offset: 0);
                    ToastHelper.showShortToast(
                        "Link should start with 'https://'.");
                  } else {
                    // Set isLoading to true to disable the button while submitting
                    setState(() {
                      _isLoading = true;
                    });

                    // Call your saveLinkToDatabase function here
                    await saveLinkToDatabase(
                        link, selectedSocialMedia, context);

                    // Navigate back to the homepage and replace the current homepage
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) =>  HomePage()),
                    );
                    ToastHelper.showLongToast(
                        "Long press app icon for more options");
                    //load ad
                    _interstitialAd?.show();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: socialMediaColors[selectedSocialMedia],
                    // Use the selected color
                    borderRadius: borderRadius,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 35.w,
                    vertical: 10.h,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                      : Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 40.0.h),
              GestureDetector(
                onTap: () async {
                  // Get the selected social media name
                  String selectedMedia = selectedSocialMedia.toLowerCase();
                  // Define app URL schemes for some common social media apps
                  Map<String, String> appURLs = {
                    'snapchat': 'snapchat://',
                    'linkedin': 'linkedin://',
                    'pinterest': 'pinterest://',
                    'twitter': 'twitter://',
                    'instagram': 'instagram://',
                    'facebook': 'facebook://',
                    'tiktok': 'tiktok://',
                    'youtube': 'youtube://',
                    'finda': 'finda://',
                    // Add more social media apps and their URL schemes here
                  };

                  // Check if the selected social media has a corresponding app URL scheme
                  if (appURLs.containsKey(selectedMedia)) {
                    // Launch the app if the URL scheme is available
                    if (await canLaunch(appURLs[selectedMedia]!)) {
                      launch(appURLs[selectedMedia]!);
                    } else {
                      // If the app is not installed, open in the default browser
                      await launch('https://www.$selectedMedia.com');
                    }
                  } else {
                    // If the URL scheme is not available, try to open in the default browser
                    await launch('https://www.$selectedMedia.com');
                  }
                },
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0.0, _animation.value),
                      child: Container(
                        padding: EdgeInsets.all(30.h),
                        decoration: BoxDecoration(
                          // color: socialMediaOpenerColors[selectedSocialMedia],
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Image.asset(
                          getIconAssetPath(selectedSocialMedia),
                          // Get the icon path based on the selected social media
                          width: 120.w,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loadAd() {
    InterstitialAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (InterstitialAd ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
                // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {},
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  ad.dispose();
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  ad.dispose();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});

            // Keep a reference to the ad so you can show it later.
            _interstitialAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            // ignore: avoid_print
            print('InterstitialAd failed to load: $error');
          },
        ));
  }
}
