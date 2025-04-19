void viDuStreamDemSo(){
  print('==== Vi du 1: Stream Tro choi nam muoi ====');
  // Tao ra steam dem so (phat ra so 0, 5, 10,.... ,100), moi giay dem 1 so
  Stream<int> stream = Stream.periodic(Duration (seconds: 2), (x)=> x + 1).take(20);

  stream.listen(
    (x) => print('Nghe duoc so: ${x*5} - dang chay tron'),
    onDone: ()  => print('Nguoi bi : bat dau di tiem! '),
    onError: (loi) => print('Co van de, ngung cuoc choi ($loi)')
  );
}
void main(){
  viDuStreamDemSo();
}