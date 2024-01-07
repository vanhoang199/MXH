// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:instagram_clone_1/models/noti.dart';
import 'package:instagram_clone_1/models/post.dart';
import 'package:instagram_clone_1/screens/profile_screen_navigator_from_search.dart';

class NotiScreen extends StatefulWidget {
  final List<Noti> itemBuild;
  const NotiScreen({
    Key? key,
    required this.itemBuild,
  }) : super(key: key);

  @override
  State<NotiScreen> createState() => _NotiScreenState();
}

class _NotiScreenState extends State<NotiScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
          itemCount: widget.itemBuild.length,
          itemBuilder: (contex, index) {
            String text =
                "${widget.itemBuild[index].sendUserName} ${widget.itemBuild[index].text}${widget.itemBuild[index].postId}";
            if (widget.itemBuild[index].text == 'Theo Dõi') {
              text =
                  "${widget.itemBuild[index].sendUserName} ${widget.itemBuild[index].text} ${widget.itemBuild[index].userName}";
            }
            return Container(
                color: Colors.red,
                child: ListTile(
                  leading: const CircleAvatar(),
                  title: Text(text),
                  trailing: TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) {
                        return ProfileScreenNavigatorFromSearch(
                            uid: widget.itemBuild[index].userId);
                      }));
                    },
                    child: const Text('Theo dõi'),
                  ),
                ));
          }),
    );
  }
}
