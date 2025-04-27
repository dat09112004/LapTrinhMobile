import 'package:flutter/material.dart';

class BackgroundContainer extends StatelessWidget {
  final Widget child;

  const BackgroundContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand( // đảm bảo container fill toàn màn hình
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/VietNam.jpg'),
            fit: BoxFit.cover, // fill toàn bộ theo tỉ lệ
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3), // lớp phủ tối nhẹ
          ),
          child: child,
        ),
      ),
    );
  }
}
