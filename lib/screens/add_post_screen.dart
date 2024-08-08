import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone_1/models/user.dart' as model_user;
import 'package:instagram_clone_1/providers/user_provider.dart';
import 'package:instagram_clone_1/resources/firestore_methods.dart';
import 'package:instagram_clone_1/utlis/colors.dart';
import 'package:instagram_clone_1/utlis/utlis.dart';
import 'package:provider/provider.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  List<Uint8List> _listImageFile = [];
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  Future<String> postImage(
    String uid,
    String username,
    String profImage,
  ) async {
    String res = '';
    try {
      setState(() {
        _isLoading = true;
      });
      res = await FirestoreMethods().uploadPost(
        _descriptionController.text,
        _file!,
        uid,
        username,
        profImage,
        _listImageFile,
        null,
      );

      if (res != 'Lỗi') {
        setState(() {
          _isLoading = false;
          _file = null;
          _listImageFile = [];
        });
        showSnackBar('Đăng bài viết thành công', context);
      } else {
        showSnackBar(res, context);
      }
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
    return res;
  }

  _selectImage(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Tạo bài viết'),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Chụp ảnh bằng camera'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  late Uint8List file;
                  Uint8List? fileFromCamera =
                      await pickImage(ImageSource.camera);
                  if (fileFromCamera != null) {
                    file = fileFromCamera;
                    setState(() {
                      _file = file;
                      _listImageFile.add(file);
                    });
                  }
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Chọn ảnh từ thư viện'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  //Khi người dùng không chọn
                  late Uint8List file;
                  Uint8List? fileFromGalley =
                      await pickImage(ImageSource.gallery);
                  if (fileFromGalley != null) {
                    file = fileFromGalley;
                    setState(() {
                      _file = file;
                      _listImageFile.add(file);
                    });
                  }
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Hủy'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model_user.User user = Provider.of<UserProvider>(context).getUser;
    return _file == null
        ? Center(
            child: IconButton(
              onPressed: () {
                _selectImage(context);
              },
              icon: const Icon(
                Icons.upload,
                size: 50,
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              leading: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.arrow_back),
              ),
              title: const Text('Tạo bài viết của bạn'),
              centerTitle: false,
              actions: [
                TextButton(
                    onPressed: () async {
                      String postId = await postImage(
                          user.uid, user.username, user.photoUrl);
                      //add 1 item trong collection mess của docs(user.uid) collection noti
                      // text = 'Đăng bài'
                      // postId = post Id

                      if (postId != 'Lỗi') {
                        FirestoreMethods().cItemMessCollect(
                            FirebaseAuth.instance.currentUser!.uid,
                            user.email,
                            user.photoUrl,
                            'Đăng bài',
                            postId,
                            null,
                            null);
                      }
                      Future.delayed(const Duration(seconds: 3));

                      // _backToFeed();
                    },
                    child: const Text(
                      'Đăng bài',
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ))
              ],
            ),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(user.photoUrl),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: TextField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              hintText: 'Viết tiêu đề',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 8,
                          ),
                        ),
                        const SizedBox(
                          height: 6,
                          width: double.infinity,
                        ),
                        _listImageFile.length < 2
                            ? SizedBox(
                                height: 45,
                                width: 45,
                                child: AspectRatio(
                                  aspectRatio: 487 / 451,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: MemoryImage(_file!),
                                          fit: BoxFit.fill,
                                          alignment:
                                              FractionalOffset.topCenter),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(
                                height: 48,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _listImageFile.length,
                                    itemBuilder: (_, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: SizedBox(
                                          height: 45,
                                          width: 45,
                                          child: AspectRatio(
                                            aspectRatio: 487 / 451,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: MemoryImage(
                                                        _listImageFile[index]),
                                                    fit: BoxFit.fill,
                                                    alignment: FractionalOffset
                                                        .topCenter),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                        IconButton(
                          onPressed: () {
                            _selectImage(context);
                          },
                          icon: const Icon(
                            Icons.add_a_photo,
                          ),
                        ),
                      ],
                    ),
                  ),
          );
  }
}
