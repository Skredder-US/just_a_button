import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:collection/collection.dart';

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

// TODO: first sound using device language
// TODO: following sounds using location
// TODO: general null safety
// Plan: get location; forEach coordinate add pair to priorityQueue;
// play the first pair's audiofile then the next until empty
class _MyHomePageState extends State<MyHomePage> {
  // All Microsoft Translater text-to-speech languages from code to name.
  // Codes are from Flutter's Platform widget in 'ISO 639-1' format.
  // Languages are as seen in Microsoft Translater.
  // Is a slower LinkedHashMap but this supports const.
  // Doubled checked for accuracy!
  static const Map<String, String> languageCodeToName = {
    'af': 'afrikaans',
    'am': 'amharic',
    'ar': 'arabic',
    'bn': 'bangla', // Bengali
    'bg': 'bulgarian',
    // Cantonese (Traditional) missing from codes
    'ca': 'catalan',
    'zh': 'chinese', // Simplified and Traditional are same for this
    'hr': 'croatian',
    'cs': 'czech',
    'da': 'danish',
    'nl': 'dutch',
    'en': 'english',
    'et': 'estonian',
    'fil': 'filipino',
    'fi': 'finnish',
    'fr': 'french',
    'fr_CA': 'french_canada',
    'gl': 'galician',
    'de': 'german',
    'el': 'greek',
    'gu': 'gujarati',
    'iw': 'hebrew',
    'hi': 'hindi',
    'hu': 'hungarian',
    'is': 'icelandic',
    'in': 'indonesian',
    'ga': 'irish',
    'it': 'italian',
    'ja': 'japanese',
    'kn': 'kannada',
    'kk': 'kazakh',
    'km': 'khmer',
    'ko': 'korean',
    'lo': 'lao',
    'lv': 'latvian',
    'lt': 'lithuanian',
    'mk': 'macedonian',
    'ms': 'malay',
    'ml': 'malayalam',
    'mt': 'maltese',
    'mr': 'marathi',
    'my': 'myanmar',
    'nb': 'norwegian', // from Bokmal
    'nn': 'norwegian', // from Nynorsk
    'ps': 'pashto',
    'fa': 'persian',
    'pl': 'polish',
    'pt_BR': 'portuguese_brazil',
    'pt': 'portuguese_portugal',
    'ro': 'romanian',
    'ru': 'russian',
    'sk': 'slovak',
    'sl': 'slovenian',
    'so': 'somali',
    'es': 'spanish',
    'sw': 'swahili',
    'sv': 'swedish',
    'ta': 'tamil',
    'te': 'telugu',
    'th': 'thai',
    'tr': 'turkish',
    'uk': 'ukrainian',
    'ur': 'urdu',
    'uz': 'uzbek',
    'vi': 'vietnamese',
    'cy': 'welsh',
    'zu': 'zulu',
  };

  // TODO: populate this after languageCodeToName
  // Stores GPS coordinates of capital of country using the list of official
  // languages (supported languages only)
  static const Map<Coordinate, List<String>> coordinateToLanguages = {
    Coordinate(-25.746111, 28.188056): [
      'zulu',
      'afrikaans',
      'english',
    ], // South Africa
    Coordinate(9.016667, 38.75): ['amharic', 'somali'], // Ethiopia
    Coordinate(36.7, 3.216667): ['arabic'], // Algeria
    Coordinate(26.216667, 50.583333): ['arabic'], // Bahrain
    Coordinate(-11.683333, 43.266667): ['arabic', 'french'], // Comoros
  };

  final AudioPlayer player = AudioPlayer();
  var isPlaying = false; // doesn't start 'til pressed
  final localeName = Platform.localeName;

  _MyHomePageState() {
    player.onPlayerComplete.listen((event) {
      // doesn't trigger on .stop();
      isPlaying = false; // works
    });

    _determineLocation().then((location) => getAudioFilesInOrder(location));
  }

  // Sample code found at 'https://pub.dev/packages/geolocator''
  // TODO: Handle errors
  Future<Position> _determineLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  // TODO: work in progress!
  List<String?> getAudioFilesInOrder(Position location) {
    // add the distance to each capital and the languages spoken there
    var nearestLanguages = PriorityQueue<DistanceToLanguages>();
    for (var curCoord in coordinateToLanguages.keys) {
      var distance = Geolocator.distanceBetween(location.latitude,
          location.longitude, curCoord.latitude, curCoord.longitude);
      // TODO: Null safe syntax is unavoidable?
      List<String>? languages = coordinateToLanguages[curCoord];
      nearestLanguages.add(DistanceToLanguages(distance, languages));
    }

    // debug print. works!
    // while (nearestLanguages.isNotEmpty) {
    //   print(nearestLanguages.removeFirst().languages);
    // }

    // In order list of languages to play
    List<String?> inOrderLanguages = [];

    // first language is system language
    String languageCode;
    if (localeName == 'fr_CA' || localeName == 'pt_BR') {
      // special case for 'French (Canada)' and 'Portuguese (Brazil)'
      languageCode = localeName;
    } else {
      languageCode = localeName.split('_')[0]; // in the form e.g.: 'en_US'
    }
    inOrderLanguages.add(languageCodeToName[languageCode]);

    // Add closest languages first
    while (nearestLanguages.isNotEmpty) {
      var curLanguages = nearestLanguages.removeFirst().languages;
      if (curLanguages != null) {
        // TODO: really neccesary to check for null?
        for (var language in curLanguages) {
          if (!inOrderLanguages.contains(language)) {
            inOrderLanguages.add(language);
          }
        }
      }
    }

    // debug check language order. works!
    for (var element in inOrderLanguages) {
      print(element);
    }

    return inOrderLanguages;
  }

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

class Coordinate {
  final double latitude; // Latitude, in degrees
  final double longitude; // Longitude, in degress

  const Coordinate(this.latitude, this.longitude);
}

class DistanceToLanguages implements Comparable<DistanceToLanguages> {
  final double distance;
  final List<String>? languages;

  const DistanceToLanguages(this.distance, this.languages);

  @override
  int compareTo(DistanceToLanguages other) {
    return distance.compareTo(other.distance);
  }
}
