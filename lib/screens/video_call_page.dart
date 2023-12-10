import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class VideoCallPage extends StatelessWidget {
  const VideoCallPage({
    Key? key,
    required this.callID,
    required this.user_id,
    required this.user_name,
  }) : super(key: key);

  final String callID;
  final String user_id;
  final String user_name;

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: 102333969,
      appSign:
          "ea36a458902dcabda270352ff1bf57a17153c11b93c43722855a4b8f43ac9d8e",
      userID: user_id,
      userName: user_name,
      callID: callID,
      onDispose: () {
        FirebaseFirestore.instance
            .collection('vc')
            .doc(callID)
            .set({'VideoCall': false}).then((value) => Navigator.pop(context));
      },
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
        ..layout = ZegoLayout.pictureInPicture(
          isSmallViewDraggable: true,
          switchLargeOrSmallViewByClick: true,
        )
        ..onOnlySelfInRoom = (_) {
          FirebaseFirestore.instance
              .collection('vc')
              .doc(callID)
              .set({'VideoCall': false});
          return Navigator.pop(context);
        },
    );
  }
}
