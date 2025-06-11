// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:min_dia/listener_page.dart';
// import 'package:min_dia/widget/listen_widget.dart';
//
// import 'audio_player_screen.dart';
// import 'controller/continue_listening_controller.dart';
//
// class BookPage extends StatelessWidget {
//   const BookPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Book')),
//       body: Stack(
//         children: [
//           Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) =>  AudioPlayerScreen(),
//                       ),
//                     );
//                   },
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.audiotrack, size: 150, color: Colors.blue),
//                       const SizedBox(height: 20),
//                       const Text(
//                         'Listen to Book',
//                         style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Replace GestureDetector column with this:
//                 // Column(
//                 //   children: [
//                 //     ListTile(
//                 //       title: Text('Audio 1'),
//                 //       onTap: () {
//                 //         Get.find<ContinueListeningController>().play(
//                 //           'https://daq7nasbr6dck.cloudfront.net/atomic_habits/1.mp3',
//                 //         );
//                 //       },
//                 //     ),
//                 //     ListTile(
//                 //       title: Text('Audio 2'),
//                 //       onTap: () {
//                 //         Get.find<ContinueListeningController>().play(
//                 //           'https://daq7nasbr6dck.cloudfront.net/sapiens/1.mp3',
//                 //         );
//                 //       },
//                 //     ),
//                 //     const SizedBox(height: 20),
//                 //     ElevatedButton(
//                 //       onPressed: () => Navigator.pop(context),
//                 //       child: const Text('Go Back'),
//                 //     )
//                 //   ],
//                 // )
//
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   child: const Text('Go Back'),
//                 ),
//               ],
//             ),
//           ),
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: ContinueListeningWidget(),
//           )
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:min_dia/listener_page.dart';
import 'package:min_dia/widget/listen_widget.dart';

import 'audio_player_screen.dart';
import 'controller/continue_listening_controller.dart';

class BookPage extends StatelessWidget {
  const BookPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ContinueListeningController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Book')),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  child: ListTile(
                    title: const Text('Audio 1'),
                    onTap: () {
                      controller.currentUrlTitle.value = 'Audio 1';
                      controller.play('https://daq7nasbr6dck.cloudfront.net/atomic_habits/1.mp3');
                    },
                  ),
                ),
                Card(
                  child: ListTile(
                    title: const Text('Audio 2'),
                    onTap: () {
                      controller.currentUrlTitle.value = 'Audio 2';
                      controller.play('https://codeskulptor-demos.commondatastorage.googleapis.com/descent/background%20music.mp3');

                    },
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back'),
                )
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ContinueListeningWidget(), // <- Your audio mini player
          )
        ],
      ),
    );
  }
}
