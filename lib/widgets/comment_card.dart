import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_1/providers/reply_comment_provider.dart';
import 'package:instagram_clone_1/utlis/gobal_varible.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommentCard extends StatefulWidget {
  final snap;
  CollectionReference pathCollection;
  int dep;
  CommentCard(
      {super.key,
      required this.snap,
      required this.pathCollection,
      required this.dep});
  // final snap;

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  int countCmt = 0;
  bool isLoading = false;
  bool isShowCmt = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.dep == 0) {
      getCountCmt();
    }
  }

  void getCountCmt() async {
    setState(() {
      isLoading = true;
    });
    try {
      var replycollectionSnap = await widget.pathCollection
          .doc(widget.snap['commentId'])
          .collection('replycomment')
          .get();
      countCmt = replycollectionSnap.docs.length;

      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const CircleAvatar()
        : Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(widget.snap['profPic']),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                      text: widget.snap['name'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  TextSpan(
                                      text: widget.snap['text'],
                                      style:
                                          const TextStyle(color: Colors.white))
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    DateFormat.yMMMd().format(
                                      widget.snap['datePublished'].toDate(),
                                    ),
                                  ),
                                ),
                                Consumer<ReplyCommentProvider>(
                                  builder: (context, data, _) {
                                    return TextButton(
                                      onPressed: () {
                                        isComment = false;
                                        data.setField(
                                            '@${widget.snap['name']} ',
                                            widget.snap['commentId']);
                                      },
                                      child: const Text('Trả lời'),
                                    );
                                  },
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.amber,
                      child: const Icon(Icons.favorite),
                    )
                  ],
                ),
                countCmt > 0
                    ? isShowCmt
                        ? Container()
                        : (widget.dep == 0)
                            ? InkWell(
                                onTap: () {
                                  setState(() {
                                    isShowCmt = true;
                                  });
                                },
                                child: Text('Hiển thị tất cả $countCmt'),
                              )
                            : Container()
                    : Container(),
                isShowCmt
                    ? StreamBuilder(
                        stream: widget.pathCollection
                            .doc(widget.snap['commentId'])
                            .collection('replycomment')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text('Lỗi $snapshot.error');
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text('Đang tải tất cả cmt dữ liệu');
                          }

                          if (!snapshot.hasData) {
                            return const Text('Các cmt không còn tồn tại');
                          }

                          var replycommentDocs = snapshot.data!.docs;
                          return Container(
                            color: Colors.white,
                            alignment: Alignment.topRight,
                            padding: const EdgeInsets.symmetric(vertical: 8)
                              ..copyWith(
                                  left:
                                      MediaQuery.of(context).size.width * 0.2),
                            height: snapshot.data!.docs.length *
                                MediaQuery.of(context).size.height /
                                8,
                            width: double.infinity,
                            child: ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  color: Colors.red,
                                  child: CommentCard(
                                    snap: replycommentDocs[index].data(),
                                    pathCollection: widget.pathCollection
                                        .doc(widget.snap['commentId'])
                                        .collection('replycomment')
                                        .doc(replycommentDocs[0]
                                            .data()['commentId'])
                                        .collection('replycomment1'),
                                    dep: 1,
                                  ),
                                );
                              },
                            ),
                          );
                        })
                    : Container(),
              ],
            ),
          );
  }
}
