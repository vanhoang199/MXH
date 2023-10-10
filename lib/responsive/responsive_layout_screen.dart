import 'package:flutter/material.dart';
import 'package:instagram_clone_1/providers/user_provider.dart';
import 'package:instagram_clone_1/utlis/gobal_varible.dart';
import 'package:provider/provider.dart';

class ResponsiveLayoutScreen extends StatefulWidget {
  final Widget webScreenLayout;
  final Widget mobileScreenLayout;

  const ResponsiveLayoutScreen({
    super.key,
    required this.webScreenLayout,
    required this.mobileScreenLayout,
  });

  @override
  State<ResponsiveLayoutScreen> createState() => _ResponsiveLayoutScreenState();
}

class _ResponsiveLayoutScreenState extends State<ResponsiveLayoutScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    addData();
  }

  void addData() async {
    UserProvider userProvider = Provider.of(context, listen: false);
    await userProvider.refreshUser();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      if (constrains.maxWidth > webScreenSize) {
        return widget.webScreenLayout;
      }
      return widget.mobileScreenLayout;
    });
  }
}
