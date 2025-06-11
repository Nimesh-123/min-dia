import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller/continue_listening_controller.dart';

class AudioPlayerScreen extends StatelessWidget {
  const AudioPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ContinueListeningController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [

            Expanded(
              child: Center(
                child: Text(
                  'Empty Area',
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_30, size: 36),
                    onPressed: controller.rewind30Seconds,
                  ),

                  Obx(() => IconButton(
                    icon: Icon(
                      controller.isPlaying.value ? Icons.pause_circle : Icons.play_circle,
                      size: 48,
                      color: Colors.green,
                    ),
                    onPressed: () {
                      controller.isPlaying.value
                          ? controller.pauseAndSavePosition()
                          : controller.playFromLastPosition();
                    },
                  )),

                  IconButton(
                    icon: const Icon(Icons.forward_30, size: 36),
                    onPressed: controller.forward30Seconds,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
