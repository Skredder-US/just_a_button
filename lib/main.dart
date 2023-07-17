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
        // Average color of the universe as perceived from Earth
        // A.K.A. Cosmic latte
        // src: https://en.wikipedia.org/wiki/Cosmic_latte
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 248, 231),
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
  // All(TODO: ?) Bing Translater text-to-speech languages from code to name.
  // Codes are from Flutter's Platform widget in 'ISO 639-1' format.
  // Used to find user's device language, a language they should understand.
  // This language is played first so they know what's being said.
  // Is a slower LinkedHashMap but this supports const which is faster.
  // Doubled checked for accuracy!
  static const Map<String, String> languageCodeToName = {
    'af': 'afrikaans',
    'am': 'amharic',
    'ar': 'arabic',
    'bn': 'bangla', // Bengali
    'bg': 'bulgarian',
    // Cantonese (Traditional) missing from codes
    'ca': 'catalan',
    'zh': 'chinese',
    'hr': 'croatian',
    'cs': 'czech',
    'da': 'danish',
    'nl': 'dutch',
    'en': 'english',
    'et': 'estonian',
    'fi': 'finnish',
    'fr': 'french', // french and french canadian are same for this
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
    'my': 'myanmar', // Burmese
    'nb': 'norwegian', // from Bokmal
    'nn': 'norwegian', // from Nynorsk
    'ps': 'pashto',
    'fa': 'persian',
    'pl': 'polish',
    'pt': 'portuguese',
    'pt_BR': 'portuguese_brazil',
    'ro': 'romanian',
    'ru': 'russian',
    'sk': 'slovak',
    'sl': 'slovenian',
    'sr': 'serbian',
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
  // Infomation from Wikipedia.org
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
    Coordinate(22.3, 114.2): ['cantonese', 'english'], // Hong Kong (China)
    Coordinate(22.166667, 113.55): ['cantonese', 'portuguese'], // Macau (China)
    Coordinate(42.506389, 1.521389): ['catalan'], // Andorra
    Coordinate(39.916667, 116.383333): ['chinese'], // China
    Coordinate(25.066667, 121.516667): ['chinese'], // Taiwan
    Coordinate(1.283333, 103.833333): [
      'chinese',
      'malay',
      'english'
    ], // Singapore
    Coordinate(45.8, 16): ['croatian'], // Croatia
    Coordinate(43.866667, 18.416667): [
      'croatian',
      'serbian'
    ], // Bosnia and Herzegovina
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
    Coordinate(8.5, -12.1): ['english'], // Sierra Leone
    Coordinate(-9.431944, 159.955556): ['english'], // Solomon Islands
    Coordinate(4.85, 31.6): ['english'], // South Sudan
    Coordinate(-6.173056, 35.741944): ['english', 'arabic'], // Tanzania
    Coordinate(10.666667, -61.5075): ['english'], // Trinidad and Tobago
    Coordinate(0.313611, 32.581111): ['english'], // Uganda
    Coordinate(-15.416667, 28.283333): ['english'], // Zambia
    Coordinate(-17.829167, 31.052222): ['english'], // Zimbabwe
    Coordinate(-35.308056, 149.124444): ['english'], // Australia
    Coordinate(-41.3, 174.783333): ['english'], // New Zealand
    Coordinate(51.5, -0.116667): ['english'], // United Kingdom
    Coordinate(59.416667, 24.75): ['estonian'], // Estonia
    Coordinate(60.170833, 24.9375): ['finnish', 'swedish'], // Finland
    Coordinate(6.497222, 2.605): ['french'], // Benin
    Coordinate(12.366667, -1.533333): ['french'], // Burkina Faso
    Coordinate(4.366667, 18.583333): ['french'], // Central African Republic
    Coordinate(-4.266667, 15.283333): ['french'], // Congo
    Coordinate(-4.316667, 15.316667): ['french'], // Dem. Rep. of the Congo
    Coordinate(3.75, 8.783333): [
      'spanish',
      'french',
      'portuguese'
    ], // Equatorial Guinea
    Coordinate(48.85, 2.35): ['french'], // Franch
    Coordinate(0.383333, 9.45): ['french'], // Gabon
    Coordinate(9.516667, -13.7): ['french'], // Guinea
    Coordinate(18.533333, -72.333333): ['french'], // Haiti
    Coordinate(6.85, -5.3): ['french'], // Ivory Coast
    Coordinate(49.814444, 6.131667): ['french', 'german'], // Luxembourg
    Coordinate(-18.916667, 47.516667): ['french'], // Madagascar
    Coordinate(12.65, -8): ['french'], // Mali
    Coordinate(43.731111, 7.42): ['french'], // Monaco
    Coordinate(13.533333, 2.083333): ['french'], // Niger
    Coordinate(14.666667, -17.416667): ['french'], // Senegal
    Coordinate(-4.616667, 55.45): ['english', 'french'], // Seychelles
    Coordinate(46.95, 7.45): ['german', 'french', 'italian'], // Switzerland
    Coordinate(6.133333, 1.216667): ['french'], // Togo
    Coordinate(-17.733333, 168.316667): ['english', 'french'], // Vanuatu
    Coordinate(48.2, 16.35): ['german'], // Austria
    Coordinate(52.516667, 13.383333): ['german'], // Germany
    Coordinate(47.166667, 9.509722): ['german'], // Liechtenstein
    Coordinate(37.966667, 23.716667): ['greek'], // Greece
    Coordinate(35.166667, 33.366667): ['greek', 'turkish'], // Cyprus
    Coordinate(23.22, 72.655): ['gujarati', 'hindi'], // Gujrat (India)
    Coordinate(31.783333, 35.216667): ['hebrew'], // Israel
    Coordinate(47.433333, 19.25): ['hungarian'], // Hungary
    Coordinate(64.133333, -21.933333): ['icelandic'], // Iceland
    Coordinate(-6.166667, 106.816667): ['indonesian'], // Indonesia
    Coordinate(43.933333, 12.433333): ['italian'], // San Marino
    Coordinate(41.9025, 12.4525): ['italian'], // Vatican City
    Coordinate(35.683333, 139.766667): ['japanese'], // Japan
    Coordinate(12.978889, 77.591667): ['kannada'], // Karnataka (India)
    Coordinate(51.166667, 71.433333): ['kazakh', 'russian'], // Kazakhstan
    Coordinate(51.95, 85.966667): ['russian', 'kazakh'], // Altai Republic (RU)
    Coordinate(11.57, 104.91): ['khmer'], // Cambodia
    Coordinate(37.55, 126.966667): ['korean'], // South Korean
    Coordinate(39.033333, 125.75): ['korean'], // North Korean
    Coordinate(17.966667, 102.6): ['lao'], // Laos
    Coordinate(56.95, 24.1): ['latvian'], // Latvia
    Coordinate(54.683333, 25.316667): ['lithuanian'], // Lithuanian
    Coordinate(42, 21.433333): ['macedonian'], // North Macedonia
    Coordinate(4.890283, 114.942217): ['malay'], // Brunei
    Coordinate(3.133333, 101.683333): ['malay'], // Malaysia
    Coordinate(10, 76.3): ['malayalam'], // Kerala (India)
    Coordinate(18.97, 72.82): ['marathi'], // Maharashtra (India)
    Coordinate(19.75, 96.1): ['myanmar'], // Myanmar
    Coordinate(59.933333, 10.683333): ['norwegian'], // Norway
    Coordinate(34.516667, 69.183333): ['pashto'], // Afghanistan
    Coordinate(35.683333, 51.416667): ['persian'], // Iran
    Coordinate(52.216667, 21.033333): ['polish'], // Poland
    Coordinate(-8.833333, 13.333333): ['portuguese'], // Angola
    Coordinate(14.916667, -23.516667): ['portuguese'], // Cape Verde
    Coordinate(-8.55, 125.56): ['portuguese'], // East Timor
    Coordinate(12, -15): ['portuguese'], // Guinea-Bissau
    Coordinate(-25.95, 32.583333): ['portuguese'], // Mozambique
    Coordinate(38.766667, -9.15): ['portuguese'], // Portugal
    Coordinate(0.333333, 6.733333): ['portuguese'], // Sao Tome ad Principe
    Coordinate(-15.783333, -47.866667): ['portuguese_brazil'], // Brazil
    Coordinate(44.416667, 26.1): ['romanian'], // Romania
    Coordinate(47, 28.916667): ['romanian'], // Moldova
    Coordinate(45.254167, 19.8425): [
      'serbian',
      'hungarian',
      'slovak',
      'romanian',
      'croatian'
    ], // Vojvodina
    Coordinate(55.755833, 37.617222): ['russian'], // Russia
    Coordinate(53.916667, 27.55): ['russian'], // Belarus
    Coordinate(42.866667, 74.6): ['russian'], // Kyrgyzstan
    Coordinate(38.55, 68.8): ['russian'], // Tajikistan
    Coordinate(48.15, 17.116667): ['slovak'], // Slovakia
    Coordinate(46.051389, 14.506111): ['slovenian'], // Slovenia
    Coordinate(44.8, 20.466667): ['serbian'], // Serbia
    Coordinate(42.666667, 21.166667): ['serbian'], // Kosovo
  };

  final player = AudioPlayer();
  final localeName = Platform.localeName;
  var languagesInOrder = [];
  var languageIndex = 0;
  var isPlaying = false; // doesn't start 'til pressed

  _MyHomePageState() {
    // Use actual (when allowed) or random location to populate the list
    // of languages, nearest to farthest.
    _getLocation().then((location) => _prepareLanguagesInOrder(location));

    // When one language audio file completes, play the next (or end)
    player.onPlayerComplete.listen((event) {
      languageIndex++; // advance to next audio file only when one completes
      _playNextAudio(); // until last audio
    });
  }

  // Request user for device location then return device location if allowed,
  // otherwise return a random location.
  // From sample code found at 'https://pub.dev/packages/geolocator'
  Future<Coordinate> _getLocation() async {
    // Test if location services are enabled.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return _getRandomCoordinate();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return _getRandomCoordinate();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return _getRandomCoordinate();
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    var position = await Geolocator.getCurrentPosition();
    return Coordinate(position.latitude, position.longitude);
  }

  Coordinate _getRandomCoordinate() {
    // Generate a random location
    Random random = Random();
    var randomLatitude = random.nextDouble() * 180 - 90;
    var randomLongitude = random.nextDouble() * 180 - 90;

    return Coordinate(randomLatitude, randomLongitude);
  }

  void _prepareLanguagesInOrder(Coordinate location) {
    // debug
    print(location.latitude);
    print(location.longitude);

    // add the distance to each capital and the languages spoken there
    var nearestLanguages = PriorityQueue<DistanceToLanguages>();

    coordinateToLanguages.forEach((curCoord, languages) {
      var distance = Geolocator.distanceBetween(location.latitude,
          location.longitude, curCoord.latitude, curCoord.longitude);

      nearestLanguages.add(DistanceToLanguages(distance, languages));
    });

    // --- add languages ---
    // first language is system language when supported
    String languageCode;
    if (localeName == 'pt_BR') {
      // special case for 'portuguese_brazil'
      languageCode = localeName;
    } else {
      languageCode = localeName.split('_')[0]; // in the form e.g.: 'en_US'
    }

    // unsupported language names ignored and nearest language is used first
    var languageName = languageCodeToName[languageCode];
    if (languageName != null) {
      languagesInOrder.add(languageName);
    }

    // Add nearest languages first (no duplicates)
    while (nearestLanguages.isNotEmpty) {
      // debug
      var distToLangs = nearestLanguages.removeFirst();
      var curLanguages = distToLangs.languages;
      // var curLanguages = nearestLanguages.removeFirst().languages;

      for (var language in curLanguages) {
        if (!languagesInOrder.contains(language)) {
          languagesInOrder.add(language);
          print('${distToLangs.distance}: $language'); // debug
        }
      }
    }
  }

  void _playNextAudio() async {
    // play next audio file unless none left to play
    if (languageIndex < languagesInOrder.length) {
      print(languagesInOrder[languageIndex]);

      // Add a delay between audio files
      if (languageIndex > 0) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Handle when the user pressed the button during the delay
      if (isPlaying) {
        await player
            .play(AssetSource('${languagesInOrder[languageIndex]}.mp3'));

        // Handle when the user pressed the button while the asset was loading
        if (!isPlaying) {
          player.stop();
        }
      }
    } else {
      isPlaying = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          // Average color of Earth (as seen from a satellite)
          // src: https://www.jeffreythompson.org/blog/2014/08/13/average-color-of-the-earth/
          backgroundColor: const Color.fromARGB(255, 23, 57, 61),
          fixedSize: _getButtonSize(),
        ),
        onPressed: () {
          if (isPlaying) {
            isPlaying = false;
            player.stop();
          } else {
            isPlaying = true;
            languageIndex = 0; // start at the beginning
            _playNextAudio();
          }
        },
        child: const Text(''), // no text, only button
      )),
    );
  }

  // Return a Size with same width and height equal to the min of the screen
  // width and height divided by the golden ratio.
  Size _getButtonSize() {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    var diameter =
        min(screenHeight, screenWidth) / 1.6180339887; // golden ratio
    return Size(diameter, diameter);
  }
}

// Geographic coordinate for positions on Earth
class Coordinate {
  // both in decimal degrees
  final double latitude;
  final double longitude;

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
