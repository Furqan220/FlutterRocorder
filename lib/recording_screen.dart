import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:recorder/audio_player_screen.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  final recorder = FlutterSoundRecorder();
  bool isRecording = false;
  bool isRecorderReady = false;
  File? audioPath;

  @override
  void initState() {
    initRecorder();
    super.initState();
  }

  @override
  void dispose() {

isRecording = false;
isRecorderReady = false;
 audioPath = null; 
    super.dispose();
  }

  void initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw "Microphone permission not granted";
    }
    isRecorderReady = true;
    await recorder.openRecorder();
    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  void startRecording() async {
    if (!isRecorderReady) {
      return;
    }
    await recorder.startRecorder(toFile: "audio");
    setState(() {
      isRecording = true;
    });
  }

  void stopRecording() async {
    if (!isRecorderReady) {
      return;
    }
    isRecording = false;

    final path = await recorder.stopRecorder();
    if (path != null) {
      audioPath = File(path);
      setState(() {});
    }
    log("Recorded Audio : $audioPath");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Recorder"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                style: const ButtonStyle(
                    padding: MaterialStatePropertyAll(EdgeInsets.all(30))),
                onPressed: () {
                  if (isRecording) {
                    stopRecording();
                    setState(() {
                      isRecording = false;
                    });
                  } else {
                    startRecording();
                    setState(() {
                      isRecording = true;
                    });
                  }
                },
                child: Icon(
                  isRecording ? Icons.stop : Icons.mic_rounded,
                  color: Colors.black,
                  size: 60,
                )),
            const SizedBox(
              height: 50,
            ),
            StreamBuilder<RecordingDisposition>(
                stream: recorder.onProgress,
                builder: (context, snapshot) {
                  final duration = snapshot.hasData
                      ? snapshot.data!.duration
                      : Duration.zero;
                  String twoDigits(int n) => n.toString().padLeft(2,"0");
                  final minutes = twoDigits(duration.inMinutes.remainder(60));
                  final seconds = twoDigits(duration.inSeconds.remainder(60));
                  return Text(
                    "$minutes:$seconds",
                    style: const TextStyle(fontSize: 50),
                  );
                }),
            const SizedBox(
              height: 50,
            ),
            Visibility(
              visible: audioPath != null,
              child: ElevatedButton(
                  style: const ButtonStyle(
                      padding: MaterialStatePropertyAll(EdgeInsets.all(20))),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AudioPlayerScreen(audioFile: audioPath!),
                        ));
                  },
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.black,
                    size: 50,
                  )),
            ),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}
