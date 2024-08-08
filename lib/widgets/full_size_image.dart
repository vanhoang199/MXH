import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FullSizeImage extends StatefulWidget {
  final String photoUrl;
  const FullSizeImage({super.key, required this.photoUrl});

  @override
  State<FullSizeImage> createState() => _FullSizeImageState();
}

class _FullSizeImageState extends State<FullSizeImage> {
  bool _rotate180degree = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  _rotate180degree = !_rotate180degree;
                });
              },
              icon: const Icon(Icons.rotate_90_degrees_cw))
        ],
      ),
      body: _rotate180degree
          ? RotatedBox(
              quarterTurns: 1,
              child: Container(
                width: double.maxFinite,
                height: double.maxFinite,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(widget.photoUrl),
                        fit: BoxFit.contain)),
              ),
            )
          : Container(
              width: double.maxFinite,
              height: double.maxFinite,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(widget.photoUrl),
                      fit: BoxFit.contain)),
            ),
    );
  }
}
