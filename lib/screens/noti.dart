// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_1/Services/chat_service.dart';

import 'package:instagram_clone_1/models/noti.dart';
import 'package:instagram_clone_1/models/user.dart' as user_model;
import 'package:instagram_clone_1/providers/noti_provider.dart';
import 'package:instagram_clone_1/providers/user_provider.dart';
import 'package:instagram_clone_1/resources/firestore_methods.dart';
import 'package:instagram_clone_1/screens/profile_screen_navigator_from_search.dart';
import 'package:instagram_clone_1/widgets/follow_button.dart';
import 'package:provider/provider.dart';

class NotiScreen extends StatefulWidget {
  const NotiScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<NotiScreen> createState() => _NotiScreenState();
}

class _NotiScreenState extends State<NotiScreen> {
  fecthData() async {
    await Provider.of<NotiProvider>(context).fetchNotis();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    fecthData();
  }

  @override
  Widget build(BuildContext context) {
    user_model.User user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Thông báo'),
        ),
        body: Consumer<NotiProvider>(builder: (_, data, __) {
          return ListView.builder(
              itemCount: data.notis.length,
              itemBuilder: (context, index) {
                return data.notis[index].text != 'Theo Dõi'
                    ? PostNoti(noti: data.notis[index])
                    : FollowingNoti(noti: data.notis[index], user: user);
              });
        }));
  }
}

class PostNoti extends StatelessWidget {
  final Noti noti;
  const PostNoti({super.key, required this.noti});
  Widget _buildNewPostMessage(Noti noti, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) {
          return ProfileScreenNavigatorFromSearch(uid: noti.sendId);
        }));
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(noti.photoUrl),
        ),
        title: RichText(
          text: TextSpan(
              text: noti.sendGmail,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white),
              children: [
                TextSpan(
                    text: ' ${noti.text.toLowerCase()} viết mới',
                    style: const TextStyle(fontWeight: FontWeight.normal))
              ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildNewPostMessage(noti, context);
  }
}

class FollowingNoti extends StatefulWidget {
  final Noti noti;
  final user_model.User user;
  const FollowingNoti({super.key, required this.noti, required this.user});

  @override
  State<FollowingNoti> createState() => _FollowingNotiState();
}

class _FollowingNotiState extends State<FollowingNoti> {
  late bool _isFollowing;
  bool isLoading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
    setState(() {});
  }

  init() async {
    _isFollowing = await ChatService().isFollowing(widget.noti.userId);
    setState(() {
      isLoading = false;
    });
  }

  Widget _buildFollowingMessage(Noti noti, user_model.User user) {
    return isLoading
        ? Container()
        : InkWell(
            // onLongPress: () {
            //   Navigator.of(context).push(MaterialPageRoute(
            //       builder: (_) => ProfileScreenNavigatorFromSearch(
            //           uid: widget.noti.userId)));
            // },
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(noti.photoUrl),
              ),
              title: RichText(
                text: TextSpan(
                    text: noti.sendGmail,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white),
                    children: [
                      TextSpan(
                          text: ' đã ${noti.text.toLowerCase()}',
                          style:
                              const TextStyle(fontWeight: FontWeight.normal)),
                      TextSpan(text: '  ${noti.userGmail}')
                    ]),
              ),
              subtitleTextStyle: const TextStyle(),
              subtitle: _isFollowing
                  ? FollowButton(
                      backGroundColor: Colors.white38,
                      broderColor: Colors.black54,
                      text: 'Đang theo dõi ${widget.noti.userGmail}',
                      textColor: Colors.black,
                      function: () async {
                        await FirestoreMethods().followUser(
                            FirebaseAuth.instance.currentUser!.uid,
                            noti.userId);
                        noti.isChecked[FirebaseAuth.instance.currentUser!.uid] =
                            !_isFollowing;
                        await FirestoreMethods().uItemMessCollection(
                            noti.sendId, noti.messId, noti.isChecked);
                        Provider.of<NotiProvider>(context, listen: false)
                            .fetchNotis();
                        _isFollowing = widget.noti.getCheckState();
                      },
                    )
                  : FollowButton(
                      backGroundColor: Colors.blue,
                      broderColor: Colors.white,
                      text: 'Theo dõi ${widget.noti.userGmail}',
                      textColor: Colors.white,
                      function: () async {
                        await FirestoreMethods().followUser(
                            FirebaseAuth.instance.currentUser!.uid,
                            noti.userId);
                        await FirestoreMethods().updateItemNotiCollection(
                          FirebaseAuth.instance.currentUser!.uid,
                          noti.userId,
                        );

                        await FirestoreMethods().cItemMessCollect(
                            FirebaseAuth.instance.currentUser!.uid,
                            user.email,
                            user.photoUrl,
                            'Theo Dõi',
                            null,
                            noti.userId,
                            noti.userGmail);

                        noti.isChecked[FirebaseAuth.instance.currentUser!.uid] =
                            !_isFollowing;
                        await FirestoreMethods().uItemMessCollection(
                            noti.sendId, noti.messId, noti.isChecked);
                        await Provider.of<NotiProvider>(context, listen: false)
                            .fetchNotis();
                        _isFollowing = widget.noti.getCheckState();
                      },
                    ),
            ),
          );
  }

  Widget _buildisFollowerMessage(Noti noti, user_model.User user) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) {
          return ProfileScreenNavigatorFromSearch(uid: noti.sendId);
        }));
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(noti.photoUrl),
        ),
        title: RichText(
          text: TextSpan(
              text: noti.sendGmail,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white),
              children: [
                TextSpan(
                    text: ' đã ${noti.text.toLowerCase()} bạn.',
                    style: const TextStyle(fontWeight: FontWeight.normal)),
              ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.noti.userId == FirebaseAuth.instance.currentUser!.uid
        ? _buildisFollowerMessage(widget.noti, widget.user)
        : _buildFollowingMessage(widget.noti, widget.user);
  }
}
