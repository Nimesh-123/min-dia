import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:min_dia/home.dart';

import 'controller/continue_listening_controller.dart';

void main() async {
  await GetStorage.init();
  Get.put(ContinueListeningController(), permanent: true);

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage(),debugShowCheckedModeBanner: false,);
  }
}
