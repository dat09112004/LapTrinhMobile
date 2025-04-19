void main(){
  Object obj = 'hello';

  //kiem tra obj co phai string
  if (obj is String){
    print('obj la mot string');
  }
  //kiem tra obj co phai int
   if (obj is! int){
    print('obj la khong phai la so nguyen int');
  }
  // ep kiu
  String str = obj as String;
  print(str.toUpperCase());
}