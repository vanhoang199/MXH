import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_1/models/user.dart';
import 'package:instagram_clone_1/providers/user_provider.dart';
import 'package:instagram_clone_1/resources/firestore_methods.dart';
import 'package:instagram_clone_1/utlis/colors.dart';
import 'package:instagram_clone_1/widgets/comment_card.dart';
import 'package:provider/provider.dart';

class CommentsScreen extends StatefulWidget {
  final snap;
  const CommentsScreen({super.key, required this.snap});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController commentController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      appBar: AppBar(
        // leading: const Icon(Icons.arrow_back),
        backgroundColor: mobileBackgroundColor,
        title: const Text('Comments'),
        centerTitle: false,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.snap['postId'])
            .collection('comments')
            .orderBy('datePublished', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: (snapshot.data! as dynamic).docs.length,
            itemBuilder: (context, index) => CommentCard(
              snap: (snapshot.data! as dynamic).docs[index].data(),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: kToolbarHeight,
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              const CircleAvatar(
                // radius: 16,
                backgroundImage: NetworkImage(
                    'https://upload.wikimedia.org/wikipedia/vi/b/b0/Avatar-Teaser-Poster.jpg'),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                  child: TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                        hintText: 'Nhập bình luận', border: InputBorder.none),
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  FirestoreMethods().postComment(
                      widget.snap['postId'],
                      commentController.text,
                      user.uid,
                      user.username,
                      user.photoUrl);
                  setState(() {
                    commentController.text = '';
                  });
                },
                child: const Text(
                  'Đăng',
                  style: TextStyle(color: Colors.blueAccent),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
