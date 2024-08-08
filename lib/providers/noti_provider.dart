import 'package:flutter/cupertino.dart';
import 'package:instagram_clone_1/models/noti.dart';
import 'package:instagram_clone_1/resources/firestore_methods.dart';

class NotiProvider extends ChangeNotifier {
  List<Noti> _data = <Noti>[];
  List<Noti> get notis => _data;

  fetchNotis() async {
    _data = await FirestoreMethods().getListNotiDetail();
    notifyListeners();
  }
}
