import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_1/screens/profile_screen_navigator_from_search.dart';
import 'package:instagram_clone_1/widgets/follow_button.dart';

class SuggetFriend extends StatefulWidget {
  const SuggetFriend({super.key});

  @override
  State<SuggetFriend> createState() => _SuggetFriendState();
}

class _SuggetFriendState extends State<SuggetFriend> {
  final Stream stream = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .snapshots();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Xảy ra lỗi: ${snapshot.error}'),
            );
          }
          if (snapshot.hasData) {
            List<dynamic> currentUserFollowing =
                snapshot.data!.data()['following'];
            currentUserFollowing.add(FirebaseAuth.instance.currentUser!.uid);

            return FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .where('uid', whereNotIn: currentUserFollowing)
                  .get(),
              builder: ((context, snapshot) {
                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                var snapshotdata = snapshot.data!.docs;
                if (snapshotdata.isNotEmpty) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.width * 0.3,
                    width: double.infinity,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshotdata.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Container(
                              height: MediaQuery.of(context).size.width * 0.35,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 0.5),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        snapshotdata[index]['photoUrl']),
                                  ),
                                  Expanded(
                                    child: Text(
                                      snapshotdata[index]['username'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(builder: (_) {
                                        return ProfileScreenNavigatorFromSearch(
                                            uid: snapshotdata[index]['uid']);
                                      }));
                                    },
                                    child: FollowButton(
                                      backGroundColor: Colors.blue,
                                      broderColor: Colors.white60,
                                      text: 'Xem người dùng',
                                      textColor: Colors.white,
                                      fontsize: 10,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
                  );
                }

                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Yahh!Bạn đã kết bạn với tất cả mọi người',
                    style: TextStyle(
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold),
                  ),
                );
              }),
            );
          }
          //Data null
          return const Text('Bạn đã kết bạn với tất cả người dùng!');
        });
  }
}
