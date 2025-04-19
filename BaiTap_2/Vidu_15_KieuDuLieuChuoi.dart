/* 
  Chuỗi là tập hợp ký tự UTF-16
*/

import 'dart:collection';

void main(){
  var s1 = ' Thanh Dat ';
  var s2 = " Thanh ";

  // Chèn giá trị của một biểu thức, biến vào trong chuỗi: ${.......}
  double diemToan = 9.5;
  double diemVan = 7.5;
  var s3 = ' Xin Chao $s1 , bạn đã đạt tổng điểm là: ${diemVan+diemToan}';
  print(s3);

  //tạo ra chuỗi nằm ở nhiều dòng
  var s4 = '''
      Dong 1
      Dong 2
      Dong 3
      ''';
  print(s4);

    var s5 = """
      Dong 1
      Dong 2
      Dong 3
      """;
  print(s5);

  var s6 = ' Đây là một đoạn \n văn bản';
  print(s6);

  var s7 = r' Đây là một đoạn \n văn bản'; // r là raw: dữ liệu thô
  print(s7);

  var s8 = 'chuỗi 1' + 'Chuỗi 2';
  print(s8);

   var s9 = 'chuỗi ' 
            'nay ' 
            'la ' 
            'một chuỗi';
  print(s9);
}