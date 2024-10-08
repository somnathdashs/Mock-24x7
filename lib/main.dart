import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'dart:isolate'; // For isolate
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mock24x7/AddTODB/addtodb.dart';
import 'package:mock24x7/Ads.dart';
import 'package:mock24x7/GiminiApi/Api_set_Screen.dart';
import 'package:mock24x7/HomeScreen.dart';
import 'package:mock24x7/MockInfo.dart';
import 'package:mock24x7/MockModel.dart';
import 'package:mock24x7/MockModelManager.dart';
import 'package:mock24x7/TestWork.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

var mockModelList = MockModelManager.getMockModels(); // Retrieve saved models

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Ads.Ads_init();
  // MobileAds.instance.initialize();
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
    Ads.Ads_init();
    UploadQNA().uploadMockDatas();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        mockModelList = MockModelManager.getMockModels();
      });
    }
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
        Future.delayed(Duration.zero, () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MyHomePage(
                    toggleTheme: Temporary, mockModelList: mockModelList)),
          );
        });
      } else {
        // Navigate to the Gemini API screen
        Future.delayed(Duration.zero, () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => GeminiAPIScreen(
                    toggleTheme: Temporary, mockModelList: mockModelList)),
          );
        });
      }
    });
    // Temporary widget while condition is being checked
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  Future<bool> checkCondition() async {
    var res = await MockModelManager.get_gimini_key();
    print(res);
    return res.isNotEmpty;
  }
}
