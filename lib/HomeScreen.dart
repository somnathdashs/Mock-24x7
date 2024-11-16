import 'dart:io';
// For isolate

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mock24x7/Ads.dart';
import 'package:mock24x7/GiminiApi/Api_set_Screen.dart';
import 'package:mock24x7/History.dart';
import 'package:mock24x7/MockInfo.dart';
import 'package:mock24x7/TestWork.dart';

import 'package:share_plus/share_plus.dart';

// class MyHomePage extends StatefulWidget {

class MyHomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  MyHomePage({
    super.key,
    required this.toggleTheme,
  });

  @override
  State<MyHomePage> createState() => _MyHomePage();
}

class _MyHomePage extends State<MyHomePage> {
  final TextEditingController topicController = TextEditingController();
  final TextEditingController difficultyController = TextEditingController();
  int selectedNumber = 15;
  // GoogleAds GADS = GoogleAds();
  bool isbannerload = false;
  late NativeAd nativeAd_Advance;
  bool _isMediumNativeAdLoaded = false;
  bool _uselargebanner = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    void generateButtonPressed() async {
      String topic = topicController.text;
      String difficulty = difficultyController.text;
      if (!await Testwork.Has_Internet(context)) {
        return;
      }

      if (topic.isEmpty || difficulty.isEmpty || selectedNumber <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please fill all the fields to continue.')),
        );
        return;
      }

      Testwork().showLoadingDialog(context);

      var newmockmodel =
          await Testwork().GenerateMock(topic, difficulty, selectedNumber);

      Navigator.pop(context);

      if (newmockmodel != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SuccessScreen(newmockmodel)),
        );
      } else {
        CoolAlert.show(
            title: "Something went wrong!!",
            confirmBtnText: "Ok",
            showCancelBtn: true,
            context: context,
            width: 400.0,
            animType: CoolAlertAnimType.slideInDown,
            type: CoolAlertType.error,
            text:
                "Some Problem occurs while generating mock. Try Again\n\nTips: Sometime it occurs due to max questions. So, try to generate fewer questions from the maximum allowed.",
            confirmBtnColor: const Color.fromARGB(255, 31, 77, 216));
      }
    }

    void handleClick(String value) async {
      switch (value) {
        case 'History':
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => HistoryScreen()));
          break;
        case 'Share':
          if (Platform.isAndroid || Platform.isIOS) {
            final result = await Share.share(
                'A Free AI generated mock test app available 24x7. Download "Mock 24x7" Now: https://somnathdashs.github.io/Mock247/  \n\nJoin whatsapp channel: https://whatsapp.com/channel/0029VaqvgQB77qVKGQJXyj0v \n\n\n--By @somnathdashs (on Github)');
          } else {
            Testwork()
                .openURL("https://somnathdashs.github.io/Mock247/?share=1");
          }
          break;
        case 'Change API':
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GeminiAPIScreen(
                        toggleTheme: widget.toggleTheme,
                        is_saved: true,
                      )));
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mock 24x7', style: GoogleFonts.cabin()),
        actions: [
          IconButton(
            tooltip: "Buy Me a Coffee",
            onPressed: () {
              Testwork().openURL("https://buymeacoffee.com/somnathdash/");
              // Action when button is pressed
            },
            icon: Padding(
              padding: EdgeInsets.all(4),
              child: Image.asset(
                "assetss/BMC.gif",
                height: 105.0,
              ),
            ),
          ),
          IconButton(
            tooltip: "Join Group, Stay Update",
            icon: Icon(Icons.group),
            onPressed: () {
              Testwork().openURL(
                  "https://whatsapp.com/channel/0029VaqvgQB77qVKGQJXyj0v");
            },
          ),
          // const SizedBox(
          //   width: 23,
          // ),
          IconButton(
            tooltip: "Change Themes",
            onPressed: widget.toggleTheme,
            icon: const Icon(Icons.brightness_6),
          ),
          // const SizedBox(
          //   width: 23,
          // ),
          PopupMenuButton<String>(
            // icon: Icon(Icons.threed_rotation),
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              var t = {
                'History',
                'Share',
                "Change API",
              };
              return t.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
          // const SizedBox(
          //     width: 23,
          //   ),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Large App Name
                  Text(
                    "Mock 24x7",
                    style: GoogleFonts.cabin(
                      textStyle:
                          Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),

                  // Text Field for Topic
                  Container(
                    width: constraints.maxWidth * 0.8,
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: topicController,
                      maxLength: 70,
                      decoration: const InputDecoration(
                          hintText: "Write your topic...",
                          hintStyle: TextStyle(fontSize: 18)),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double availableWidth = constraints.maxWidth;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Small Text Bar for Difficulty with max width
                            Container(
                              width: screenWidth > 600 ? 200 : 140,
                              decoration: const BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: difficultyController,
                                maxLength: 20,
                                decoration: const InputDecoration(
                                  hintText: "Difficulty: Class 10, Hard, etc..",
                                ),
                                style: const TextStyle(
                                  fontSize: 15, // Responsive font size
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            // Dropdown for selecting number of questions
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Questions:",
                                  style: GoogleFonts.cabin(
                                    textStyle:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                                const SizedBox(width: 15), // Responsive spacing
                                StatefulBuilder(builder: (context, innerState) {
                                  return DropdownButton<int>(
                                    value: selectedNumber,
                                    dropdownColor: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    items:
                                        List.generate(30, (index) => index + 1)
                                            .map<DropdownMenuItem<int>>(
                                                (int value) {
                                      return DropdownMenuItem<int>(
                                        value: value,
                                        child: Text(
                                          value.toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (int? newValue) {
                                      innerState(() {
                                        selectedNumber = newValue!;
                                      });
                                    },
                                  );
                                }),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      }),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: generateButtonPressed,
      //   label: const Text(
      //     'Generate Mock',
      //     style: TextStyle(
      //         fontSize: 17.0, fontWeight: FontWeight.bold, color: Colors.white),
      //   ),
      //   backgroundColor: const Color.fromARGB(255, 233, 176, 18),
      //   icon: const Icon(
      //     Icons.play_arrow_rounded,
      //     color: Colors.white,
      //     size: 30,
      //   ),
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(10.0),
      //   ),
      // ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 51, 247, 58),
              Color.fromARGB(255, 3, 185, 145)
            ], // Green gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25), // Rounded corners for FAB
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: generateButtonPressed,
          label: const Text(
            "Generate Test",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 3,
                  color: Colors.black45,
                ),
              ],
            ),
          ),
          icon: const Icon(
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3,
                color: Colors.black45,
              ),
            ],
            Icons.auto_fix_high,
            color: Colors.white,
          ),
          backgroundColor: Colors
              .transparent, // Makes background transparent to show gradient
          elevation: 0, // Removes FAB shadow to use custom shadow
        ),
      ),
    );
  }
}
