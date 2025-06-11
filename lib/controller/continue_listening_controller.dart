// import 'package:flutter/widgets.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:just_audio/just_audio.dart';
//
// class ContinueListeningController extends GetxController with WidgetsBindingObserver {
//   final box = GetStorage();
//   final player = AudioPlayer();
//
//   var isPlaying = false.obs;
//   var isVisible = true.obs;
//
//   var lastPosition = Duration.zero.obs;
//   var totalDuration = const Duration(seconds: 1).obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     WidgetsBinding.instance.addObserver(this);
//     loadSavedPosition();
//     box.listen(() {
//       print("nowwwwwww");
//     },);
//   }
//
//   @override
//   void onClose() {
//     saveCurrentPosition();
//     player.dispose();
//     WidgetsBinding.instance.removeObserver(this);
//     super.onClose();
//   }
//
//   // @override
//   // void didChangeAppLifecycleState(AppLifecycleState state) {
//   //   if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
//   //     stopAndSavePosition();
//   //   }
//   // }
//
//   void loadSavedPosition() {
//     final seconds = box.read('last_position') ?? 0;
//     final totalSeconds = box.read('total_duration') ?? 1;
//     lastPosition.value = Duration(seconds: seconds);
//     totalDuration.value = Duration(seconds: totalSeconds);
//   }
//
//   Future<void> playFromLastPosition() async {
//     try {
//       loadSavedPosition();
//       isPlaying.value = false;
//       await player.setUrl('http://daq7nasbr6dck.cloudfront.net/7habits/1.mp3');
//
//       await player.durationStream.firstWhere((d) => d != null);
//       await player.seek(lastPosition.value);
//
//       isPlaying.value = true;
//       await player.play();
//     } catch (e) {
//       print("Play error: $e");
//     }
//   }
//
//   Future<void> pauseAndSavePosition() async {
//     await player.pause();
//     isPlaying.value = false;
//     saveCurrentPosition();
//   }
//
//   Future<void> stopAndSavePosition() async {
//     await player.stop();
//     isPlaying.value = false;
//     saveCurrentPosition();
//   }
//
//   Future<void> saveCurrentPosition() async {
//     final curr = player.position;
//     final dur = player.duration ?? const Duration(seconds: 1);
//     double percent = (curr.inSeconds / dur.inSeconds) * 100;
//     percent = percent.clamp(0.0, 100.0);
//     print('percentageListened: $percent');
//     print('currInSeconds: ${curr.inSeconds}');
//
//     if (percent > 94) {
//       box.write('last_position', 0); // reset
//     } else {
//       box.write('last_position', curr.inSeconds);
//     }
//
//     box.write('total_duration', dur.inSeconds);
//   }
//
//   Future<void> rewind30Seconds() async {
//     final newPosition = player.position - const Duration(seconds: 30);
//     await player.seek(newPosition >= Duration.zero ? newPosition : Duration.zero);
//   }
//
//   Future<void> forward30Seconds() async {
//     final newPosition = player.position + const Duration(seconds: 30);
//     final duration = player.duration ?? const Duration(seconds: 1);
//     if (newPosition < duration) {
//       await player.seek(newPosition);
//     } else {
//       await player.seek(duration);
//     }
//   }
// }
// Updated ContinueListeningController with support for multiple audios
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio/just_audio.dart';

class ContinueListeningController extends GetxController with WidgetsBindingObserver {
  final box = GetStorage();
  final player = AudioPlayer();

  var isPlaying = false.obs;
  var isVisible = false.obs;

  var lastPosition = Duration.zero.obs;
  var totalDuration = const Duration(seconds: 1).obs;
  var currentUrl = ''.obs;
  var currentUrlTitle = ''.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadState();

    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        isPlaying.value = false;
        update();
        isPlaying.refresh();
        print("isPlaying.value----END--->${isPlaying.value}");
      }
    });
  }

  @override
  void onClose() {
    saveCurrentPosition();
    player.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  void _loadState() {
    final seconds = box.read('last_position') ?? 0;
    final totalSeconds = box.read('total_duration') ?? 1;
    final url = box.read('audio_url') ?? '';
    final title = box.read('currentUrlTitle') ?? '';

    lastPosition.value = Duration(seconds: seconds);
    totalDuration.value = Duration(seconds: totalSeconds);
    currentUrl.value = url;
    currentUrlTitle.value = title;
    print("currentUrlTitle.value0--->${currentUrlTitle.value}");
    isVisible.value = url.isNotEmpty;
  }

  Future<void> play(String url) async {
    try {
      // isPlaying.value = false;
      if (url != currentUrl.value) {
        // New audio, reset position
        await player.setUrl(url);
        isPlaying.value = true;
        isVisible.value = true;
        await player.play();
        currentUrl.value = url;
        lastPosition.value = Duration.zero;
      } else {
        // Resume existing
        await player.setUrl(url);
        await player.seek(lastPosition.value);
        isPlaying.value = true;
        isVisible.value = true;
        await player.play();
      }
      isPlaying.value = true;
      isVisible.value = true;
      box.write('audio_url', url);
      box.write('currentUrlTitle', currentUrlTitle.value);
      final title = box.read('currentUrlTitle') ?? '';
      print("currentUrlTitle.value---->${currentUrlTitle.value} == [$title]");
    } catch (e) {
      print('Error while playing audio: $e');
    }
  }

  Future<void> playFromLastPosition() async {
    if (currentUrl.value.isNotEmpty) {
      await play(currentUrl.value);
    }
  }

  Future<void> pauseAndSavePosition() async {
    await player.pause();
    isPlaying.value = false;
    saveCurrentPosition();
  }

  Future<void> stopAndSavePosition() async {
    await player.stop();
    isPlaying.value = false;
    saveCurrentPosition();
  }

  void saveCurrentPosition() {
    final curr = player.position;
    final dur = player.duration ?? const Duration(seconds: 1);
    final percent = (curr.inSeconds / dur.inSeconds * 100).clamp(0.0, 100.0);

    print("percent---< $percent");

    if (percent > 94) {
      lastPosition.value = Duration(seconds: 0);
      box.write('last_position', 0);
    } else {
      lastPosition.value = Duration(seconds: curr.inSeconds);
      box.write('last_position', curr.inSeconds);
    }

    box.write('total_duration', dur.inSeconds);
    box.write('audio_url', currentUrl.value);
    box.write('currentUrlTitle', currentUrlTitle.value);
  }

  Future<void> rewind30Seconds() async {
    final newPosition = player.position - const Duration(seconds: 30);
    await player.seek(newPosition >= Duration.zero ? newPosition : Duration.zero);
  }

  Future<void> forward30Seconds() async {
    final newPosition = player.position + const Duration(seconds: 30);
    final duration = player.duration ?? const Duration(seconds: 1);
    await player.seek(newPosition < duration ? newPosition : duration);
  }
}
