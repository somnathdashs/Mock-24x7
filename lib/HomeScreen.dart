import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'dart:isolate'; // For isolate

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mock24x7/AddTODB/addtodb.dart';
import 'package:mock24x7/Ads.dart';
import 'package:mock24x7/GiminiApi/Api_set_Screen.dart';
import 'package:mock24x7/History.dart';
import 'package:mock24x7/MockInfo.dart';
import 'package:mock24x7/MockModel.dart';
import 'package:mock24x7/MockModelManager.dart';
import 'package:mock24x7/TestWork.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class MyHomePage extends StatelessWidget {
  final VoidCallback toggleTheme;
  final mockModelList;

  MyHomePage({super.key, required this.toggleTheme, required this.mockModelList});
  final TextEditingController topicController = TextEditingController();
  final TextEditingController difficultyController = TextEditingController();
  int selectedNumber = 15;

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    void generateButtonPressed() async {
      String topic = topicController.text;
      String difficulty = difficultyController.text;

      if (topic.isEmpty || difficulty.isEmpty || selectedNumber <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all the fields to continue.')),
        );
        return;
      }

      Testwork().showLoadingDialog(context);

      var newmockmodel =
          await Testwork().GenerateMock(topic, difficulty, selectedNumber);

      Navigator.pop(context);

      if (newmockmodel != null) {
        Ads.show_Interstitial_Ads();
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Mock 24x7', style: GoogleFonts.cabin()),
        actions: [
          IconButton(
            icon: Row(
              children: [
                (Platform.isAndroid || Platform.isIOS)
                    ? GestureDetector(
                        onTap: () async {
                          await FlutterShare.share(
                              title: 'Share Mock 24x7',
                              text:
                                  'A Free AI generated mock test app available 24x7. Download "Mock 24x7" Now --By @somnathdashs (on Github)',
                              linkUrl:
                                  'https://somnathdashs.github.io/apps/mock_24x7',
                              chooserTitle: 'By @somnath_dash1 (x.com)');
                        },
                        child: const Icon(Icons.share),
                      )
                    : const Center(),
                (Platform.isAndroid || Platform.isIOS)
                    ? const SizedBox(
                        width: 35,
                      )
                    : const Center(),
                GestureDetector(
                  onTap: toggleTheme,
                  child: const Icon(Icons.brightness_6),
                ),
                const SizedBox(
                  width: 35,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                HistoryScreen(mockModelList: mockModelList)));
                  },
                  child: const Icon(Icons.history),
                )
              ],
            ),
            onPressed: () {}, // Toggle light/dark mode
          ),
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
                  const SizedBox(height: 40),

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

                  const SizedBox(height: 20),

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
                            const SizedBox(width: 10.0,),
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
                                const SizedBox(
                                    width: 15), // Responsive spacing
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

                  const SizedBox(height: 80),
                  InkWell(
                    onTap: () {
                      Testwork()
                          .openURL("https://buymeacoffee.com/somnathdash");
                      // Action when button is pressed
                    },
                    child: Image.asset(
                      'assetss/buy_coffee.png', // Add your image asset here
                      width: 200,
                    ),
                  ),
                  const SizedBox(height: 50),
                  Ads.Show_Banner_Ads(),
                ],
              ),
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: generateButtonPressed,
        label: const Text('Generate'),
        icon: const Icon(Icons.play_arrow_rounded),
      ),
    );
  }
}
