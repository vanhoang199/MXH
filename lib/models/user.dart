// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String username;
  final String uid;
  final String email;
  final String bio;
  final String photoUrl;
  final List followers;
  final List following;

  User({
    required this.username,
    required this.uid,
    required this.email,
    required this.bio,
    required this.photoUrl,
    required this.followers,
    required this.following,
  });

  // factory User.fromJson(String source) => User.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'uid': uid,
      'email': email,
      'bio': bio,
      'followers': followers,
      'following': following,
      'photoUrl': photoUrl,
    };
  }

  factory User.empty() {
    return User(
        username: 'username',
        uid: 'uid',
        email: 'email',
        bio: 'bio',
        photoUrl: 'photoUrl',
        followers: [],
        following: []);
  }

  static User fromSnap(DocumentSnapshot snapshot) {
    var snap = snapshot.data() as Map<String, dynamic>;
    return User(
      username: snap['username'],
      uid: snap['uid'],
      email: snap['email'],
      bio: snap['bio'],
      photoUrl: snap['photoUrl'],
      followers: snap['followers'],
      following: snap['following'],
    );
  }
}
