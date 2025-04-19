import 'package:flutter/material.dart';

class MyScaffold extends StatelessWidget{
  const MyScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    // Tra ve Scaffold - widget cung cap bo cuc material design co ban
    // man hinh
    return Scaffold(
      // tieu de
      appBar: AppBar(
        title: Text("App 02"),
      ),
      // hinh nen
      backgroundColor: Colors.cyanAccent,

      body: Center(child: Text("Noi dung chinh"),),

      floatingActionButton: FloatingActionButton(
        onPressed: (){print("pressed");},
        child: const Icon(Icons.add_ic_call),
      ),

      bottomNavigationBar: BottomNavigationBar(items: [
        BottomNavigationBarItem(icon:  Icon(Icons.home), label: "Trang Chu"),
        BottomNavigationBarItem(icon:  Icon(Icons.search), label: "Tim Kiem"),
        BottomNavigationBarItem(icon:  Icon(Icons.person), label: "Ca Nhan"),
      ]),
    );
  }
}