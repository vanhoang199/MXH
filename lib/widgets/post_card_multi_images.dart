import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_1/models/user.dart' as user_model;
import 'package:instagram_clone_1/providers/user_provider.dart';
import 'package:instagram_clone_1/resources/firestore_methods.dart';
import 'package:instagram_clone_1/screens/comments_screen.dart';
import 'package:instagram_clone_1/screens/profile_screen_navigator_from_search.dart';
import 'package:instagram_clone_1/utlis/colors.dart';
import 'package:instagram_clone_1/utlis/utlis.dart';
import 'package:instagram_clone_1/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart';

//TODO: 1 bài đăng
//header post;
// body post;
// like,share, cmt;
// desc

class PostCardFromMultiImages extends StatefulWidget {
  const PostCardFromMultiImages(
      {super.key, required this.snap, required this.nameRouter});
  final snap;
  final String nameRouter;

  @override
  State<PostCardFromMultiImages> createState() =>
      _PostCardFromMultiImagesState();
}

class _PostCardFromMultiImagesState extends State<PostCardFromMultiImages> {
  bool isLikeAnimating = false;
  final ScreenshotController _screenshotController = ScreenshotController();

  void _takeScreenshot(String username, String tittlePost) async {
    final uint8List = await _screenshotController.capture();
    String tempPath = (await getTemporaryDirectory()).path;
    String fileName = "shareSnapshotPosts";
    File file = await File('$tempPath/$fileName"}.png').create();
    file.writeAsBytesSync(uint8List!);
    await Share.shareFiles([file.path], text: '$username: $tittlePost');
  }

  _buildMoreVertItem() {
    List<String> itemsName = <String>['Xóa', 'Chỉnh Sửa', 'Hoàn Tác'];

    if (widget.nameRouter == 'FeedScreen') {
      if (widget.snap['uid'] != FirebaseAuth.instance.currentUser!.uid) {
        itemsName.remove('Xóa');
      }
    } else if (widget.nameRouter == 'FeedSaved') {
      itemsName.remove('Chỉnh Sửa');
    }
    showDialog(
        context: context,
        builder: (context) => Dialog(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
                shrinkWrap: true,
                children: itemsName
                    .map(
                      (e) => InkWell(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          child: Text(e),
                        ),
                        onTap: () async {
                          moreVertFunction(e, widget.nameRouter);
                          Navigator.of(context).pop();
                        },
                      ),
                    )
                    .toList(),
              ),
            ));
  }

  //'Xóa',
  //'Chỉnh Sửa',
  //'Hoàn Tác',
  moreVertFunction(String e, String nameRouter) async {
    if (e == 'Hoàn Tác') return;

    if (nameRouter == 'FeedScreen') {
      if (e == 'Xóa') {
        await FirestoreMethods().deletePost(widget.snap['postId']);
        // ignore: use_build_context_synchronously
        showSnackBar(
            '$e Bài viết ${widget.snap['postId'].substring(1, 5)} đã đăng',
            context);
      }
    } else if (nameRouter == 'FeedSaved') {
      if (e == 'Xóa') {
        await FirestoreMethods().deleteSavedPost(widget.snap['postId']);
        // ignore: use_build_context_synchronously
        showSnackBar(
            '$e Bài viết ${widget.snap['postId'].substring(1, 5)} đã lưu',
            context);
      }
      //Bug when delete
    } else if (nameRouter == 'ProfileScreen') {
      if (e == 'Xóa') {
        await FirestoreMethods().deletePost(widget.snap['postId']);
      }
    }
  }

  //TODO: build()
  @override
  Widget build(BuildContext context) {
    var length = widget.snap['listPostImageUrl'].length;
    List listPostImageUrl = widget.snap['listPostImageUrl'];
    final user_model.User user =
        Provider.of<UserProvider>(context).getUser; //TODO BAD CODE
    return Screenshot(
      controller: _screenshotController,
      child: Container(
        color: mobileBackgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            //header post
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 4,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) =>
                                        ProfileScreenNavigatorFromSearch(
                                            uid: widget.snap['uid'])));
                              },
                              child: Text(
                                widget.snap['username'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                      //More_advert button
                      IconButton(
                          onPressed: () {
                            _buildMoreVertItem();
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
                        child: ListView.builder(
                            itemCount: length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (_, index) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Stack(children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                listPostImageUrl[index]),
                                            fit: BoxFit.cover)),
                                    width: MediaQuery.of(context).size.width,
                                  ),
                                  length == 1
                                      ? Container()
                                      : Positioned(
                                          top: 10,
                                          right: 30,
                                          child: Text(
                                            'Ảnh ${index + 1}/$length',
                                            style: const TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 22),
                                          ),
                                        )
                                ]),
                              );
                            }),
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
                            isAnimating:
                                widget.snap['likes'].contains(user.uid),
                            smallLike: true,
                            child: IconButton(
                              onPressed: () async {
                                FirestoreMethods().likePost(
                                    widget.snap['postId'],
                                    user.uid,
                                    widget.snap['likes']);
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
                            onPressed: () => _takeScreenshot(
                                widget.snap['username'],
                                widget.snap['description']),
                            icon: const Icon(Icons.share_outlined)),
                        // Expanded(
                        //   child: Align(
                        //     alignment: Alignment.bottomRight,
                        //     child: Icon(Icons.bookmark),
                        //   ),
                        // )
                        const Spacer(),
                        widget.snap['uid'] ==
                                FirebaseAuth.instance.currentUser!.uid
                            ? Container()
                            : IconButton(
                                onPressed: () async {
                                  if (widget.snap['uid'] !=
                                      FirebaseAuth.instance.currentUser!.uid) {
                                    FirestoreMethods()
                                        .savedPost(widget.snap['postId']);
                                    showSnackBar(
                                        'Đã lưu về tường thành công', context);
                                  }
                                },
                                icon: const Icon(Icons.bookmark))
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
      ),
    );
  }
}
