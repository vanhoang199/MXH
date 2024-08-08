import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_1/models/noti.dart';
import 'package:instagram_clone_1/models/post.dart';
import 'package:instagram_clone_1/resources/storage_method.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //TODO: POST
  //Create + Upload a Post
  //Thành công trả về postId
  //Lỗi trả về "Lỗi"
  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String username,
    String profImage,
    List<Uint8List>? listImageFile,
    List<Uint8List>? listVideoFile,
  ) async {
    String res = "Lỗi";
    List listPostImageUrl = [];
    try {
      // String photoUrl =
      //     await StorageMethods().upLoadImageToStorage('posts', file, true);

      if (listImageFile != null) {
        if (listImageFile.isNotEmpty) {
          for (var file in listImageFile) {
            String photoUrl1 = await StorageMethods()
                .upLoadImageToStorage('posts', file, true);
            listPostImageUrl.add(photoUrl1);
          }
        }
      }

      String postId = const Uuid().v1();

      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        likes: [],
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: '',
        profImage: profImage,
        listPostImageUrl: listPostImageUrl,
        listPostVideoUrl: [],
      );

      _firestore.collection('posts').doc(postId).set(post.toJson());

      res = postId;
    } catch (e) {
      res = e.toString();
    }

    return res;
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        //set = pass all para
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  //update: ảnh/video của bài đăng
  Future<void> updatePost(String desc) async {
    try {
      await _firestore
          .collection('posts')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'de': desc});
      debugPrint('call this function');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  //Xóa post dựa trên postId được nhận
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  //Lưu người dùng lưu trữ bài đăng
  Future<void> savedPost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'uidsSaved':
            FieldValue.arrayUnion([(FirebaseAuth.instance.currentUser!.uid)])
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteSavedPost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'uidsSaved':
            FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  //TODO: Comment
  //Tạo comment cho 1 post
  Future<void> postComment(String postId, String text, String uid, String name,
      String profPic) async {
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profPic': profPic,
          'name': name,
          'uid': uid,
          'commentId': commentId,
          'datePublished': DateTime.now(),
          'text': ' $text'
        });
      } else {
        debugPrint('Nội dung bình luận bị bỏ trống');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> postReplyComment(String postId, String commentId, String text,
      String uid, String name, String profPic) async {
    try {
      if (text.isNotEmpty) {
        String replycommentId = const Uuid().v1();
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('replycomment')
            .doc(replycommentId)
            .set({
          'profPic': profPic,
          'name': name,
          'uid': uid,
          'commentId': commentId,
          'datePublished': DateTime.now(),
          'text': ' $text'
        });
      } else {
        debugPrint('Text is empty');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  //TODO: User
  Future<void> updateProfile(String username, String email, String bio) async {
    try {
      await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'username': username, 'email': email, 'bio': bio});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateStatusUser(String status) async {
    try {
      await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'status': status});
      debugPrint('call this function');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateNotiUser(bool hasNoti) async {
    try {
      await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'hasNoti': hasNoti});
      debugPrint('call this function');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> followUser(String uid, String followId) async {
    DocumentSnapshot snap = await _firestore.collection('users').doc(uid).get();
    List following = (snap.data()! as dynamic)['following'];

    if (following.contains(followId)) {
      await _firestore.collection('users').doc(followId).update({
        'followers': FieldValue.arrayRemove([uid])
      });
      await _firestore.collection('users').doc(uid).update({
        'following': FieldValue.arrayRemove([followId])
      });
    } else {
      await _firestore.collection('users').doc(followId).update({
        'followers': FieldValue.arrayUnion([uid])
      });

      await _firestore.collection('users').doc(uid).update({
        'following': FieldValue.arrayUnion([followId])
      });
    }
  }

  //TODO: Thông báo
  createItemNotiCollection(String sendUid) async {
    await _firestore.collection('noti').doc(sendUid).set({});
  }

  updateItemNotiCollection(String sendUid, String recUid) async {
    await _firestore.collection('noti').doc(sendUid).update({
      'listRecUid': FieldValue.arrayUnion([recUid])
    });
  }

  Future<List<dynamic>> getListRecUid() async {
    DocumentSnapshot snapshot = await _firestore
        .collection('noti')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    var data = snapshot.data() as Map<String, dynamic>;
    return data['listRecUid'];
  }

  //TODO: NOTI
  //text: Đăng bài -> postId không null
  //text: Theo dõi -> userId không null
  cItemMessCollect(String sendUid, String sendGmail, String photoUrl,
      String text, String? postId, String? userId, String? userGmail) async {
    List<dynamic> listRecUid = await getListRecUid();
    Map<String, bool> isChecked = {for (var item in listRecUid) item: false};
    List<String> docIds = listRecUid.map((e) => e.toString()).toList();
    String messId = const Uuid().v1();
    await _firestore
        .collection('noti')
        .doc(sendUid)
        .collection('mess')
        .doc(messId)
        .set({
      'messId': messId,
      'userId': userId ?? '',
      'sendGmail': sendGmail,
      'photoUrl': photoUrl,
      'text': text,
      'postId': postId ?? '',
      'sendId': FirebaseAuth.instance.currentUser!.uid,
      'userGmail': userGmail ?? '',
      'time': Timestamp.now(),
      'isChecked': isChecked,
    });

    updateFieldInMultipleDocuments('users', docIds, 'hasNoti', true);
  }

  uItemMessCollection(
      String sendUid, String messId, Map<String, dynamic> isChecked) async {
    _firestore
        .collection('noti')
        .doc(sendUid)
        .collection('mess')
        .doc(messId)
        .update({'isChecked': isChecked});
  }

  void updateFieldInMultipleDocuments(String collectionName,
      List<String> documentIds, String fieldToUpdate, dynamic newValue) async {
    // Reference to the collection
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection(collectionName);

    // Create a batch
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // Update the field in each document in the batch
    for (String documentId in documentIds) {
      DocumentReference docRef = collectionRef.doc(documentId);
      batch.update(docRef, {fieldToUpdate: newValue});
    }

    // Commit the batch
    await batch.commit();
    print('Fields updated successfully.');
  }

  Future<List<Noti>> getListNotiDetail() async {
    List<Noti> itemsBuildNotiUi = [];
    List<String> documentIds = [];

    String docId = FirebaseAuth.instance.currentUser!.uid;

    QuerySnapshot data = await FirebaseFirestore.instance
        .collection('noti')
        .where('listRecUid', arrayContains: docId)
        .get();

    for (var e in data.docs) {
      documentIds.add(e.id);
    }

    if (documentIds.isNotEmpty) {
      for (var id in documentIds) {
        try {
          var snapshot = await _firestore
              .collection('noti')
              .doc(id)
              .collection('mess')
              .get();
          for (var doc in snapshot.docs) {
            itemsBuildNotiUi.add(Noti.fromJson(doc.data()));
          }
        } catch (e) {
          debugPrint(e.toString());
        }
      }
    }

    //sort theo thời gian dảm giần
    itemsBuildNotiUi.sort((a, b) => a.time.compareTo(b.time));
    List<Noti> reslut = itemsBuildNotiUi.reversed.toList();
    return reslut;
  }
}
