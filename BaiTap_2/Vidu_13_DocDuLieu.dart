import 'dart:io';

void main (){
  // nhập tên người dùng
  stdout.write('Enter your name: ');
  String name = stdin.readLineSync()!;

  // nhập tuổi người dùng
  stdout.write('Enter your age: ');
  int age = int.parse(stdin.readLineSync()!);

  print("Xin Chao: $name, Tuổi của bạn là: $age");
  
}