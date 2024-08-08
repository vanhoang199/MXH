import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_1/models/user.dart' as user_model;
import 'package:instagram_clone_1/providers/user_provider.dart';
import 'package:instagram_clone_1/resources/auth_methods.dart';
import 'package:instagram_clone_1/resources/firestore_methods.dart';
import 'package:instagram_clone_1/screens/chat_page_ver1.dart';
import 'package:instagram_clone_1/screens/login_screen.dart';
import 'package:instagram_clone_1/screens/post_screen.dart';
import 'package:instagram_clone_1/utlis/colors.dart';
import 'package:instagram_clone_1/widgets/follow_button.dart';
import 'package:provider/provider.dart';

class ProfileScreenNavigatorFromSearch extends StatefulWidget {
  final String uid;
  bool? isFollowing;
  ProfileScreenNavigatorFromSearch(
      {super.key, required this.uid, this.isFollowing});

  @override
  State<ProfileScreenNavigatorFromSearch> createState() =>
      _ProfileScreenNavigatorFromSearchState();
}

class _ProfileScreenNavigatorFromSearchState
    extends State<ProfileScreenNavigatorFromSearch> {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  late bool isFollowing;
  bool isLoading = false;
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
      isFollowing = widget.isFollowing ??
          userSnap
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
    user_model.User user = Provider.of<UserProvider>(context).getUser;
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
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.green,
                            backgroundImage: NetworkImage(userData['photoUrl']),
                            radius: 40,
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildStatColumn(postLen, 'Bài viết'),
                                    buildStatColumn(
                                        followers, 'Người theo dõi'),
                                    buildStatColumn(
                                        following, 'Người đang theo dõi'),
                                  ],
                                ),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      FirebaseAuth.instance.currentUser!.uid ==
                                              widget.uid
                                          ? FollowButton(
                                              text: 'Đăng xuất',
                                              backGroundColor:
                                                  mobileBackgroundColor,
                                              textColor: primaryColor,
                                              broderColor: Colors.grey,
                                              function: () async {
                                                await AuthMethods().signOut();
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
                                              ? Column(children: [
                                                  FollowButton(
                                                    text: 'Bỏ theo dõi',
                                                    backGroundColor:
                                                        Colors.white,
                                                    textColor: Colors.black,
                                                    broderColor: Colors.grey,
                                                    function: () async {
                                                      await FirestoreMethods()
                                                          .followUser(
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid,
                                                              userData['uid']);
                                                      setState(() {
                                                        isFollowing = false;
                                                        followers--;
                                                      });
                                                    },
                                                  ),
                                                  FollowButton(
                                                    backGroundColor:
                                                        Colors.blue,
                                                    broderColor: Colors.white,
                                                    text: 'Nhắn tin',
                                                    textColor: Colors.white,
                                                    function: () {
                                                      Navigator.of(context)
                                                          .push(
                                                              MaterialPageRoute(
                                                                  builder: (_) {
                                                        return ChatPageVer1(
                                                            recevierUid:
                                                                userData['uid'],
                                                            recevierUserName:
                                                                userData[
                                                                    'username']);
                                                      }));
                                                    },
                                                  )
                                                ])
                                              : FollowButton(
                                                  text: 'Theo dõi',
                                                  backGroundColor: Colors.blue,
                                                  textColor: Colors.white,
                                                  broderColor: Colors.blue,
                                                  function: () async {
                                                    await FirestoreMethods()
                                                        .followUser(
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid,
                                                            userData['uid']);
                                                    await FirestoreMethods()
                                                        .updateItemNotiCollection(
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid,
                                                      userData['uid'],
                                                    );
                                                    await FirestoreMethods()
                                                        .cItemMessCollect(
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid,
                                                            user.email,
                                                            user.photoUrl,
                                                            'Theo Dõi',
                                                            null,
                                                            userData['uid'],
                                                            userData['email']);
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
                          userData['username'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          userData['bio'],
                        ),
                      )
                    ],
                  ),
                ),
                const Divider(),
                FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('posts')
                      .where('uid', isEqualTo: widget.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
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
                                uid: (snapshot.data! as dynamic).docs[index]
                                    ['uid'],
                                postLongPressId: (snapshot.data! as dynamic)
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
            ),
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
