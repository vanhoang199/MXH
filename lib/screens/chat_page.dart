import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_1/Services/chat_service.dart';
import 'package:instagram_clone_1/utlis/text_field_input.dart';

class ChatPage extends StatefulWidget {
  final String recevierUserEmail;
  final String recevierUid;
  const ChatPage(
      {super.key, required this.recevierUid, required this.recevierUserEmail});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recevierUserEmail),
      ),
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
