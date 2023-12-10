import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_1/Services/chat_service.dart';
import 'package:instagram_clone_1/screens/video_call_page.dart';
import 'package:instagram_clone_1/utlis/text_field_input.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recevierUserName),
        actions: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('vc')
                .doc(ChatService().getChatRoomIds(
                    widget.recevierUid, _firebaseAuth.currentUser!.uid))
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  DocumentSnapshot datasnapshot =
                      snapshot.data as DocumentSnapshot;

                  final data = snapshot.data?.data()?['VideoCall'] ?? false;
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
                                      user_name: FirebaseAuth
                                              .instance.currentUser!.email ??
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
                                  user_id:
                                      FirebaseAuth.instance.currentUser!.uid,
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

  //
  Widget _buildMesssageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    var aligment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerLeft
        : Alignment.centerRight;

    return Container(
      alignment: aligment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            crossAxisAlignment:
                (data['senderId'] == _firebaseAuth.currentUser!.uid)
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
            mainAxisAlignment:
                (data['senderId'] == _firebaseAuth.currentUser!.uid)
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
            children: [
              Text(data['senderEmail']),
              Text(data['message']),
            ]),
      ),
    );
  }

  //

  //
  Widget _buildMessageInput() {
    return Row(
      children: [
        Expanded(
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
