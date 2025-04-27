import 'package:flutter/material.dart';

class Screen2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Screen 2')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Quay về màn hình trước
            Navigator.pop(context);
          },
          child: Text('Back to Screen 1'),
        ),
      ),
    );
  }
}
