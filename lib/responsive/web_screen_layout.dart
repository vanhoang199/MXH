import 'package:flutter/material.dart';
import 'package:instagram_clone_1/models/user.dart';
import 'package:instagram_clone_1/providers/user_provider.dart';
import 'package:provider/provider.dart';

class WebScreenLayout extends StatefulWidget {
  const WebScreenLayout({super.key});

  @override
  State<WebScreenLayout> createState() => _WebScreenLayoutState();
}

class _WebScreenLayoutState extends State<WebScreenLayout> {
  @override
  void initState() {
    super.initState();
    // getUserName();
  }

  // void getUserName() async {
  //   DocumentSnapshot snapshot = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(FirebaseAuth.instance.currentUser!.uid)
  //       .get();
  //   setState(() {
  //     // _userName = snapshot.data()!['username']; error typecheck
  //     _userName = (snapshot.data()! as Map<String, dynamic>)['username'];
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      body: Center(
        child: Text(user.username.isEmpty ? 'Đang Load' : user.username),
      ),
    );
  }
}
