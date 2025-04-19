import "dart:async";

Future<String> layTen() async {
  return'Nguyen Van A';
}

Future<String> taiDuLieu() {
  return Future.delayed(
    Duration(seconds: 2 ),() => 'Du lieu da tai xong'
  );
}
void hamChinh1() {
  print('Bat dau tai');
  Future<String> f = taiDuLieu();
  f.then((ketQua){
    print('Ket Qua: $ketQua');
  });
  print('Tiep tuc cong viec khac');
}
void hamChinh2() async {
  print('Bat dau tai');
  String ketQua = await taiDuLieu();
  print('Ket Qua: $ketQua');
  print('Tiep tuc cong viec khac');
}
void main(){
  hamChinh2();
}