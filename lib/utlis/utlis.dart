import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

pickImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();

  XFile? file = await imagePicker.pickImage(source: source, imageQuality: 50);

  if (file != null) {
    return await file.readAsBytes();
  }
  print('No image select ');
  //TODO: file = assets/default_profile
}

showSnackBar(String res, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(res)),
  );
}
