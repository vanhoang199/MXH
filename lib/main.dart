import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_1/screens/login_screen.dart';

import 'package:instagram_clone_1/utlis/colors.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyBFIhOY-yMOUW2lFeO4_ZXdtnpN7-er8bg',
          appId: '1:1037669616203:web:0768380ab482d89b229bce',
          messagingSenderId: '1037669616203',
          projectId: 'instagram-clone-1-a72b3',
          storageBucket: 'instagram-clone-1-a72b3.appspot.com'
          //authDomain: 'instagram-clone-1-a72b3.firebaseapp.com'
          ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: mobileBackgroundColor,
          snackBarTheme: const SnackBarThemeData(
              backgroundColor: primaryColor,
              actionTextColor: mobileBackgroundColor)),
      // home: const ResponsiveLayoutScreen(
      //   webScreenLayout: WebScreenLayout(),
      //   mobileScreenLayout: MobileScreenLayout(),
      // ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
