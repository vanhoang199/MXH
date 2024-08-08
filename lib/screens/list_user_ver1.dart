import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_1/Services/chat_service.dart';
import 'package:instagram_clone_1/screens/chat_page_ver1.dart';
import 'package:instagram_clone_1/utlis/colors.dart';
import 'package:instagram_clone_1/widgets/action_icon.dart';

class ListUserVer1 extends StatefulWidget {
  const ListUserVer1({super.key});

  @override
  State<ListUserVer1> createState() => _ListUserVer1State();
}

class _ListUserVer1State extends State<ListUserVer1> {
  final ChatService _chatService = ChatService();
  final String _currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách bạn bè'),
        centerTitle: true,
        backgroundColor: mobileBackgroundColor,
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const AlertDialog(
                      title: Text('Giải thích'),
                      content: Text(
                          '1, Bạn bè mới xem được lịch sử \n2, Kết bạn bằng cách theo dõi người dùng và người dùng đó theo dõi lại bạn')),
                );
              },
              icon: const Icon(Icons.question_mark))
        ],
      ),

      //body: _buildUserList(context),
      body: _buildUserList(context),
    );
  }

  //snapshot trên người dùng hiện tại
  //bạn bè = phần giao giữa 2 list người theo dõi và đang theo dõi
  Widget _buildUserList(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
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

        final curUsersDetail = snapshot.data!.data();
        var followers = curUsersDetail!['followers'].toSet();
        var following = curUsersDetail['following'].toSet();
        var friends = following.intersection(followers).toList();

        return ListView(
          children: friends
              .map<Widget>((uid) => _buildUserListItem(uid, context))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(String uid, BuildContext context) {
    return FutureBuilder(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Xảy ra sự cố: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Text('Vui lòng chờ, đang tải'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.exists == false) {
            return const Text('Không tìm thấy dữ liệu');
          }

          var data = snapshot.data!.data();
          return ListTile(
            minLeadingWidth: 50,
            leading: Stack(children: [
              CircleAvatar(
                backgroundImage: NetworkImage(data!['photoUrl']),
              ),
              Positioned(
                  height: 30,
                  width: 30,
                  bottom: -5,
                  right: -5,
                  child: ActionIcons(context, data['uid'], 23))
            ]),
            title: Text(
              data['username'],
              style: const TextStyle(fontSize: 20),
            ),
            subtitle: _getLastMessages(uid, context),
            trailing: const Text(
              '',
              textAlign: TextAlign.justify,
            ),
            onLongPress: () {
              showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      title: const Text('Xóa lịch sử!'),
                      content: const Text(
                          'Mọi tin nhắn giữa bạn và người dùng này sẽ mất hết\n'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            textStyle: Theme.of(context).textTheme.labelLarge,
                          ),
                          child: const Text('Từ chối'),
                        ),
                        TextButton(
                          onPressed: () {
                            _chatService.deleteDocument(_chatService
                                .getChatRoomIds(uid, _currentUserUid));
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            textStyle: Theme.of(context).textTheme.labelLarge,
                          ),
                          child: const Text('Đồng ý'),
                        )
                      ],
                    );
                  });
            }, //Xóa tin nhắn với người dùng này
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPageVer1(
                      recevierUid: data['uid'],
                      recevierUserName: data['username']),
                ),
              );
            },
          );
        });
  }

  Widget _getLastMessages(String uid, BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat_rooms')
            .doc(_chatService.getChatRoomIds(uid, _currentUserUid))
            .collection('messages')
            .snapshots(),
        builder: (context, snapshot) {
          return FutureBuilder(
              future: _chatService.getLastMessages(uid, _currentUserUid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  Text('Lấy dữ liệu: ${snapshot.error.toString()}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Đang lấy tin nhắn gần nhất');
                }

                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Chưa có tin nhắn nào!'),
                  );
                }

                String daySended =
                    snapshot.data!['timestamp'].toDate().day.toString();
                String monthSended =
                    snapshot.data!['timestamp'].toDate().month.toString();
                return snapshot.data!['senderId'] == _currentUserUid
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 8,
                            child: SizedBox(
                              child: Text('Bạn: ${snapshot.data!['message']} ',
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '$daySended-$monthSended',
                              textAlign: TextAlign.right,
                            ),
                          )
                        ],
                      )
                    : Text(
                        snapshot.data!['message'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
              });
        });
  }
}
