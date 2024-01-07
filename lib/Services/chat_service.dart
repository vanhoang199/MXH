import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_1/models/message.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  //Send message
  Future<void> sendMessage(String receiverId, String message) async {
    //get current user info
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String email = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    // create a new message
    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: email,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
    );
    //construct chat rom id from current user id and recevier id
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    //add new message to database
    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  //GET  MESSAGE
  Stream<QuerySnapshot> getMessages(String userId, String otherId) {
    List<String> ids = [userId, otherId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<Map<String, dynamic>> getLastMessages(
      String userId, String otherId) async {
    List<String> ids = [userId, otherId];
    ids.sort();
    String chatRoomId = ids.join("_");

    QuerySnapshot<Map<String, dynamic>> lastMessages = await FirebaseFirestore
        .instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    return lastMessages.docs[0].data();
  }

  Future<List> getListUidFollowing() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
    List uidFollowing = data['following'];
    return uidFollowing;
  }

  Future<List> getListUidFollowers() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
    List uidFollowers = data['followers'];
    return uidFollowers;
  }

  Future<List> getkownUsersUidList() async {
    var listFollower = await getListUidFollowers();
    var listFollowing = await getListUidFollowing();
    var knowUsersUid = [];
    knowUsersUid.addAll(listFollower);
    knowUsersUid.addAll(listFollowing);
    return knowUsersUid;
  }

  String getChatRoomIds(String userId, otherId) {
    List<String> ids = [userId, otherId];
    ids.sort();
    String chatRoomId = ids.join("_");
    return chatRoomId;
  }

  Future<String> deleteDocument(String documentId) async {
    String result = 'Thất bại';
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection(
              'chat_rooms') // Thay thế 'collection_name' bằng tên collection của bạn
          .doc(documentId)
          .collection('messages')
          .get();

      for (var documentSnapshot in snap.docs) {
        await documentSnapshot.reference.delete();
      }
      result = 'Thành công';
    } catch (e) {
      print(e.toString());
    }
    return result;
  }
}
