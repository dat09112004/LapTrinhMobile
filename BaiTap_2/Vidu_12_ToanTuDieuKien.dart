/* 
 ex1 ? ex2 : ex3
 nếu ex1 đúng, trả về ex2; ngược lại trả về ex3
 ex1 ?? ex2
 nếu ex1 ko null, trả về giá trị của nó;
 ngược lại trả về giá trị ex2

*/
void main(){
  var kiemTra = (100%2==0) ? "100 là số chẵn" : "100 là số lẻ";
  print(kiemTra);

  var x = 100;
  var y = x ?? 50;
  print(y);

  int? z;
  y = z ?? 30;
  print(y);

}