import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_1/screens/add_post_screen.dart';
import 'package:instagram_clone_1/screens/feed_screen.dart';
import 'package:instagram_clone_1/screens/list_user.dart';
import 'package:instagram_clone_1/screens/list_user_ver1.dart';
import 'package:instagram_clone_1/screens/profile_screen.dart';
import 'package:instagram_clone_1/screens/search_screen.dart';

const webScreenSize = 600;

List<Widget> homeItemScreens = [
  const FeedScreen(),
  const SearchScreen(),
  const AddPostScreen(),
  const ListUserVer1(),
  ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid),
];
