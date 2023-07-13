import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
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
    Coordinate(23.763889, 90.388889): ['bangla'], // Bangladesh
    Coordinate(42.683333, 23.316667): ['bulgarian'], // Bulgaria
    Coordinate(42.506389, 1.521389): ['catalan'], // Andorra
    Coordinate(39.916667, 116.383333): ['chinese'], // China
    Coordinate(25.066667, 121.516667): ['chinese'], // Taiwan
    Coordinate(1.283333, 103.833333): [
      'chinese',
      'malay',
      'english'
    ], // Singapore
    Coordinate(45.8, 16): ['croatian'], // Croatia
    Coordinate(43.866667, 18.416667): ['croatian'], // B&H
    Coordinate(50.083333, 14.466667): ['czech'], // Czech Republic
    Coordinate(55.670094, 12.600247): ['danish'], // Denmark
    Coordinate(52.366667, 4.883333): ['dutch'], // Netherlands
    Coordinate(50.85, 4.35): ['dutch', 'french', 'german'], // Belgium
    Coordinate(5.833333, -55.166667): ['dutch'], // Suriname
    Coordinate(25.078056, -77.338611): ['english'], // Bahamas
    Coordinate(13.097778, -59.618333): ['english'], // Barbados
    Coordinate(17.25, -88.766667): ['english'], // Belize
    Coordinate(-24.658333, 25.908333): ['english'], // Botswana
    Coordinate(-3.5, 30): ['french', 'english'], // Burundi
    Coordinate(3.866667, 11.516667): ['french', 'english'], // Cameroon
    Coordinate(45.4, -75.666667): ['english', 'french'], // Canada
    Coordinate(15.3, -61.383333): ['english'], // Domenica
    Coordinate(-18.166667, 178.45): ['english'], // Fiji
    Coordinate(13.466667, -16.6): ['english'], // The Gambia
    Coordinate(5.555, -0.1925): ['english'], // Ghana
    Coordinate(12.05, -61.75): ['english'], // Grenada
    Coordinate(6.805833, -58.150833): ['english'], // Guyana
    Coordinate(28.613889, 77.208333): ['hindi', 'english'], // India
    Coordinate(53.344167, -6.2675): ['irish', 'english'], // Ireland
    Coordinate(17.971389, -76.793056): ['english'], // Jamaica
    Coordinate(-1.266667, 36.8): ['english'], // Kenya
    Coordinate(6.316667, -10.8): ['english'], // Liberia
    Coordinate(-13.95, 33.7): ['english'], // Malawi
    Coordinate(35.9, 14.516667): ['maltese', 'english'], // Malta
    Coordinate(7.116667, 171.066667): ['english'], // Marshall Islands
    Coordinate(-20.2, 57.5): ['english', 'french'], // Mauritius
    Coordinate(6.916667, 158.183333): ['english'], // Micronesia
    Coordinate(-22.566667, 17.083333): ['english'], // Nambia
    Coordinate(9.066667, 7.483333): ['english'], // Nigeria
    Coordinate(33.691667, 73.05): ['english'], // Pakistan
    Coordinate(-9.478889, 147.149444): ['english'], // Papua New Guinea
    Coordinate(14.582260, 120.974800): ['english'], // Philippines
    Coordinate(-1.943889, 30.059444): ['french', 'english'], // Rwanda
    Coordinate(-13.833333, -171.762222): ['english'], // Samoa
  };

  final AudioPlayer player = AudioPlayer();
  final localeName = Platform.localeName;
  var inOrderLanguages = [];
  var languagesIndex = 0;
  var isPlaying = false; // doesn't start 'til pressed

  _MyHomePageState() {
    // Be ready to play the nearest languages in order on button press!
    _getLocation().then((actualLocation) {
      _getLanguagesInOrder(
          Coordinate(actualLocation.latitude, actualLocation.longitude));
    }).catchError((err) {
      // Not allowed to use device location!
      // Generate a random location
      Random random = Random();
      var randLatitude = random.nextDouble() * 180 - 90;
      var randLongitude = random.nextDouble() * 180 - 90;

      _getLanguagesInOrder(Coordinate(randLatitude, randLongitude));
    });

    // When one language audio file completes, play the next (or end)
    player.onPlayerComplete.listen((event) {
      _playNextAudio(); // until last audio
    });
  }

  // Sample code found at 'https://pub.dev/packages/geolocator'
  Future<Position> _getLocation() async {
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

  void _getLanguagesInOrder(Coordinate location) {
    print(location.latitude); // debug
    print(location.longitude);

    // add the distance to each capital and the languages spoken there
    var nearestLanguages = PriorityQueue<DistanceToLanguages>();
    coordinateToLanguages.forEach((curCoord, languages) {
      var distance = Geolocator.distanceBetween(location.latitude,
          location.longitude, curCoord.latitude, curCoord.longitude);

      nearestLanguages.add(DistanceToLanguages(distance, languages));
    });

    // --- add languages ---
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

    // Add nearest languages first (no duplicates)
    while (nearestLanguages.isNotEmpty) {
      var curLanguages = nearestLanguages.removeFirst().languages;

      for (var language in curLanguages) {
        if (!inOrderLanguages.contains(language)) {
          inOrderLanguages.add(language);
        }
      }
    }
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
