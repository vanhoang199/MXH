import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone_1/models/noti.dart';
import 'package:instagram_clone_1/resources/firestore_methods.dart';
import 'package:instagram_clone_1/screens/noti.dart';

import 'package:instagram_clone_1/utlis/colors.dart';
import 'package:instagram_clone_1/widgets/post_card_multi_images.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        centerTitle: false,
        title: SvgPicture.asset(
          'assets/ic_instagram.svg',
          // color: primaryColor,
          height: 32,
        ),
        //TODO: Thêm phần thông tin về ứng dụng
        actions: [
          IconButton(
            onPressed: () async {
              List<Noti> noti = await FirestoreMethods().getListNotiDetail();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                return NotiScreen(itemBuild: noti);
              }));
            },
            icon: const Icon(Icons.heart_broken_sharp),
          ),
          const IconButton(
            onPressed: null,
            icon: Icon(Icons.question_mark),
          )
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('datePublished', descending: true)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                return PostCardFromMultiImages(
                  snap: snapshot.data!.docs[index].data(),
                  nameRouter: 'FeedScreen',
                );
              });
        },
      ),
    );
  }
}
