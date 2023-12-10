import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_1/Services/chat_service.dart';
import 'package:instagram_clone_1/screens/chat_page_ver1.dart';
import 'package:instagram_clone_1/utlis/colors.dart';

class ListUserVer1 extends StatefulWidget {
  const ListUserVer1({super.key});

  @override
  State<ListUserVer1> createState() => _ListUserVer1State();
}

class _ListUserVer1State extends State<ListUserVer1> {
  List uidFollowing = [];
  List uidFollower = [];
  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách bạn bè'),
        centerTitle: true,
        backgroundColor: mobileBackgroundColor,
      ),
      //body: _buildUserList(context),
      body: _buildUserList(context),
    );
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    try {
      getFollowing();
      getFollowers();
    } catch (e) {
      print(e);
    }
    setState(() {
      isLoading = false;
    });
  }

  getFollowing() async {
    var result = await ChatService().getListUidFollowing();
    setState(() {
      uidFollowing = result;
    });
  }

  getFollowers() async {
    var result = await ChatService().getListUidFollowers();
    setState(() {
      uidFollower = result;
    });
  }

  //Hàm kiểm tra,in ra uid của người theo dõi hoặc đang theo dõi
  Widget _buidFollowersOrFollowingUser(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : FutureBuilder(
            future: ChatService().getListUidFollowers(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Có lỗi!'),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: Text('Dữ liệu lỗi'),
                );
              }

              return ListView(
                children: snapshot.data!
                    .map<Widget>((doc) => _buildUserListItem(doc, context))
                    .toList(),
              );
            },
          );
  }

  isChatData(Map m) {
    //Kiểm tra
    //update: người lạ được chấp thuận
    // var mapUidIsFollowingOrIsFollwer = {};

    //1,following
    // for (var i in uidFollowing) {
    //   mapUidIsFollowingOrIsFollwer[i] = m.containsValue(i);
    // }
    for (var i in uidFollowing) {
      if (m.containsValue(i)) {
        return true;
      }
    }

    //2,follwer
    // for (var i in uidFollower) {
    //   mapUidIsFollowingOrIsFollwer.putIfAbsent(i, () => m.containsValue(i));
    // }
    for (var i in uidFollower) {
      if (m.containsValue(i)) {
        return true;
      }
    }
    // return mapUidIsFollowingOrIsFollwer.containsValue(true);
    return false;
  }

  //Hiển thị
  //Tên người theo dõi
  //Tên người đang theo dõi
  //Update: người lạ được cho phép
  Widget _buildUserList(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('uid')
                //.where('uid',whereNotIn: [FirebaseAuth.instance.currentUser!.uid])
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    '_buildUserList: ' 'Xin lỗi vì sự bất tiện',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: Text('_buildUserList: ' 'Dữ Liệu Lỗi'),
                );
              }

              var chatData = snapshot.data!.docs;

              chatData.removeWhere((element) => !isChatData(element.data()));
              for (var e in chatData) {
                (e.data()).toString();
              }

              return ListView(
                children: chatData
                    .map<Widget>((doc) => _buildUserListItem(doc, context))
                    .toList(),
              );
            },
          );
  }

  Widget _buildUserListItem(DocumentSnapshot document, BuildContext context) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    // Hiện tất cả người đăng kí tài khoản trừ người dùng hiện tại
    if (data.containsKey('uid')) {
      return ListTile(
        title: Text(data['username']),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPageVer1(
                  recevierUid: data['uid'], recevierUserName: data['username']),
            ),
          );
        },
      );
    } else {
      return const Center(
        child: Text('Chưa có bạn bè nào để trò chuyện'),
      );
    }
  }
}
