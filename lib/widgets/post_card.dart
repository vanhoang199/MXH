import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_1/models/user.dart';
import 'package:instagram_clone_1/providers/user_provider.dart';
import 'package:instagram_clone_1/resources/firestore_methods.dart';
import 'package:instagram_clone_1/screens/comments_screen.dart';
import 'package:instagram_clone_1/utlis/colors.dart';
import 'package:instagram_clone_1/utlis/utlis.dart';
import 'package:instagram_clone_1/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

//TODO: 1 bài đăng
//header post;
// body post;
// like,share, cmt;
// desc

class PostCard extends StatefulWidget {
  const PostCard({super.key, required this.snap});
  final snap;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimating = false;

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;
    return Container(
      color: mobileBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          //header post
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 16,
            ).copyWith(right: 0),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(widget.snap['profImage']),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.snap['username'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ),
                    //More_advert button
                    IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                    child: ListView(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shrinkWrap: true,
                                      children: ['Xóa', 'Thêm', 'Hoàn tác']
                                          .map(
                                            (e) => InkWell(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 12,
                                                  horizontal: 16,
                                                ),
                                                child: Text(e),
                                              ),
                                              onTap: () {},
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ));
                        },
                        icon: const Icon(Icons.more_vert)),
                  ],
                ),

                //body post
                GestureDetector(
                  onDoubleTap: () async {
                    await FirestoreMethods().likePost(
                      widget.snap['postId'],
                      user.uid,
                      widget.snap['likes'],
                    );
                    setState(() {
                      isLikeAnimating = true;
                    });
                  },
                  child: Stack(alignment: Alignment.center, children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.35,
                      width: double.infinity,
                      child: Image.network(
                        widget.snap['postUrl'],
                        fit: BoxFit.cover,
                      ),
                    ),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isLikeAnimating ? 1 : 0,
                      child: LikeAnimation(
                        isAnimating: isLikeAnimating,
                        duration: const Duration(milliseconds: 400),
                        onEnd: () {
                          setState(() {
                            isLikeAnimating = false;
                          });
                        },
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 200,
                        ),
                      ),
                    )
                  ]),
                ),

                //Like, share, cmt, bookmark
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      LikeAnimation(
                          isAnimating: widget.snap['likes'].contains(user.uid),
                          smallLike: true,
                          child: IconButton(
                            onPressed: () async {
                              FirestoreMethods().likePost(widget.snap['postId'],
                                  user.uid, widget.snap['likes']);
                            },
                            icon: widget.snap['likes'].contains(user.uid)
                                ? const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                  )
                                : const Icon(
                                    Icons.favorite_border_outlined,
                                  ),
                          )),
                      const SizedBox(
                        width: 5,
                      ),
                      IconButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (buildcontext) => CommentsScreen(
                                snap: widget.snap,
                              ),
                            ));
                          },
                          icon: const Icon(Icons.comment_outlined)),

                      const SizedBox(
                        width: 5,
                      ),
                      IconButton(
                          onPressed: () {
                            print('click');
                          },
                          icon: const Icon(Icons.share_outlined)),
                      // Expanded(
                      //   child: Align(
                      //     alignment: Alignment.bottomRight,
                      //     child: Icon(Icons.bookmark),
                      //   ),
                      // )
                      const Spacer(),
                      IconButton(
                          onPressed: () {}, icon: const Icon(Icons.bookmark))
                    ],
                  ),
                ),

                //desc post
                Container(
                  //color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DefaultTextStyle(
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(fontWeight: FontWeight.w800),
                        child: Text(
                          '${widget.snap['likes'].length} người thích',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(top: 8.0),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: primaryColor),
                            children: [
                              TextSpan(
                                  text: widget.snap['username'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              const TextSpan(text: ' '),
                              TextSpan(text: widget.snap['description']),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (buildcontext) => CommentsScreen(
                                snap: widget.snap,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('posts')
                                  .doc(widget.snap['postId'])
                                  .collection('comments')
                                  .snapshots(),
                              builder: (context, snap) {
                                if (snap.hasError) {
                                  return Text(
                                      'Xem các bình luận = $snap.error');
                                }
                                if (snap.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Column(
                                    children: [
                                      Text('Xem tất cả '),
                                      CircularProgressIndicator(),
                                      Text(' bình luận')
                                    ],
                                  );
                                }
                                return Text(
                                  "Xem tất cả ${snap.data?.size ?? 0} bình luận",
                                  style: const TextStyle(
                                      fontSize: 16, color: secondaryColor),
                                );
                              }),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          DateFormat.yMMMd()
                              .format(widget.snap['datePublished'].toDate()),
                          style: const TextStyle(
                              fontSize: 16, color: secondaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
