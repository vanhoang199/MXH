import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone_1/screens/post_screen.dart';
import 'package:instagram_clone_1/screens/profile_screen_navigator_from_search.dart';
import 'package:instagram_clone_1/utlis/colors.dart';
import 'package:instagram_clone_1/widgets/suggest_friend.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;
  var isReloading;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isReloading = Object();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextFormField(
          decoration: const InputDecoration(
              labelText: 'Nhập tên người dùng cần tìm kiếm'),
          controller: searchController,
          onFieldSubmitted: (String s) {
            setState(() {
              isShowUsers = true;
            });
          },
        ),
      ),
      //TODO: fix bug - Another exception was thrown: Bad state: field does not exist within the DocumentSnapshotPlatform
      body: isShowUsers
          ? FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .where('username',
                      isGreaterThanOrEqualTo: searchController.text)
                  .where('username',
                      isLessThanOrEqualTo: '${searchController.text}\uf8ff')
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.connectionState == ConnectionState.done) {
                  return ListView.builder(
                    itemCount: (snapshot.data! as dynamic).docs.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () => Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProfileScreenNavigatorFromSearch(
                                        uid: (snapshot.data! as dynamic)
                                            .docs[index]['uid']),
                              ),
                            )
                            .then((value) => SearchScreen(
                                  key: UniqueKey(),
                                )),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(
                              (snapshot.data! as dynamic).docs[index]
                                  ['photoUrl'],
                            ),
                          ),
                          title: Text((snapshot.data! as dynamic).docs[index]
                              ['username']),
                        ),
                      );
                    },
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            )

          //TODO: Add inkwell navigator to post - check instagram hoạt động
          : ListView(
              children: [
                const SuggetFriend(),
                const Divider(color: Colors.white),
                FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('posts')
                      .where('uid',
                          isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Xảy ra lỗi ${snapshot.error.toString()}');
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return StaggeredGridView.countBuilder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      crossAxisCount: 3,
                      itemCount: (snapshot.data! as dynamic).docs.length,
                      itemBuilder: (contex, index) => InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) {
                            return PostScreen(
                              uid: (snapshot.data! as dynamic).docs[index]
                                  ['uid'],
                              postLongPressId: (snapshot.data! as dynamic)
                                  .docs[index]['postId'],
                              userPost: (snapshot.data! as dynamic).docs[index]
                                  ['username'],
                            );
                          }));
                        },
                        child: Image.network((snapshot.data! as dynamic)
                            .docs[index]['listPostImageUrl'][0]),
                      ),
                      staggeredTileBuilder: (index) => StaggeredTile.count(
                        (index % 7 == 0) ? 2 : 1,
                        (index % 7 == 0) ? 2 : 1,
                      ),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    );
                  },
                ),
              ],
            ),
    );
  }
}
