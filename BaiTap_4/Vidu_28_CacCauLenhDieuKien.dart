import 'dart:convert';

void main(){
 int x = 100;
 if (x is! int){
  print('day ko phai la so');
 }else if (x%2==0){
  print('day la so chan');
 }else {
  print('x la so le');
 }
  int thang = 5;
  switch (thang) {
    case 2:
      print('thanh $thang co 28 ngay');
      break;
    case 1:
    case 3:
    case 5:
    case 7:
    case 8:
    case 10:
    case 12:
      print('thanh $thang co 31 ngay');
      break;

    case 4:
    case 6:
    case 9:
    case 11:
      print('thanh $thang co 30 ngay');
      break;
    default:
      print('thang $thang ko xac dinh');
  }
}