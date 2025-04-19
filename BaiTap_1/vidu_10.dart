void main (){
  var a = 2;
  print(a);

  // ??= : gan gia tri neu bien dag null

  int? b;
  b ??= 5;
  print('b = $b');

  b ??= 10; 
  print('b = $b');
}