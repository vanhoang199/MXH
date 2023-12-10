import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;

Widget errorScreen(dynamic detailsException) {
  return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child:
            //Check is it release mode
            foundation.kReleaseMode
                //Widget for release mode
                ? const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        Text(
                          'Đang tải vui lòng chờ chút',
                          style: TextStyle(fontSize: 24.0),
                        ),
                      ],
                    ),
                  )
                //Widget for debug mode
                : SingleChildScrollView(
                    child: Text('Exeption Details:\n\n$detailsException')),
      ));
}
