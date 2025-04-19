
double tinhtong (var a, double b, double c){
  return a + b + c;

}
// su dung cu phap rut gon " =>"
double tinhtong1 (var a, double b, double c) => a + b + c;
//Ham voi ten cua tham so
String createFullName ({String ho="", String chuLot="", String ten=""}){
  return ho + " " + chuLot + " " + ten;
}

double sum (double a, [double? b, double? c,double? d]){
  var result = a;
  result += (b!= null)?b : 0;
  result += (c!= null)?c : 0;
  result += (d!= null)?d : 0;
  return result;
}
// ham an danh

// Ham main 
void main(){
  print('Hello World!');
  var x = tinhtong(1, 10, 100);
  print(x);

  var y = tinhtong(1, 10, 100);
  print(y);
  var fn = createFullName(ho: 'Luong', chuLot: 'Duong', ten: 'Dat');
  print(fn);

  print(sum(10));
  print(sum(10,4,5));
}
