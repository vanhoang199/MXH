import 'package:flutter/material.dart';
import 'package:instagram_clone_1/utlis/colors.dart';

//TODO: 1 bài đăng
//header post;
// body post;
// like,share, cmt;
// desc

class PostCard extends StatelessWidget {
  const PostCard({super.key});

  @override
  Widget build(BuildContext context) {
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
                    const CircleAvatar(
                      radius: 16,
                      backgroundImage:
                          NetworkImage('https://picsum.photos/id/237/200/300'),
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'username',
                              style: TextStyle(fontWeight: FontWeight.bold),
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
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  child: Image.network(
                    'https://picsum.photos/id/237/200/300',
                    fit: BoxFit.cover,
                  ),
                ),

                //Like, share, cmt, bookmark
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          )),
                      const SizedBox(
                        width: 5,
                      ),
                      IconButton(
                          onPressed: () {
                            print('click');
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
                          '123 likes',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(top: 8.0),
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(color: primaryColor),
                            children: [
                              TextSpan(
                                  text: "Tên người dùng",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: " Mô tả post"),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          //chuyển hướng đến bình luận
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: const Text(
                            "Xem tất cả cmt",
                            style:
                                TextStyle(fontSize: 16, color: secondaryColor),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: const Text(
                          "10/10/2023",
                          style: TextStyle(fontSize: 16, color: secondaryColor),
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
