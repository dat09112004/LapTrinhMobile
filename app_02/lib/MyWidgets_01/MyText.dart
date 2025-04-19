import 'package:flutter/material.dart';

class Mytext extends StatelessWidget {
  const Mytext({super.key});

  @override
  Widget build(BuildContext context) {
    // Tra ve Scaffold - widget cung cap bo cuc material design co ban
    // man hinh
    return Scaffold(
      // tieu de
      appBar: AppBar(
        title: Text("App 02"),
        // mau nen
        backgroundColor: Colors.yellow,
        // do nang/ do bong cua AppBar
        elevation: 4,
        actions: [
          IconButton(
            onPressed: () {
              print("B1");
            },
            icon: Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              print("B2");
            },
            icon: Icon(Icons.abc),
          ),
          IconButton(
            onPressed: () {
              print("B3");
            },
            icon: Icon(Icons.more_vert),
          ),
        ],

      ),

      // hinh nen
      //backgroundColor: Colors.cyanAccent,
      body: Center(child: Column(
          children: [
            // tao khoang cach
            const SizedBox(height: 50,),
            // text co ban
            const Text("Anh Huy"),
            const SizedBox(height: 20,),

            const Text(
              "Xin Chao Cac Ban Dang Hoc Lap Trinh!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                letterSpacing: 1.5,

              ),
            ),
            const SizedBox( height: 20,),
            const Text(
              "Flutter là một SDK phát triển ứng dụng di động nguồn mở được tạo ra bởi Google. Nó được sử dụng để phát triển ứng ứng dụng cho Android và iOS, cũng là phương thức chính để tạo ứng dụng cho Google Fuchsia.",
              textAlign: TextAlign.center,
              // Quy dinh so luong dong
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                //color: Colors.blue,
                letterSpacing: 1.5,

              ),
            ),
          ]

      )),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("pressed");
        },
        child: const Icon(Icons.add_ic_call),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang Chu"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Tim Kiem"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Ca Nhan"),
        ],
      ),
    );
  }
}
