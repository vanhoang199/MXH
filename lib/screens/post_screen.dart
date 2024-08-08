import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:instagram_clone_1/widgets/post_card_multi_images.dart';

class PostScreen extends StatefulWidget {
  final String uid;
  final String userPost;
  final String postLongPressId;

  const PostScreen({
    super.key,
    required this.postLongPressId,
    required this.userPost,
    required this.uid,
  });

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  String currentUid = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Bài đăng của ${currentUid == widget.uid ? 'tôi' : widget.userPost}'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('postId', isEqualTo: widget.postLongPressId)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.data!.docs.isEmpty) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pop();
            });
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) => PostCardFromMultiImages(
                snap: snapshot.data!.docs[index].data(),
                nameRouter: 'ProfileScreen'),
          );
        },
      ),
    );
  }
}
