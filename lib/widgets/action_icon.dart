import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Widget ActionIcons(BuildContext context, String uid, double? sizeIcon) {
  return StreamBuilder(
    stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.active) {
        if (snapshot.hasData) {
          var data = snapshot.data?.data()?['status'] ?? 'off';
          if (data == 'onl') {
            return Icon(Icons.circle_rounded,
                color: Colors.green, size: sizeIcon ?? 20);
          } else {
            return Icon(Icons.circle_rounded,
                color: Colors.grey, size: sizeIcon ?? 20);
          }
        } else if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        } else {
          return const Center(
            child: Text("Không có thông tin"),
          );
        }
      } else {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
    },
  );
}
