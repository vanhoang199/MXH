import 'package:flutter/material.dart';

class ReplyCommentProvider extends ChangeNotifier {
  String userName = '';
  String commentId = '';

  void setField(String userName, commentId) {
    this.userName = userName;
    this.commentId = commentId;
    notifyListeners();
  }

  String getCommentId() {
    return commentId;
  }

  String getUserName() {
    return userName;
  }
}
