import 'package:flutter/material.dart';
import 'package:min_dia/widget/listen_widget.dart';
import 'book.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Podcast Reader')),
      body: Stack(
        children: [
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BookPage()),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book, size: 150, color: Colors.blue),
                  const SizedBox(height: 20),
                  const Text('Open Book',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
           Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ContinueListeningWidget(),
          )
        ],
      ),
    );
  }
}
