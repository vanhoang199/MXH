import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone_1/resources/auth_methods.dart';
import 'package:instagram_clone_1/resources/firestore_methods.dart';
import 'package:instagram_clone_1/screens/login_screen.dart';
import 'package:instagram_clone_1/utlis/colors.dart';
import 'package:instagram_clone_1/utlis/logincode.dart';
import 'package:instagram_clone_1/utlis/text_field_input.dart';
import 'package:instagram_clone_1/utlis/utlis.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  Uint8List? _img;
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _userNameController.dispose();
    _bioController.dispose();
  }

  void selectImage() async {
    //TODO: Fix null full disk, ram  by image_picker readme

    Uint8List? im;
    if (kIsWeb) {
      im = await pickImage(ImageSource.camera);
    } else {
      im = await pickImage(ImageSource.gallery);
    }

    if (im == null) {
      print('Bộ nhớ đầy! Giải phóng các ứng dụng khác');
      return;
    }

    setState(() {
      _img = im;
    });
  }

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });
    //TODO: Setting img = default profile
    if (_img == null) {
      final ByteData bytes =
          await rootBundle.load('assets/default_profile.png');
      final Uint8List list = bytes.buffer.asUint8List();
      _img = list;
    }

    String res = await AuthMethods().signUpUser(
        username: _userNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        bio: _bioController.text,
        file: _img!);
    //TODO: res -> const in folder
    if (res != Code().signUpSuccess) {
      showSnackBar(res, context);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    }

    await FirestoreMethods()
        .createItemNotiCollection(FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      _isLoading = false;
    });
  }

  void loginUser() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 1,
                child: Container(),
              ),
              SvgPicture.asset(
                'assets/ic_instagram.svg',
                // color: primaryColor,
                height: 64,
              ),
              const SizedBox(
                height: 64,
              ),
              Stack(
                children: [
                  _img != null
                      ? CircleAvatar(
                          radius: 64,
                          backgroundImage: MemoryImage(_img!),
                        )
                      //ToDo: change to assests image
                      : const CircleAvatar(
                          radius: 64,
                          backgroundImage:
                              AssetImage('assets/default_profile.png'),
                        ),
                  Positioned(
                    bottom: -10,
                    left: 85,
                    child: IconButton(
                        onPressed: selectImage,
                        icon: const Icon(Icons.add_a_photo)),
                  )
                ],
              ),
              const SizedBox(
                height: 32,
              ),
              TextFieldInput(
                textEditingController: _userNameController,
                hintText: 'Nhập Tên',
                textInputType: TextInputType.text,
                isPass: false,
              ),
              const SizedBox(
                height: 12,
              ),
              TextFieldInput(
                textEditingController: _emailController,
                hintText: 'Nhập email ',
                textInputType: TextInputType.emailAddress,
              ),
              const SizedBox(
                height: 12,
              ),
              TextFieldInput(
                textEditingController: _passwordController,
                hintText: 'Nhập mật khẩu',
                textInputType: TextInputType.text,
                isPass: true,
              ),
              const SizedBox(
                height: 12,
              ),
              TextFieldInput(
                textEditingController: _bioController,
                hintText: 'Nhập Bio',
                textInputType: TextInputType.text,
                isPass: false,
              ),
              const SizedBox(
                height: 12,
              ),
              InkWell(
                onTap: signUpUser,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: primaryColor,
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: const ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                            color: blueColor),
                        child: const Text(
                          'Đăng kí',
                        ),
                      ),
              ),
              const SizedBox(
                height: 12,
              ),
              Flexible(
                flex: 1,
                child: Container(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Text('Bạn đã có tài khoản? '),
                  ),
                  GestureDetector(
                    onTap: loginUser,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text(
                        'Đăng nhập ngay',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Flexible(
                flex: 1,
                child: Container(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
