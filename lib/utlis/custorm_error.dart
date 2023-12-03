import 'package:flutter/material.dart';

void setErrorBuilder() {
  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return const Scaffold(
      body:
          // Center(child: Text("Unexpected error. See console for details.")));
          Center(
        child: CircularProgressIndicator(),
      ),
    );
  };
}
