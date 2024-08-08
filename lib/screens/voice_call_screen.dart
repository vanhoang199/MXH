import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class VoiceCallScreen extends StatelessWidget {
  const VoiceCallScreen({
    Key? key,
    required this.callId,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  final String callId;
  final String userId;
  final String userName;

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: 102333969,
      appSign:
          "ea36a458902dcabda270352ff1bf57a17153c11b93c43722855a4b8f43ac9d8e",
      userID: userId,
      userName: userName,
      callID: callId,
      onDispose: () {
        FirebaseFirestore.instance
            .collection('vc')
            .doc(callId)
            .set({'VoiceCall': false});
      },
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
        ..layout = ZegoLayout.pictureInPicture(
          isSmallViewDraggable: true,
          switchLargeOrSmallViewByClick: true,
        )
        ..onOnlySelfInRoom = (_) {
          FirebaseFirestore.instance
              .collection('vc')
              .doc(callId)
              .set({'VoiceCall': false});
        },
    );
  }
}
