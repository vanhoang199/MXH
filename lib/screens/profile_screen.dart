import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_1/resources/auth_methods.dart';
import 'package:instagram_clone_1/resources/firestore_methods.dart';
import 'package:instagram_clone_1/screens/feed_saved.dart';
import 'package:instagram_clone_1/screens/login_screen.dart';
import 'package:instagram_clone_1/screens/post_screen.dart';
import 'package:instagram_clone_1/utlis/colors.dart';
import 'package:instagram_clone_1/widgets/follow_button.dart';
import 'package:instagram_clone_1/widgets/form_update_profile.dart';
import 'package:instagram_clone_1/widgets/suggest_friend.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;
  bool isShowSuggetUser = true;
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();

      postLen = postSnap.docs.length;
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      isFollowing = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);

      setState(() {});
    } catch (e) {
      //TODO: Create showSnackbar()
      print(e);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Text(userData['email']),
              centerTitle: false,
            ),
            body: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Xảy ra sự cố: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Text('Đang chờ lấy dữ liệu'));
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: Text('Không có dữ liệu về người dùng này'),
                    );
                  }
                  return ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.green,
                                  backgroundImage: NetworkImage(
                                      snapshot.data!.data()?['photoUrl']),
                                  radius: 40,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: buildStatColumn(
                                                  postLen, 'Bài viết')),
                                          Expanded(
                                            flex: 2,
                                            child: buildStatColumn(
                                                snapshot.data!
                                                    .data()?['followers']
                                                    .length,
                                                'Người theo dõi'),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: buildStatColumn(
                                                snapshot.data!
                                                    .data()?['following']
                                                    .length,
                                                'Người đang theo dõi'),
                                          ),
                                        ],
                                      ),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            FirebaseAuth.instance.currentUser!
                                                        .uid ==
                                                    widget.uid
                                                ? FollowButton(
                                                    text: 'Đăng xuất',
                                                    backGroundColor:
                                                        mobileBackgroundColor,
                                                    textColor: primaryColor,
                                                    broderColor: Colors.grey,
                                                    function: () async {
                                                      await FirestoreMethods()
                                                          .updateStatusUser(
                                                              'off');
                                                      await AuthMethods()
                                                          .signOut();

                                                      Navigator.of(context)
                                                          .pushReplacement(
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              const LoginScreen(),
                                                        ),
                                                      );
                                                    },
                                                  )
                                                : isFollowing
                                                    ? FollowButton(
                                                        text: 'Bỏ theo dõi',
                                                        backGroundColor:
                                                            Colors.white,
                                                        textColor: Colors.black,
                                                        broderColor:
                                                            Colors.grey,
                                                        function: () async {
                                                          await FirestoreMethods()
                                                              .followUser(
                                                                  FirebaseAuth
                                                                      .instance
                                                                      .currentUser!
                                                                      .uid,
                                                                  userData[
                                                                      'uid']);
                                                          setState(() {
                                                            isFollowing = false;
                                                            followers--;
                                                          });
                                                        },
                                                      )
                                                    : FollowButton(
                                                        text: 'Theo dõi',
                                                        backGroundColor:
                                                            Colors.blue,
                                                        textColor: Colors.white,
                                                        broderColor:
                                                            Colors.blue,
                                                        function: () async {
                                                          await FirestoreMethods()
                                                              .followUser(
                                                                  FirebaseAuth
                                                                      .instance
                                                                      .currentUser!
                                                                      .uid,
                                                                  userData[
                                                                      'uid']);
                                                          setState(() {
                                                            isFollowing = true;
                                                            followers++;
                                                          });
                                                        },
                                                      )
                                          ])
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(top: 15),
                              child: Text(
                                snapshot.data?.data()?['username'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(top: 1),
                              child: Text(
                                snapshot.data!.data()?['bio'],
                              ),
                            )
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: FollowButton(
                                function: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) =>
                                          const FormUpdateProfile()));
                                },
                                backGroundColor: Colors.blueAccent,
                                broderColor: Colors.white,
                                text: 'Chỉnh sửa hồ sơ',
                                textColor: Colors.white),
                          ),
                          Expanded(
                            flex: 1,
                            child: FollowButton(
                                function: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => const FeedSaved()));
                                },
                                backGroundColor: Colors.blueAccent,
                                broderColor: Colors.white,
                                text: 'Bài viết đã lưu',
                                textColor: Colors.white),
                          ),
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  isShowSuggetUser = !isShowSuggetUser;
                                });
                              },
                              icon: isShowSuggetUser
                                  ? const Icon(
                                      Icons.add_reaction_outlined,
                                    )
                                  : const Icon(
                                      Icons.add_reaction_rounded,
                                      color: Colors.grey,
                                    ))
                        ],
                      ),
                      isShowSuggetUser ? const SuggetFriend() : Container(),
                      const SizedBox(
                        height: 10,
                        width: double.infinity,
                      ),
                      const Divider(
                        color: Colors.white54,
                        height: 5,
                      ),
                      const SizedBox(
                        height: 10,
                        width: double.infinity,
                      ),
                      FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection('posts')
                            .where('uid', isEqualTo: widget.uid)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return GridView.builder(
                            shrinkWrap: true,
                            itemCount: (snapshot.data! as dynamic).docs.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 1.5,
                              childAspectRatio: 1,
                            ),
                            itemBuilder: (context, index) {
                              DocumentSnapshot snap =
                                  (snapshot.data! as dynamic).docs[index];
                              return InkWell(
                                onTap: () {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(builder: (_) {
                                    return PostScreen(
                                      uid: (snapshot.data! as dynamic)
                                          .docs[index]['uid'],
                                      postLongPressId:
                                          (snapshot.data! as dynamic)
                                              .docs[index]['postId'],
                                      userPost: (snapshot.data! as dynamic)
                                          .docs[index]['username'],
                                    );
                                  }));
                                },
                                child: Container(
                                  child: Image(
                                    image: NetworkImage(
                                      snap['listPostImageUrl'][0],
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      )
                    ],
                  );
                }),
          );
  }

  Column buildStatColumn(int number, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          number.toString(),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Column(
            children: label.split(' ').map((e) {
          return Text(e);
        }).toList())
      ],
    );
  }
}
