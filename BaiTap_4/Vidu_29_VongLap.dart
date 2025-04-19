void main(){
  for (var i = 1; i<= 5; i++){
    print(i);
  }
  var names =['luong','duong thanh','dat'];
  for (var name in names){
    print(name);
  }
  //vong lap while
  var i = 1;
  while (i<=5){
    print(i);
    i++;
  }
  // Vong lap do while
  var x =1;
  do{
    print(x);
    x++;
    if (x ==3) break;
  }while (x <= 5) ;

  //break / continue
  var y =1;
  do{
    y++;
    if (y ==3) continue;
    print(y);
    
    
  }while (y <= 5) ;
}