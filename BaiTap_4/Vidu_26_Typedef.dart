typedef IntList = List <int>;
typedef ListMapper<x> = Map<x, List<x>>;
typedef IntSet = Set<int>;
void main(){
  /*

  */
  IntList l1 = [1,2,3,4,5];
  print(l1);
  IntList l2 = [1,2,3,4,5,6,7];

  Map<String, List<String>> m1 ={};
  ListMapper <String> m2 = {};

  IntSet Set1 = {1,2,3,4,5,6,7,8,9,10};
  print(Set1);

}