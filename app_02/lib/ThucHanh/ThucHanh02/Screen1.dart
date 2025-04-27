import 'package:flutter/material.dart';
import 'Screen2.dart';

class Screen1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Screen 1')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Chuyển tới Screen2
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Screen2()),
            );
          },
          child: Text('Go to Screen 2'),
        ),
      ),
    );
  }
}
