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

// TODO: general null safety
class _MyHomePageState extends State<MyHomePage> {
  // All(?) Bing Translater text-to-speech languages from code to name.
  // Codes are from Flutter's Platform widget in 'ISO 639-1' format.
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
  };

  // TODO: populate this while adding matching audio files
  // Stores GPS coordinates of capital of country using the list of official
  // languages (supported languages only)
  static const Map<Coordinate, List<String>> coordinateToLanguages = {
    Coordinate(-25.746111, 28.188056): ['afrikaans', 'english'], // South Africa
    Coordinate(9.016667, 38.75): ['amharic'], // Ethiopia
    Coordinate(36.7, 3.216667): ['arabic'], // Algeria
    Coordinate(26.216667, 50.583333): ['arabic'], // Bahrain
    Coordinate(-11.683333, 43.266667): ['arabic', 'french'], // Comoros
    Coordinate(12.1, 16.033333): ['arabic', 'french'], // Chad
    Coordinate(11.6, 43.166667): ['arabic', 'french'], // Djibouti
    Coordinate(30.033333, 31.216667): ['arabic'], // Egypt
    Coordinate(15.337760, 38.931352): ['arabic', 'english'], // Eritrea
    Coordinate(33.333333, 44.433333): ['arabic'], // Iraq
    Coordinate(31.95, 35.933333): ['arabic'], // Jordan
    Coordinate(29.366667, 47.966667): ['arabic'], // Kuwait
    Coordinate(33.9, 35.533333): ['arabic'], // Lebanon
    Coordinate(32.896589, 13.179370): ['arabic'], // Libya
    Coordinate(18.15, -15.966667): ['arabic'], // Mauritania
    Coordinate(34.033333, -6.85): ['arabic'], // Morocco
    Coordinate(23.6, 58.55): ['arabic'], // Oman
    Coordinate(31.902940, 35.206210): ['arabic'], // Palestine
    Coordinate(25.3, 51.516667): ['arabic', 'english'], // Qatar
    Coordinate(24.694701, 46.723209): ['arabic'], // Saudi Arabia
    Coordinate(15.633333, 32.533333): ['arabic', 'english'], // Sudan
    Coordinate(33.5, 36.3): ['arabic'], // Syria
    Coordinate(36.816667, 10.183333): ['arabic'], // Tunisia
    Coordinate(15.353559, 44.205941): ['arabic'], // Yemen
  };

  final AudioPlayer player = AudioPlayer();
  final localeName = Platform.localeName;
  var inOrderLanguages = [];
  var languagesIndex = 0;
  var isPlaying = false; // doesn't start 'til pressed

  _MyHomePageState() {
    player.onPlayerComplete.listen((event) {
      _playNextAudio(); // until last audio
    });

    _determineLocation().then((location) {
      inOrderLanguages = _getLanguagesInOrder(location);
    });
  }

  void _playNextAudio() async {
    if (languagesIndex < inOrderLanguages.length) {
      print(inOrderLanguages[languagesIndex]); // debug
      await player.play(AssetSource('${inOrderLanguages[languagesIndex]}.mp3'));
      languagesIndex++;
    } else {
      isPlaying = false; // works
      languagesIndex = 0; // just in case
    }
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

  List<String> _getLanguagesInOrder(Position location) {
    // add the distance to each capital and the languages spoken there
    var nearestLanguages = PriorityQueue<DistanceToLanguages>();
    coordinateToLanguages.forEach((curCoord, languages) {
      var distance = Geolocator.distanceBetween(location.latitude,
          location.longitude, curCoord.latitude, curCoord.longitude);
      nearestLanguages.add(DistanceToLanguages(distance, languages));
    });

    // debug print. works so far!
    // while (nearestLanguages.isNotEmpty) {
    //   print(nearestLanguages.removeFirst().languages);
    // }

    // In order list of languages to play
    List<String> inOrderLanguages = [];

    // first language is system language
    String languageCode;
    if (localeName == 'fr_CA' || localeName == 'pt_BR') {
      // special case for 'french_canada' and 'portuguese_brazil'
      languageCode = localeName;
    } else {
      languageCode = localeName.split('_')[0]; // in the form e.g.: 'en_US'
    }

    // unsupported language names ignored and nearest language used first
    var languageName = languageCodeToName[languageCode];
    if (languageName != null) {
      inOrderLanguages.add(languageName);
    }

    // Add nearest languages first (no duplicates) and stay in order
    while (nearestLanguages.isNotEmpty) {
      var curLanguages = nearestLanguages.removeFirst().languages;

      for (var language in curLanguages) {
        if (!inOrderLanguages.contains(language)) {
          inOrderLanguages.add(language);
        }
      }
    }

    // debug check language order. works so far!
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
            languagesIndex = 0;
            _playNextAudio();
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
  final List<String> languages;

  const DistanceToLanguages(this.distance, this.languages);

  @override
  int compareTo(DistanceToLanguages other) {
    return distance.compareTo(other.distance);
  }
}
