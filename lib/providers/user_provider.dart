import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_1/Services/chat_service.dart';
import 'package:instagram_clone_1/models/user.dart' as user_model;
import 'package:instagram_clone_1/resources/auth_methods.dart';

class UserProvider extends ChangeNotifier {
  user_model.User? _user = user_model.User(
    email: '',
    uid: '',
    photoUrl: '',
    username: '',
    bio: '',
    followers: [],
    following: [],
  );
  final AuthMethods _authMethods = AuthMethods();

  user_model.User get getUser => _user!;

  Future<void> refreshUser() async {
    user_model.User user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}

class SuggestFriendProvider extends ChangeNotifier {
  Stream? _stream = const Stream.empty();

  Stream get getUser => _stream!;

  Future<void> refreshSuggetFriend() async {
    List listFollowing = await ChatService().getListUidFollowing();
    listFollowing.add(FirebaseAuth.instance.currentUser!.uid);
    _stream = FirebaseFirestore.instance
        .collection('users')
        .where('uid', whereNotIn: listFollowing)
        .snapshots();
    notifyListeners();
  }
}
