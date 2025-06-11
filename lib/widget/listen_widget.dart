import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/continue_listening_controller.dart';

class ContinueListeningWidget extends StatelessWidget {
  ContinueListeningWidget({super.key});
  ContinueListeningController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isVisible.value) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.greenAccent.shade100,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
        ),
        child: Row(
          children: [
            Image.network(
              'http://daq7nasbr6dck.cloudfront.net/7habits/cover.jpg',
              height: 50,
              width: 50,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() => Text(
                controller.currentUrlTitle.value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),)
            ),
            Obx(() => IconButton(
              icon: Icon(controller.isPlaying.value ? Icons.pause : Icons.play_arrow),
              onPressed: () async {
                if (controller.isPlaying.value) {
                  await controller.pauseAndSavePosition(); // Save on pause
                } else {
                  await controller.playFromLastPosition(); // Resume from saved
                }
              },
            )),
          ],
        ),
      );
    });
  }
}
