import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_1/providers/user_provider.dart';
import 'package:instagram_clone_1/responsive/mobile_screen_layout.dart';
import 'package:instagram_clone_1/responsive/responsive_layout_screen.dart';
import 'package:instagram_clone_1/responsive/web_screen_layout.dart';
import 'package:instagram_clone_1/screens/login_screen.dart';

import 'package:instagram_clone_1/utlis/colors.dart';
import 'package:provider/provider.dart';

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
  // ErrorWidget.builder = (FlutterErrorDetails flutterErrorDetails) =>
  //     errorScreen(flutterErrorDetails.exception);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: mobileBackgroundColor,
        ),
        home: StreamBuilder(
          // sign in + sign out
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: ((context, snapshot) {
            //TODO: Check data

            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                return const ResponsiveLayoutScreen(
                  webScreenLayout: WebScreenLayout(),
                  mobileScreenLayout: MobileScreenLayout(),
                );
              } else if (snapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Text(snapshot.error.toString()),
                  ),
                );
              }
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                ),
              );
            }
            return const LoginScreen();
          }),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
