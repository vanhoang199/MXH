import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:instagram_clone_1/utlis/colors.dart';
import 'package:instagram_clone_1/widgets/post_card_multi_images.dart';

class FeedSaved extends StatelessWidget {
  const FeedSaved({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        centerTitle: false,
        title: const Row(
          children: [
            Text('Các bài viết đã lưu'),
            Icon(
              Icons.bookmark,
              size: 20,
            ),
          ],
        ),
        actions: const [
          IconButton(onPressed: null, icon: Icon(Icons.clear_all))
        ],
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .where('uidsSaved',
                  arrayContainsAny: [(FirebaseAuth.instance.currentUser!.uid)])
              .orderBy('datePublished', descending: true)
              .snapshots(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Xảy ra sự cố!'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Column(
                children: [
                  CircularProgressIndicator(),
                  Text('Đang lấy dữ liệu, vui lòng chờ...'),
                ],
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: Text('Không có dữ liệu'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var length = snapshot.data!.docs[index]
                    .data()['listPostImageUrl']
                    .length;

                return PostCardFromMultiImages(
                  snap: snapshot.data!.docs[index].data(),
                  nameRouter: 'FeedSaved',
                );
              },
            );
          }),
    );
  }
}
