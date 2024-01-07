import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_1/Services/chat_service.dart';
import 'package:instagram_clone_1/resources/auth_methods.dart';
import 'package:instagram_clone_1/screens/video_call_page.dart';
import 'package:instagram_clone_1/utlis/text_field_input.dart';
import 'package:instagram_clone_1/models/user.dart' as user_model;
import 'package:instagram_clone_1/widgets/action_icon.dart';

class ChatPageVer1 extends StatefulWidget {
  final String recevierUserName;
  final String recevierUid;

  const ChatPageVer1(
      {super.key, required this.recevierUid, required this.recevierUserName});

  @override
  State<ChatPageVer1> createState() => _ChatPageVer1State();
}

//Dipose controller
class _ChatPageVer1State extends State<ChatPageVer1> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  user_model.User userRecevier = user_model.User.createsEmptyUser();

  bool _dataLoaded = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserRecevier();
    setState(() {
      _dataLoaded = false;
    });
  }

  getUserRecevier() async {
    userRecevier = await AuthMethods().getUserByUid(widget.recevierUid);
  }

  void sendMesage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.recevierUid, _messageController.text);
      //clear controller
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatRoomIds = _chatService.getChatRoomIds(
        FirebaseAuth.instance.currentUser!.uid, widget.recevierUid);
    return _dataLoaded
        ? const CircularProgressIndicator()
        : Scaffold(
            appBar: AppBar(
              centerTitle: false,
              title: Row(
                children: [
                  Flexible(
                    child: FutureBuilder(
                      future: AuthMethods().getUserByUid(widget.recevierUid),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          const Center(
                            child: Text('Xảy ra lỗi'),
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          const Center(
                            child: CircleAvatar(),
                          );
                        }

                        if (snapshot.hasData) {
                          return CircleAvatar(
                            backgroundImage:
                                NetworkImage(snapshot.data!.photoUrl),
                            radius: 20,
                          );
                        }
                        return const CircleAvatar();
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(widget.recevierUserName),
                ],
              ),
              actions: [
                ActionIcons(context, widget.recevierUid, null),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('vc')
                      .doc(ChatService().getChatRoomIds(
                          widget.recevierUid, _firebaseAuth.currentUser!.uid))
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        var data = snapshot.data?.data()?['VideoCall'] ?? false;
                        if (data == true) {
                          return IconButton(
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('vc')
                                    .doc(chatRoomIds)
                                    .set({'VideoCall': true});
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (_) => VideoCallPage(
                                            callID: chatRoomIds,
                                            user_id: FirebaseAuth
                                                .instance.currentUser!.uid,
                                            user_name: FirebaseAuth.instance
                                                    .currentUser!.email ??
                                                'NoName')));
                              },
                              icon: const Icon(Icons.video_call,
                                  color: Colors.green, size: 50));
                        } else {
                          return IconButton(
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('vc')
                                    .doc(chatRoomIds)
                                    .set({'VideoCall': true});
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (_) => VideoCallPage(
                                        callID: chatRoomIds,
                                        user_id: FirebaseAuth
                                            .instance.currentUser!.uid,
                                        user_name: FirebaseAuth
                                                .instance.currentUser!.email ??
                                            'NoName'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.video_call,
                                  color: Colors.white, size: 30));
                        }
                      } else if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                              "An error occured! Please check your internet connection."),
                        );
                      } else {
                        return const Center(
                          child: Text("Say hi to your new friend"),
                        );
                      }
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ],
            ),
            //TODO:ScrollViews
            body: Column(children: [
              Expanded(
                child: _buildMessageList(),
              ),
              _buildMessageInput(),
            ]),
          );
  }

  //_buildMessageList
  Widget _buildMessageList() {
    return StreamBuilder(
        stream: _chatService.getMessages(
            widget.recevierUid, _firebaseAuth.currentUser!.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            const Text('has error');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            const Text('Loading....');
          }
          return ListView(
            children:
                snapshot.data!.docs.map((e) => _buildMesssageItem(e)).toList(),
          );
        });
  }

  //TODO: BuildMessageItem
  Widget _buildMesssageItem(DocumentSnapshot document) {
    // late bool  showTime;
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    var aligment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    var color = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Colors.blue
        : Colors.pink[200];

    //Người gửi thì ko hiện thị ảnh
    var displayReciverImage =
        !(data['senderId'] == _firebaseAuth.currentUser!.uid);

    return Container(
      alignment: aligment,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.only(bottom: 4),
        width: MediaQuery.of(context).size.width * 0.75,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
              future: AuthMethods().getUserByUid(widget.recevierUid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  const Center(
                    child: Text('Xảy ra lỗi'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  const Center(
                    child: CircleAvatar(),
                  );
                }

                return displayReciverImage
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(userRecevier.photoUrl),
                        radius: 15,
                      )
                    : Container();
              },
            ),
            Expanded(
              child: Column(children: [
                Container(
                  alignment: aligment,
                  child: InkWell(
                    // onLongPress: () {

                    //   setState(() {
                    //     showTime = !showTime;
                    //   }); print('LongPress');
                    // },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          color: color,
                          border: Border.all(width: 2),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: Text(
                        data['message'],
                      ),
                    ),
                  ),
                ),
                Container(
                  alignment: aligment,
                  child: Text(data['timestamp'].toDate().toString()),
                )
                // showTime
                //     ? Container(
                //         alignment: aligment,
                //         child: Text(data['timestamp'].toDate().toString()),
                //       )
                //     : Container()
              ]),
            ),
          ],
        ),
      ),
    );
  }

  //

  //
  Widget _buildMessageInput() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          flex: 1,
          child: TextFieldInput(
            textInputType: TextInputType.text,
            textEditingController: _messageController,
            hintText: 'Enter Message',
            isPass: false,
          ),
        ),
        // Expanded(
        //     child: MyTextField(
        //         controller: _messageController,
        //         hintText: 'Nhập gì đó',
        //         obscureText: false)),
        IconButton(
          onPressed: sendMesage,
          icon: const Icon(
            Icons.arrow_upward,
            size: 40,
          ),
        ),
        // const MyButton(text: 'Gửi')
      ],
    );
  }
}
