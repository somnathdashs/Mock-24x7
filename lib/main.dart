// import 'package:google_mobile_ads/google_mobile_ads.dart';
// For isolate
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mock24x7/Ads.dart';
import 'package:mock24x7/GiminiApi/Api_set_Screen.dart';
import 'package:mock24x7/History.dart';
import 'package:mock24x7/HomeScreen.dart';
import 'package:mock24x7/IntroScreen.dart';
import 'package:mock24x7/MockModelManager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  ThemeMode _themeMode = ThemeMode.system;
  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mock 24x7',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.cabinTextTheme(
          Theme.of(context).textTheme,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.blue[50],
          hintStyle: TextStyle(color: Colors.grey[700], fontSize: 16),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.yellow,
        scaffoldBackgroundColor: Colors.grey[900],
        textTheme: GoogleFonts.cabinTextTheme(
          Theme.of(context).textTheme.apply(bodyColor: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[800],
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      themeMode: _themeMode, // Current theme mode based on state
      home: InitialScreen(
        Temporary: _toggleTheme,
      ),
    );
  }
}

// Initial screen with condition check
class InitialScreen extends StatelessWidget {
  final VoidCallback Temporary;

  const InitialScreen({super.key, required this.Temporary});

  @override
  Widget build(BuildContext context) {
    // Example condition, you can replace this with an actual API check or logic
    checkCondition().then((condition) {
      if (condition) {

        // Navigate to the next screen
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MyHomePage(toggleTheme: Temporary)),
          );
        });
      } else {
        // Navigate to the Gemini API screen
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    Intro_Video_Screen(toggleTheme: Temporary)),
          );
        });
      }
    });
    // Temporary widget while condition is being checked
    return Scaffold(
      body: Center(
          child: ClipRRect(
              borderRadius: BorderRadius.circular(150),
              child: Image.asset(
                "assetss/MOCK.jpg",
                width: 200,
              ))),
    );
  }

  Future<bool> checkCondition() async {
    var res = await MockModelManager.get_gimini_key();
    print(res);
    return res.isNotEmpty;
  }
}
