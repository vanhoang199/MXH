import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  final Function()? function;
  final Color backGroundColor;
  final Color broderColor;
  final String text;
  final Color textColor;
  double? fontsize;

  FollowButton(
      {super.key,
      this.function,
      required this.backGroundColor,
      required this.broderColor,
      required this.text,
      required this.textColor,
      this.fontsize});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 5),
      child: TextButton(
        onPressed: function,
        child: Container(
          decoration: BoxDecoration(
            color: backGroundColor,
            border: Border.all(color: broderColor),
            borderRadius: BorderRadius.circular(5),
          ),
          alignment: Alignment.center,
          width: 200,
          height: 27,
          child: Text(
            text,
            style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: fontsize),
          ),
        ),
      ),
    );
  }
}
