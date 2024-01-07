// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Noti {
  String sendId;
  String sendUserName;
  String text;
  String postId;
  Timestamp time;
  String userId;
  String userName;
  List isChecked;
  Noti(
      {required this.sendId,
      required this.sendUserName,
      required this.text,
      required this.postId,
      required this.time,
      required this.userId,
      required this.userName,
      required this.isChecked});

  static Noti fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Noti(
        postId: snapshot['postId'],
        sendId: snapshot['sendId'],
        sendUserName: snapshot['sendUserName'],
        text: snapshot['text'],
        time: snapshot['time'],
        userId: snapshot['userId'],
        userName: snapshot['username'],
        isChecked: snapshot['isChecked']);
  }

  static Noti fromJson(Map<String, dynamic> json) {
    return Noti(
        postId: json['postId'],
        sendId: json['sendId'],
        sendUserName: json['sendUserName'],
        text: json['text'],
        time: json['time'],
        userId: json['userId'],
        userName: json['username'],
        isChecked: json['isChecked']);
  }
}
