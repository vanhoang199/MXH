// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Noti {
  String sendId;
  String sendGmail;
  String text;
  String postId;
  Timestamp time;
  String userId;
  String userGmail;
  Map<String, dynamic> isChecked;
  String photoUrl;
  String messId;
  Noti(
      {required this.sendId,
      required this.sendGmail,
      required this.text,
      required this.postId,
      required this.time,
      required this.userId,
      required this.userGmail,
      required this.isChecked,
      required this.photoUrl,
      required this.messId});

  static Noti fromJson(Map<String, dynamic> json) {
    json['isChecked'].runtimeType;
    return Noti(
        postId: json['postId'],
        sendId: json['sendId'],
        sendGmail: json['sendGmail'],
        text: json['text'],
        time: json['time'],
        userId: json['userId'],
        userGmail: json['userGmail'],
        isChecked: json['isChecked'],
        photoUrl: json['photoUrl'],
        messId: json['messId']);
  }

  bool getCheckState() {
    String key = FirebaseAuth.instance.currentUser!.uid;
    return isChecked[key] ?? false;
  }
}
