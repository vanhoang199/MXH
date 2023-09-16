import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clone_1/models/user.dart' as model;
import 'package:instagram_clone_1/resources/storage_method.dart';
import 'package:instagram_clone_1/utlis/logincode.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> signUpUser({
    required String username,
    required String email,
    required String password,
    required String bio,
    required Uint8List file,
  }) async {
    String res = Code().signUpFailure;
    try {
      if (username.isNotEmpty ||
          email.isNotEmpty ||
          password.isNotEmpty ||
          bio.isNotEmpty) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        String photoUrl = await StorageMethods()
            .upLoadImageToStorage(cred.user!.uid, file, false);

        model.User user = model.User(
            username: username,
            uid: cred.user!.uid,
            email: email,
            bio: bio,
            photoUrl: photoUrl,
            followers: [],
            following: []);

        await _firestore
            .collection('users')
            .doc(cred.user!.uid)
            .set(user.toJson());

        // id auto increment
        // await _firestore.collection('users').add({
        //   'username': username,
        //   'uid': userCred.user!.uid,
        //   'email': email,
        //   'bio': bio,
        //   'followers': [],
        //   'following': [],
        // });

        return res = Code().signUpSuccess;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        return res = 'Sai định dạng Email';
      } else if (e.code == 'email-already-in-use') {
        return res = 'Email đã được sử dụng!(Vui lòng nhập email khác)';
      } else if (e.code == 'weak-password') {
        return res = 'Mật khẩu yếu!(ít nhất 7 kí tự)';
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = Code().signUpFailure;

    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        //hanldeThenanale -> thiếu await cho hàm Future
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = Code().signUpSuccess;
      } else {
        print('Nhập hết các trường');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        return res = 'Địa chỉ Email sai';
      } else if (e.code == 'user-disabled') {
        return res = 'Tài khoản với email đã bị vô hiệu hóa';
      } else if (e.code == 'user-not-found') {
        return res = 'Email chưa đăng kí';
      } else if (e.code == 'wrong-password') {
        return res = 'Mật khẩu sai';
      }
    } catch (e) {
      return res = e.toString();
    }
    return res;
  }

  //Try Catch => Tài khoản bị xóa trên storage, mất thông tin
  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();
    return model.User.fromSnap(snapshot);
  }
}
