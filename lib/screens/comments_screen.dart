import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_1/models/user.dart';
import 'package:instagram_clone_1/providers/reply_comment_provider.dart';
import 'package:instagram_clone_1/providers/user_provider.dart';
import 'package:instagram_clone_1/resources/firestore_methods.dart';
import 'package:instagram_clone_1/utlis/colors.dart';
import 'package:instagram_clone_1/utlis/gobal_varible.dart';
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
    commentController.text = userNameComment;
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
          var pathCollection = FirebaseFirestore.instance
              .collection('posts')
              .doc(widget.snap['postId'])
              .collection('comments');

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: (snapshot.data! as dynamic).docs.length,
            itemBuilder: (context, index) => CommentCard(
              snap: (snapshot.data! as dynamic).docs[index].data(),
              pathCollection: pathCollection,
              dep: 0,
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
              CircleAvatar(
                // radius: 16,
                backgroundImage: NetworkImage(user.photoUrl),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                  child: Consumer<ReplyCommentProvider>(
                    builder: ((context, data, _) {
                      commentController.text = data.getUserName();
                      return TextField(
                        controller: commentController,
                        decoration: const InputDecoration(
                            hintText: 'Nhập bình luận',
                            border: InputBorder.none),
                      );
                    }),
                  ),
                ),
              ),
              Consumer<ReplyCommentProvider>(builder: (context, data, _) {
                return InkWell(
                  onTap: () async {
                    if (isComment) {
                      FirestoreMethods().postComment(
                          widget.snap['postId'],
                          commentController.text,
                          user.uid,
                          user.username,
                          user.photoUrl);
                    } else {
                      if (commentController.text.contains('@')) {
                        List<String> splitted =
                            commentController.text.split(' ');

                        String charactersAfterFirstSpace =
                            commentController.text.substring(
                                splitted[0].length + 1,
                                commentController.text.length);

                        FirestoreMethods().postReplyComment(
                            widget.snap['postId'],
                            data.getCommentId(),
                            charactersAfterFirstSpace,
                            user.uid,
                            user.username,
                            user.photoUrl);
                      } else {
                        FirestoreMethods().postComment(
                            widget.snap['postId'],
                            commentController.text,
                            user.uid,
                            user.username,
                            user.photoUrl);
                      }
                    }

                    data.setField('', '');
                    isComment = true;

                    commentController.text = '';
                  },
                  child: const Text(
                    'Đăng',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                );
              })
            ],
          ),
        ),
      ),
    );
  }
}
