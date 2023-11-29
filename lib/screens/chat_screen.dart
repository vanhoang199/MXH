import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_1/resources/firestore_methods.dart';

class chatscreen extends StatefulWidget {
  const chatscreen({super.key});

  @override
  State<chatscreen> createState() => _chatscreenState();
}

class _chatscreenState extends State<chatscreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getList();
  }

  getList() async {}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          DocumentSnapshot documentSnapshot = snapshot.data!;
          List following = (documentSnapshot as dynamic)['following'];

          // Sử dụng dữ liệu từ documentSnapshot ở đây để hiển thị trong widget

          return Text(following.toString());
        }
      },
    );
  }
}
