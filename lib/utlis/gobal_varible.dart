import 'package:flutter/material.dart';
import 'package:instagram_clone_1/screens/add_post_screen.dart';
import 'package:instagram_clone_1/screens/feed_screen.dart';
import 'package:instagram_clone_1/screens/search_screen.dart';

const webScreenSize = 600;

const homeItemScreens = [
  FeedScreen(),
  SearchScreen(),
  AddPostScreen(),
  Text('Farvourite'),
  Text('Person'),
];
