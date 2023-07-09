import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';

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
  // All supported flutter and text-to-speech languages from code to name
  // Will add 5 at a time (here and there)
  // Is a slower LinkedHashMap but this supports better syntax
  static const Map<String, String> languageCodeToName = {
    'af': 'Afrikaans',
    'am': 'Amharic',
    'ar': 'Arabic',
    'bn': 'Bangla', // Bengali
    'bg': 'Bulgarian',
  };

  final AudioPlayer player = AudioPlayer();
  var isPlaying = false; // doesn't start 'til pressed
  final deviceLanguage = Platform.localeName.split('_')[0];

  _MyHomePageState() {
    // debug print language code
    print(deviceLanguage);

    player.onPlayerComplete.listen((event) {
      isPlaying = false; // works
    });
  }

  // TODO: first sound using Platform language
  // TODO: following sounds using location

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
