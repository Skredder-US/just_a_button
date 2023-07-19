import 'dart:collection';
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
  // All Bing Translater text-to-speech languages from code to name.
  // Codes are from Flutter's Platform widget in 'ISO 639-1' format.
  // Used to find user's device language, a language they should understand.
  // This language is played first so they know what's being said.
  // Is a slower LinkedHashMap but this supports const which is faster.
  // Doubled checked for accuracy!
  static const languageCodeToName = {
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
    'pt_BR': 'portuguese_brazil',
    'pt': 'portuguese',
    'ro': 'romanian',
    'ru': 'russian',
    'sk': 'slovak',
    'sl': 'slovenian',
    'sr': 'serbian',
    'es': 'spanish',
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

  // Stores GPS coordinates of capital of country using the list of official
  // languages (supported languages only)
  // Infomation from Wikipedia.org
  static const coordinateToLanguages = {
    _Coordinate(-25.746111, 28.188056): [
      'afrikaans',
      'english'
    ], // South Africa
    _Coordinate(9.016667, 38.75): ['amharic'], // Ethiopia
    _Coordinate(36.7, 3.216667): ['arabic'], // Algeria
    _Coordinate(26.216667, 50.583333): ['arabic'], // Bahrain
    _Coordinate(-11.683333, 43.266667): ['arabic', 'french'], // Comoros
    _Coordinate(12.1, 16.033333): ['arabic', 'french'], // Chad
    _Coordinate(11.6, 43.166667): ['arabic', 'french'], // Djibouti
    _Coordinate(30.033333, 31.216667): ['arabic'], // Egypt
    _Coordinate(15.337760, 38.931352): ['arabic', 'english'], // Eritrea
    _Coordinate(33.333333, 44.433333): ['arabic'], // Iraq
    _Coordinate(31.95, 35.933333): ['arabic'], // Jordan
    _Coordinate(29.366667, 47.966667): ['arabic'], // Kuwait
    _Coordinate(33.9, 35.533333): ['arabic'], // Lebanon
    _Coordinate(32.896589, 13.179370): ['arabic'], // Libya
    _Coordinate(18.15, -15.966667): ['arabic'], // Mauritania
    _Coordinate(34.033333, -6.85): ['arabic'], // Morocco
    _Coordinate(23.6, 58.55): ['arabic'], // Oman
    _Coordinate(31.902940, 35.206210): ['arabic'], // Palestine
    _Coordinate(25.3, 51.516667): ['arabic', 'english'], // Qatar
    _Coordinate(24.694701, 46.723209): ['arabic'], // Saudi Arabia
    _Coordinate(15.633333, 32.533333): ['arabic', 'english'], // Sudan
    _Coordinate(33.5, 36.3): ['arabic'], // Syria
    _Coordinate(36.816667, 10.183333): ['arabic'], // Tunisia
    _Coordinate(15.353559, 44.205941): ['arabic'], // Yemen
    _Coordinate(23.763889, 90.388889): ['bangla'], // Bangladesh
    _Coordinate(42.683333, 23.316667): ['bulgarian'], // Bulgaria
    _Coordinate(22.3, 114.2): ['cantonese', 'english'], // Hong Kong (China)
    _Coordinate(22.166667, 113.55): [
      'cantonese',
      'portuguese'
    ], // Macau (China)
    _Coordinate(42.506389, 1.521389): ['catalan'], // Andorra
    _Coordinate(39.916667, 116.383333): ['chinese'], // China
    _Coordinate(25.066667, 121.516667): ['chinese'], // Taiwan
    _Coordinate(1.283333, 103.833333): [
      'malay',
      'chinese',
      'tamil',
      'english'
    ], // Singapore
    _Coordinate(45.8, 16): ['croatian'], // Croatia
    _Coordinate(43.866667, 18.416667): [
      'croatian',
      'serbian'
    ], // Bosnia and Herzegovina
    _Coordinate(50.083333, 14.466667): ['czech'], // Czech Republic
    _Coordinate(55.670094, 12.600247): ['danish'], // Denmark
    _Coordinate(52.366667, 4.883333): ['dutch'], // Netherlands
    _Coordinate(50.85, 4.35): ['dutch', 'french', 'german'], // Belgium
    _Coordinate(5.833333, -55.166667): ['dutch'], // Suriname
    _Coordinate(25.078056, -77.338611): ['english'], // Bahamas
    _Coordinate(13.097778, -59.618333): ['english'], // Barbados
    _Coordinate(17.25, -88.766667): ['english'], // Belize
    _Coordinate(-24.658333, 25.908333): ['english'], // Botswana
    _Coordinate(-3.5, 30): ['french', 'english'], // Burundi
    _Coordinate(3.866667, 11.516667): ['french', 'english'], // Cameroon
    _Coordinate(45.4, -75.666667): ['english', 'french'], // Canada
    _Coordinate(15.3, -61.383333): ['english'], // Domenica
    _Coordinate(-18.166667, 178.45): ['english'], // Fiji
    _Coordinate(13.466667, -16.6): ['english'], // The Gambia
    _Coordinate(5.555, -0.1925): ['english'], // Ghana
    _Coordinate(12.05, -61.75): ['english'], // Grenada
    _Coordinate(6.805833, -58.150833): ['english'], // Guyana
    _Coordinate(28.613889, 77.208333): ['hindi', 'english'], // India
    _Coordinate(53.344167, -6.2675): ['irish', 'english'], // Ireland
    _Coordinate(17.971389, -76.793056): ['english'], // Jamaica
    _Coordinate(-1.266667, 36.8): ['english'], // Kenya
    _Coordinate(6.316667, -10.8): ['english'], // Liberia
    _Coordinate(-13.95, 33.7): ['english'], // Malawi
    _Coordinate(35.9, 14.516667): ['maltese', 'english'], // Malta
    _Coordinate(7.116667, 171.066667): ['english'], // Marshall Islands
    _Coordinate(-20.2, 57.5): ['english', 'french'], // Mauritius
    _Coordinate(6.916667, 158.183333): ['english'], // Micronesia
    _Coordinate(-22.566667, 17.083333): ['english'], // Nambia
    _Coordinate(9.066667, 7.483333): ['english'], // Nigeria
    _Coordinate(33.691667, 73.05): ['urdu', 'english'], // Pakistan
    _Coordinate(-9.478889, 147.149444): ['english'], // Papua New Guinea
    _Coordinate(14.582260, 120.974800): ['english'], // Philippines
    _Coordinate(-1.943889, 30.059444): ['french', 'english'], // Rwanda
    _Coordinate(-13.833333, -171.762222): ['english'], // Samoa
    _Coordinate(8.5, -12.1): ['english'], // Sierra Leone
    _Coordinate(-9.431944, 159.955556): ['english'], // Solomon Islands
    _Coordinate(4.85, 31.6): ['english'], // South Sudan
    _Coordinate(-6.173056, 35.741944): ['english', 'arabic'], // Tanzania
    _Coordinate(10.666667, -61.5075): ['english'], // Trinidad and Tobago
    _Coordinate(0.313611, 32.581111): ['english'], // Uganda
    _Coordinate(-15.416667, 28.283333): ['english'], // Zambia
    _Coordinate(-17.829167, 31.052222): ['english'], // Zimbabwe
    _Coordinate(-35.308056, 149.124444): ['english'], // Australia
    _Coordinate(-41.3, 174.783333): ['english'], // New Zealand
    _Coordinate(51.5, -0.116667): ['english'], // United Kingdom
    _Coordinate(59.416667, 24.75): ['estonian'], // Estonia
    _Coordinate(60.170833, 24.9375): ['finnish', 'swedish'], // Finland
    _Coordinate(6.497222, 2.605): ['french'], // Benin
    _Coordinate(12.366667, -1.533333): ['french'], // Burkina Faso
    _Coordinate(4.366667, 18.583333): ['french'], // Central African Republic
    _Coordinate(-4.266667, 15.283333): ['french'], // Congo
    _Coordinate(-4.316667, 15.316667): ['french'], // Dem. Rep. of the Congo
    _Coordinate(3.75, 8.783333): [
      'spanish',
      'french',
      'portuguese'
    ], // Equatorial Guinea
    _Coordinate(48.85, 2.35): ['french'], // Franch
    _Coordinate(0.383333, 9.45): ['french'], // Gabon
    _Coordinate(9.516667, -13.7): ['french'], // Guinea
    _Coordinate(18.533333, -72.333333): ['french'], // Haiti
    _Coordinate(6.85, -5.3): ['french'], // Ivory Coast
    _Coordinate(49.814444, 6.131667): ['french', 'german'], // Luxembourg
    _Coordinate(-18.916667, 47.516667): ['french'], // Madagascar
    _Coordinate(12.65, -8): ['french'], // Mali
    _Coordinate(43.731111, 7.42): ['french'], // Monaco
    _Coordinate(13.533333, 2.083333): ['french'], // Niger
    _Coordinate(14.666667, -17.416667): ['french'], // Senegal
    _Coordinate(-4.616667, 55.45): ['english', 'french'], // Seychelles
    _Coordinate(46.95, 7.45): ['german', 'french', 'italian'], // Switzerland
    _Coordinate(6.133333, 1.216667): ['french'], // Togo
    _Coordinate(-17.733333, 168.316667): ['english', 'french'], // Vanuatu
    _Coordinate(48.2, 16.35): ['german'], // Austria
    _Coordinate(52.516667, 13.383333): ['german'], // Germany
    _Coordinate(47.166667, 9.509722): ['german'], // Liechtenstein
    _Coordinate(37.966667, 23.716667): ['greek'], // Greece
    _Coordinate(35.166667, 33.366667): ['greek', 'turkish'], // Cyprus
    _Coordinate(23.22, 72.655): ['gujarati', 'hindi'], // Gujrat (India)
    _Coordinate(31.783333, 35.216667): ['hebrew'], // Israel
    _Coordinate(47.433333, 19.25): ['hungarian'], // Hungary
    _Coordinate(64.133333, -21.933333): ['icelandic'], // Iceland
    _Coordinate(-6.166667, 106.816667): ['indonesian'], // Indonesia
    _Coordinate(43.933333, 12.433333): ['italian'], // San Marino
    _Coordinate(41.9025, 12.4525): ['italian'], // Vatican City
    _Coordinate(35.683333, 139.766667): ['japanese'], // Japan
    _Coordinate(12.978889, 77.591667): ['kannada'], // Karnataka (India)
    _Coordinate(51.166667, 71.433333): ['kazakh', 'russian'], // Kazakhstan
    _Coordinate(51.95, 85.966667): ['russian', 'kazakh'], // Altai Republic (RU)
    _Coordinate(11.57, 104.91): ['khmer'], // Cambodia
    _Coordinate(37.55, 126.966667): ['korean'], // South Korean
    _Coordinate(39.033333, 125.75): ['korean'], // North Korean
    _Coordinate(17.966667, 102.6): ['lao'], // Laos
    _Coordinate(56.95, 24.1): ['latvian'], // Latvia
    _Coordinate(54.683333, 25.316667): ['lithuanian'], // Lithuanian
    _Coordinate(42, 21.433333): ['macedonian'], // North Macedonia
    _Coordinate(4.890283, 114.942217): ['malay'], // Brunei
    _Coordinate(3.133333, 101.683333): ['malay'], // Malaysia
    _Coordinate(10, 76.3): ['malayalam'], // Kerala (India)
    _Coordinate(18.97, 72.82): ['marathi'], // Maharashtra (India)
    _Coordinate(19.75, 96.1): ['myanmar'], // Myanmar
    _Coordinate(59.933333, 10.683333): ['norwegian'], // Norway
    _Coordinate(34.516667, 69.183333): ['pashto'], // Afghanistan
    _Coordinate(35.683333, 51.416667): ['persian'], // Iran
    _Coordinate(52.216667, 21.033333): ['polish'], // Poland
    _Coordinate(-8.833333, 13.333333): ['portuguese'], // Angola
    _Coordinate(14.916667, -23.516667): ['portuguese'], // Cape Verde
    _Coordinate(-8.55, 125.56): ['portuguese'], // East Timor
    _Coordinate(12, -15): ['portuguese'], // Guinea-Bissau
    _Coordinate(-25.95, 32.583333): ['portuguese'], // Mozambique
    _Coordinate(38.766667, -9.15): ['portuguese'], // Portugal
    _Coordinate(0.333333, 6.733333): ['portuguese'], // Sao Tome ad Principe
    _Coordinate(-15.783333, -47.866667): ['portuguese_brazil'], // Brazil
    _Coordinate(44.416667, 26.1): ['romanian'], // Romania
    _Coordinate(47, 28.916667): ['romanian'], // Moldova
    _Coordinate(45.254167, 19.8425): [
      'serbian',
      'hungarian',
      'slovak',
      'romanian',
      'croatian'
    ], // Vojvodina
    _Coordinate(55.755833, 37.617222): ['russian'], // Russia
    _Coordinate(53.916667, 27.55): ['russian'], // Belarus
    _Coordinate(42.866667, 74.6): ['russian'], // Kyrgyzstan
    _Coordinate(38.55, 68.8): ['russian'], // Tajikistan
    _Coordinate(48.15, 17.116667): ['slovak'], // Slovakia
    _Coordinate(46.051389, 14.506111): ['slovenian'], // Slovenia
    _Coordinate(44.8, 20.466667): ['serbian'], // Serbia
    _Coordinate(42.666667, 21.166667): ['serbian'], // Kosovo
    _Coordinate(-34.6, -58.383333): ['spanish'], // Argentina
    _Coordinate(-19.0475, -65.26): ['spanish'], // Bolivia
    _Coordinate(-33.433333, -70.666667): ['spanish'], // Chile
    _Coordinate(4.583333, -74.066667): ['spanish'], // Colombia
    _Coordinate(9.933333, -84.083333): ['spanish'], // Costa Rica
    _Coordinate(23.133333, -82.383333): ['spanish'], // Cuba
    _Coordinate(19, -70.666667): ['spanish'], // Dominican Republic
    _Coordinate(-0.22, -78.511944): ['spanish'], // Ecuador
    _Coordinate(13.698889, -89.191389): ['spanish'], // El Salvador
    _Coordinate(14.633333, -90.5): ['spanish'], // Guatemala
    _Coordinate(14.1, -87.216667): ['spanish'], // Honduras
    _Coordinate(19.433333, -99.133333): ['spanish'], // Mexico
    _Coordinate(12.1, -86.233333): ['spanish'], // Nicaragua
    _Coordinate(8.966667, -79.533333): ['spanish'], // Panama
    _Coordinate(-25.266667, -57.666667): ['spanish'], // Paraguay
    _Coordinate(-12.043333, -77.028333): ['spanish'], // Peru
    _Coordinate(40.433333, -3.7): ['spanish'], // Spain
    _Coordinate(-34.883333, -56.166667): ['spanish'], // Uruguay
    _Coordinate(10.5, -66.916667): ['spanish'], // Venezuela
    _Coordinate(59.35, 18.066667): ['swedish'], // Sweden
    _Coordinate(13.0825, 80.275): ['tamil', 'english'], // Tamil Nadu (India)
    _Coordinate(6.933333, 79.866667): ['tamil'], // Sri Lanka
    _Coordinate(16.51, 80.52): ['telugu', 'urdu'], // Andhra Pradesh (India)
    _Coordinate(17.8244, 79.1879): ['telugu'], // Telangana (India)
    _Coordinate(13.75, 100.483333): ['thai'], // Thailand
    _Coordinate(39.916667, 32.85): ['turkish'], // Turkey
    _Coordinate(49, 32): ['ukrainian'], // Ukraine
    _Coordinate(41.316667, 69.266667): ['uzbek'], // Uzbekistan
    _Coordinate(21.033333, 105.85): ['vietnamese'], // Vietnam
    _Coordinate(51.483333, -3.183333): ['english', 'welsh'], // Wales
  };

  static const translations = {
    'afrikaans': 'Ek hoop jy het \'n goeie dag',
    'amharic': 'መልካም ቀን ይኑርህ ብዬ ተስፋ አደርጋለሁ',
    'arabic': 'أتمنى لك يوما سعيدا',
    'bangla': 'আমি আশা করি আপনার দিনটি ভাল কাটবে',
    'bulgarian': 'Надявам се да имате добър ден',
    'cantonese': '希望你有美好嘅一日', // traditional
    'catalan': 'Espero que tingueu un bon dia',
    'chinese': '希望你有美好的一天',
    'croatian': 'Nadam se da ćete imati dobar dan',
    'czech': 'Doufám, že máte dobrý den',
    'danish': 'Jeg håber du får en god dag',
    'dutch': 'Ik hoop dat je een goede dag hebt',
    'english': 'I hope you have a good day',
    'estonian': 'Loodan, et teil on hea päev',
    'finnish': 'Toivottavasti sinulla on hyvä päivä',
    'french': 'J’espère que vous passez une bonne journée',
    'german': 'Ich hoffe ihr habt einen schönen Tag',
    'greek': 'Ελπίζω να έχετε μια καλή μέρα',
    'gujarati': 'હું આશા રાખું છું કે તમારો દિવસ સારો રહેશે',
    'hebrew': 'אני מקווה שיהיה לך יום טוב',
    'hindi': 'मुझे आशा है कि आपके पास एक अच्छा दिन है',
    'hungarian': 'Remélem, jó napod lesz',
    'icelandic': 'Vonandi eigið þið góðan dag',
    'indonesian': 'Saya harap Anda memiliki hari yang baik',
    'irish': 'Tá súil agam go bhfuil lá maith agat',
    'italian': 'Spero che tu abbia una buona giornata',
    'japanese': '良い一日をお過ごしください',
    'kannada': 'ನೀವು ಉತ್ತಮ ದಿನವನ್ನು ಹೊಂದಿದ್ದೀರಿ ಎಂದು ನಾನು ಭಾವಿಸುತ್ತೇನೆ',
    'kazakh': 'Сіздерде жақсы күн болады деп үміттенемін',
    'khmer': 'ខ្ញុំ សង្ឃឹម ថា អ្នក មាន ថ្ងៃ ល្អ',
    'korean': '좋은 하루 보내시기 바랍니다',
    'lao': 'ຂ້າພະເຈົ້າຫວັງວ່າທ່ານຈະມີມື້ດີ',
    'latvian': 'Es ceru, ka jums ir laba diena',
    'lithuanian': 'Tikiuosi, kad jums bus gera diena',
    'macedonian': 'Се надевам дека имаш добар ден.',
    'malay': 'Saya harap anda mempunyai hari yang baik',
    'malayalam': 'നിങ്ങൾക്ക് ഒരു നല്ല ദിവസം ആശംസിക്കുന്നു',
    'maltese': 'Nispera li għandek ġurnata tajba',
    'marathi': 'मला आशा आहे की तुमचा दिवस चांगला जाईल.',
    'myanmar': 'ခင်ဗျားတို့ဟာ ကောင်းတဲ့ နေ့ရက်တွေ ရှိမယ်လို့ မျှော်လင့်ပါတယ်။',
    'norwegian': 'Jeg håper du har en god dag',
    'pashto': 'کاش چې تاسو ښه ورځ ولرئ',
    'persian': 'امیدوارم روز خوبی داشته باشی',
    'polish': 'Mam nadzieję, że masz dobry dzień',
    'portuguese_brazil': 'Espero que você tenha um bom dia',
    'portuguese': 'Espero que tenham um bom dia',
    'romanian': 'Sper să aveți o zi bună',
    'russian': 'Я надеюсь, что у вас будет хороший день',
    'serbian': 'Надам се да ћеш имати добар дан',
    'slovak': 'Dúfam, že máte dobrý deň',
    'slovenian': 'Upam, da imate dober dan',
    'spanish': 'Espero que tengas un buen día',
    'swedish': 'Jag hoppas att du får en bra dag',
    'tamil': 'உங்களுக்கு ஒரு நல்ல நாள் இருக்கும் என்று நம்புகிறேன்',
    'telugu': 'మీకు మంచి రోజు ఉందని నేను ఆశిస్తున్నాను',
    'thai': 'ฉันหวังว่าคุณจะมีวันที่ดี',
    'turkish': 'Umarım iyi günler geçirirsin',
    'ukrainian': 'Сподіваюся, у вас хороший день',
    'urdu': 'مجھے امید ہے کہ آپ کا دن اچھا گزرے گا',
    'uzbek': 'Umid qilamanki, sizda yaxshi kun bo\'lsin',
    'vietnamese': 'Tôi hy vọng bạn có một ngày tốt lành',
    'welsh': 'Gobeithio y cewch ddiwrnod da',
  };

  final _player = AudioPlayer();
  final _localeName = Platform.localeName;
  final _languagesInOrder = [];
  final _languageSubtitles = HashMap();
  var _languageIndex = 0;
  var _isPlaying = false; // doesn't start until pressed
  var _subtitles = ''; // no subtitles until started

  _MyHomePageState() {
    // Use actual (when allowed) or random location to populate the list
    // of languages, nearest to farthest.
    _getLocation().then((location) => _prepareLanguagesInOrder(location));

    // Populate hashmap of subtitles for quick lookup
    _languageSubtitles.addAll(translations);

    // When one language audio file completes, play the next (or end)
    _player.onPlayerComplete.listen((event) {
      setState(() {
        _subtitles = '';
      });
      _languageIndex++; // advance to next audio file only when one completes
      _playNextAudio(); // until last audio
    });
  }

  // Request user for device location then return device location if allowed,
  // otherwise return a random location.
  // From sample code found at 'https://pub.dev/packages/geolocator'
  Future<_Coordinate> _getLocation() async {
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
    return _Coordinate(position.latitude, position.longitude);
  }

  _Coordinate _getRandomCoordinate() {
    // Generate a random location
    Random random = Random();
    var randomLatitude = random.nextDouble() * 180 - 90;
    var randomLongitude = random.nextDouble() * 180 - 90;

    return _Coordinate(randomLatitude, randomLongitude);
  }

  void _prepareLanguagesInOrder(_Coordinate location) {
    // debug
    print(location.latitude);
    print(location.longitude);

    // add the distance to each capital and the languages spoken there
    var nearestLanguages = PriorityQueue<_DistanceToLanguages>();

    coordinateToLanguages.forEach((curCoord, languages) {
      var distance = Geolocator.distanceBetween(location.latitude,
          location.longitude, curCoord.latitude, curCoord.longitude);

      nearestLanguages.add(_DistanceToLanguages(distance, languages));
    });

    // --- add languages ---
    // first language is system language when supported
    String languageCode;
    if (_localeName == 'pt_BR') {
      // special case for 'portuguese_brazil'
      languageCode = _localeName;
    } else {
      languageCode = _localeName.split('_')[0]; // in the form e.g.: 'en_US'
    }

    // unsupported language names ignored and nearest language is used first
    var languageName = languageCodeToName[languageCode];
    if (languageName != null) {
      _languagesInOrder.add(languageName);
    }

    // Add nearest languages first (no duplicates)
    while (nearestLanguages.isNotEmpty) {
      // debug
      var distToLangs = nearestLanguages.removeFirst();
      var curLanguages = distToLangs.languages;
      // var curLanguages = nearestLanguages.removeFirst().languages;

      for (var language in curLanguages) {
        if (!_languagesInOrder.contains(language)) {
          _languagesInOrder.add(language);
          print('${distToLangs.distance}: $language'); // debug
        }
      }
    }
  }

  void _playNextAudio() async {
    // play next audio file unless none left to play
    if (_languageIndex < _languagesInOrder.length) {
      print(_languagesInOrder[_languageIndex]);

      // Add a delay between audio files
      if (_languageIndex > 0) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Handle when the user pressed the button during the delay
      if (_isPlaying) {
        var language = _languagesInOrder[_languageIndex];
        await _player.play(AssetSource('$language.mp3'));

        // Handle when the user pressed the button while the asset was loading
        if (_isPlaying) {
          setState(() {
            _subtitles = _languageSubtitles[language];
          });
        } else {
          _stopAndClear();
        }
      }
    } else {
      _isPlaying = false;
    }
  }

  void _stopAndClear() {
    _player.stop();
    setState(() {
      _subtitles = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Center(
            child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            // Average color of Earth (as seen from a satellite)
            // src: https://www.jeffreythompson.org/blog/2014/08/13/average-color-of-the-earth/
            backgroundColor: const Color.fromARGB(255, 23, 57, 61),
            fixedSize: _calcButtonSize(),
          ),
          onPressed: () {
            if (_isPlaying) {
              _isPlaying = false;
              _stopAndClear();
            } else {
              _isPlaying = true;
              _languageIndex = 0; // start at the beginning
              _playNextAudio();
            }
          },
          child: const Text(''), // no text, only button
        )),
        Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(_calcSubtitlePadding()),
              child: Text(
                _subtitles,
                style: TextStyle(
                  color: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 32, 32, 32),
                  fontSize: _calcSubtitleFontSize(),
                ),
              ),
            ))
      ]),
    );
  }

  double _calcSubtitlePadding() {
    var screenHeight = MediaQuery.of(context).size.height;

    return screenHeight / 16.667;
  }

  double _calcSubtitleFontSize() {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return min(screenHeight, screenWidth) / 20;
  }

  // Return a Size with same width and height equal to the min of the screen
  // width and height divided by the golden ratio.
  Size _calcButtonSize() {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    var diameter =
        min(screenHeight, screenWidth) / 1.6180339887; // golden ratio
    return Size(diameter, diameter);
  }
}

// Geographic coordinate for positions on Earth
class _Coordinate {
  // both in decimal degrees
  final double latitude;
  final double longitude;

  const _Coordinate(this.latitude, this.longitude);
}

class _DistanceToLanguages implements Comparable<_DistanceToLanguages> {
  final double distance;
  final List<String> languages;

  const _DistanceToLanguages(this.distance, this.languages);

  @override
  int compareTo(_DistanceToLanguages other) {
    return distance.compareTo(other.distance);
  }
}
