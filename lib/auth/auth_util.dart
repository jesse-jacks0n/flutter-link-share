// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
//
// import '../screens/home_screen.dart';
// import '../screens/links_screen.dart';
// import 'login_page.dart';
//
// class AuthPage extends StatelessWidget {
//   const AuthPage({Key? key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder<User?>(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             // Return a loading indicator or an empty container
//             return  Center(
//
//                 child: Image.asset(
//                     'assets/Spin.gif',
//                     width: 70,
//                     height: 70,
//                   ));
//           } else if (snapshot.hasData) {
//             // User is logged in, check if links data exists
//             final user = FirebaseAuth.instance.currentUser;
//             final databaseReference = FirebaseDatabase.instance.reference();
//             final userLinksRef = databaseReference.child('users/${user?.uid}/links');
//
//             return FutureBuilder<DatabaseEvent>(
//               future: userLinksRef.once(),
//               builder: (context, linksSnapshot) {
//                 if (linksSnapshot.connectionState == ConnectionState.waiting) {
//                   return  Center(
//                       child: Image.asset(
//                     'assets/Spin.gif',
//                     width: 70,
//                     height: 70,
//                   ));
//                 } else if (linksSnapshot.hasError) {
//
//                   //debugPrint('Error fetching links data: ${linksSnapshot.error}');
//                   return Text('Error: ${linksSnapshot.error}');
//                 } else if (linksSnapshot.hasData && linksSnapshot.data?.snapshot.value != null) {
//                  // debugPrint('Links data exists: ${linksSnapshot.data?.snapshot.value}');
//                   return const HomePage();
//                 } else {
//                   //debugPrint('Links data does not exist');
//                       return LinksPage();
//                 }
//               },
//             );
//
//           } else {
//             return const LoginPage();
//           }
//         },
//       ),
//     );
//   }
// }
//
//
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import 'login_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (authSnapshot.connectionState == ConnectionState.none) {
            return Center(
              child: Text('Error: ${authSnapshot.error}'),
            );
          } else if (authSnapshot.hasData) {
            return const HomePage();
          } else {
            return FutureBuilder<ConnectivityResult>(
              future: Connectivity().checkConnectivity(),
              builder: (context, connectivitySnapshot) {
                if (connectivitySnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (connectivitySnapshot.hasData &&
                    connectivitySnapshot.data == ConnectivityResult.none) {
                  return Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('No Internet Connection'),
                          ElevatedButton(
                            onPressed: () {
                              // Retry logic on button press
                              // You may want to handle retry logic based on your requirements
                              // For simplicity, you can call setState to trigger a rebuild
                              // or reload the AuthPage widget.
                            },
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const LoginPage();
                }
              },
            );
          }
        },
      ),
    );
  }
}
