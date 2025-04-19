void main(){
  /*
Records là một kiểu dữ liệu tổng hợp (composite type) được giới thiệu trong Dart 3.0
cho phép nhóm nhiều giá trị có kiểu khác nhau thành một đơn vị duy nhất.
Records là immutable - nghĩa là không thể thay đổi sau khi được tạo.
*/
  var r = ('firts', x:2, 5, 10.5); // record
  //dinh nghia record co 2 gia tri
  var point =( 123, 456);
  //dinh nghia person
  var person = (name:'Alice', age:25, 5);

  //Cach truy cap gia tri trong record
  //Dung chi so
  print(point.$1);
  print(point.$2);
  print(person.$1);

  //dung ten 
  print(person.name);
  print(person.age);

}