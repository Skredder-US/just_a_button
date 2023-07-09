import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const JustAButton());
}

class JustAButton extends StatelessWidget {
  const JustAButton({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Just a Button',
      theme: ThemeData(
        // Temp default color
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final player = AudioPlayer();
  var isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          // Temp? simple button
          child: ElevatedButton(
        child: const Text(''),
        onPressed: () async {
          if (isPlaying) {
            player.stop();
          } else {
            // Temp example sound
            await player.play(AssetSource('example.mp3'));
          }
          isPlaying = !isPlaying;
        },
      )),
    );
  }
}
