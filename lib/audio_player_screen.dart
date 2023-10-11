import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_sound/flutter_sound.dart';

class AudioPlayerScreen extends StatefulWidget {
  final File audioFile;
  const AudioPlayerScreen({super.key, required this.audioFile});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {

  final audioPlayer = AudioPlayer();
  

  bool isPlaying = false;
  double progress = 0.0;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;


//   @override
//   void dispose() {
//     audioPlayer.dispose();
//     isPlaying = false;
  
// progress = 0.0;
// duration = Duration.zero;
// position = Duration.zero;
//     super.dispose();
//   }

  @override
  void initState() {
    super.initState();
  // to listen play , paused stopped
  audioPlayer.onPlayerStateChanged.listen((state) {

    log(state.toString());
    setState(() {
      isPlaying = state == PlayerState.playing;
    });
   });
   // to listen duration 
  audioPlayer.onDurationChanged.listen((newDuration) {
    log(newDuration.toString());
    setState(() {
      duration = newDuration;
    });
   });
   // to listen audio position 
  audioPlayer.onPositionChanged.listen((newPosition) {
        log(newPosition.toString());

    setState(() {
      position = newPosition;
    });
   });
  }

  Future<void> setAudio ()async{

    audioPlayer.setReleaseMode(ReleaseMode.loop);
    // audioPlayer.setSourceDeviceFile(widget.audioFile.path);
    audioPlayer.setSourceUrl(widget.audioFile.path);
    audioPlayer.setVolume(10);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Play your audio"),
      ),
      body: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        child: Column(
          children: [
            Container(
              width: 300,
              height: 450,
              color: Colors.amber,
              child: Image.network(
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQKeiHH22NCJSy5NpZNfd1Xs7cXYBz5ALHaVhp1SMLZsgUChZbhOxe4bOJBfNiaXuOJ5HM&usqp=CAU",
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Slider(
              min: 0,
              max: duration.inSeconds.toDouble(),
                value: position.inSeconds.toDouble(),
                onChanged: (v) async {
                  final position = Duration( seconds:  v.toInt());
                await audioPlayer.seek(position);
                await audioPlayer.resume();
                setState(() {
                });
                  // setState(() {
                  //   progress = v;
                  // });
                }),
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatTime(position)),
                  Text(formatTime (duration - position)),
                ],
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    style: const ButtonStyle(
                        padding: MaterialStatePropertyAll(EdgeInsets.all(10))),
                    onPressed: () {},
                    child: const Icon(
                      Icons.skip_previous,
                      color: Colors.black,
                      size: 40,
                    )),
                ElevatedButton(
                    style: const ButtonStyle(
                        padding: MaterialStatePropertyAll(EdgeInsets.all(10))),
                    onPressed: ()async {
                      if (isPlaying) {
                        await audioPlayer.pause();
                      } else {
                        
                        await audioPlayer.play(UrlSource(widget.audioFile.path));
                      }
                    },
                    child: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.black,
                      size: 40,
                    )),
                ElevatedButton(
                    style: const ButtonStyle(
                        padding: MaterialStatePropertyAll(EdgeInsets.all(10))),
                    onPressed: () {},
                    child: const Icon(
                      Icons.skip_next,
                      color: Colors.black,
                      size: 40,
                    )),
              ],
            ),
            const SizedBox(
              height: 30,
            )
          ],
        ),
      ),
    );
  }

 String formatTime (Duration duration){
  String twoDigits (int n)=> n.toString().padLeft(2,"0");
  final hours = twoDigits(duration.inHours);
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));

  return [
    if(duration.inHours > 0 )hours,minutes,seconds

  ].join(":");

 }

}
