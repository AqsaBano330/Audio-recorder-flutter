import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;

  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    initRecorder();

  //   audioPlayer.onPlayerStateChanged.listen((state) { 
  //     setState(() {
  //       isPlaying = state == PlayerState.PLAYING;
  //     });
  //   });

  //   audioPlayer.onDurationChanged.listen((newDuration) { 
  //     setState(() {
  //       position = newPosition;
  //     });
  //   });
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    super.dispose();
  }

  

  Future<void> initRecorder() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw "Microphone Permission not granted";
    }
    await recorder.openRecorder();
    isRecorderReady = true;
    recorder.setSubscriptionDuration(Duration(microseconds: 500));
  }

  Future<void> record() async {
    if (!isRecorderReady) return;
    await recorder.startRecorder(toFile: "audio");
  }

  Future<void> stop() async {
    if (!isRecorderReady) return;

    final path = await recorder.stopRecorder();
    final audioFile = File(path!);

    print("Recorder audio: $audioFile");
  }

  Future setAudio() async {

    audioPlayer.setReleaseMode(ReleaseMode.loop);

    //final file = File();
    //audioPlayer.setSourceAsset(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AudioRecorder"),
      ),
      body: Center(
        child: Column(
          children: [
            StreamBuilder<RecordingDisposition>(
              stream: recorder.onProgress,
              builder: (context, snapshot) {
                final duration = snapshot.hasData
                    ? snapshot.data!.duration
                    : Duration.zero;

                String twoDigits(int n) =>
                    n.toString().padLeft(40);
                final twoDigitMinutes =
                    twoDigits(duration.inMinutes.remainder(60));
                final twoDigitSeconds =
                    twoDigits(duration.inSeconds.remainder(60));
                return Text(
                  "${twoDigitMinutes}: ${twoDigitSeconds} s",
                  style: TextStyle(fontSize: 80),
                );
              },
            ),

            SizedBox(height: 32),

            ElevatedButton(
              onPressed: () async {
                if (recorder.isRecording) {
                  await stop();
                } else {
                  await record();
                }
              },
              child: Text("Record"),
            ),

            Text("The Flutter Song"),
            Slider(
              min: 0,
              max: duration.inSeconds.toDouble(),
              value: position.inSeconds.toDouble(),
              onChanged: (value) async {
                // Seek to the specified position in the audio
                await audioPlayer.seek(Duration(seconds: value.toInt()));
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(position.toString()),
                Text(duration.toString()),
              ],
            ),

            CircleAvatar(
              radius: 35,
              child: IconButton(
                iconSize: 50,
                onPressed: () async {
                  if (isPlaying) {
                    await audioPlayer.pause();
                    isPlaying = false;
                  } else {

                    await audioPlayer.play(UrlSource('/data/user/0/com.example.audiorecorder/cache/audio'));
                    
                    isPlaying = true;
                  }
                },
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              ),
            )
          ],
        ),
      ),
    );
  }
}
