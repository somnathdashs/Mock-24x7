import 'dart:convert';
import 'dart:isolate';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mock24x7/AddTODB/addtodb.dart';
import 'package:mock24x7/Ads.dart';
import 'package:mock24x7/MOCKTEST.dart';
import 'package:mock24x7/MockModel.dart';
import 'package:mock24x7/MockModelManager.dart';
import 'package:mock24x7/TestWork.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class SuccessScreen extends StatefulWidget {
  final Mockmodel _mockmodel;
  const SuccessScreen(this._mockmodel, {super.key});

  @override
  _SuccessScreenState createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  final TextEditingController timerController = TextEditingController();

  final TextEditingController _timerController = TextEditingController();

  var Suggest_List;

  bool Has_suggestion_pressed = false;

  Future fetchData() async {
    String cmdTopicGen =
        Testwork().cmd_related_denerater(widget._mockmodel.Topic, "5");

    // Return a Future that resolves to the result of the Python shell command
    return Testwork().Ask_Gemini(cmdTopicGen).then((result) {
      // If result is null, return an empty list
      return (result.isNotEmpty) ? jsonDecode(result) : [];
    }).catchError((error) {
      // Handle any errors that occur and return an empty list in case of error
      print('Error fetching data: $error');
      return [];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    // Suggest_List = Future.value(widget._mockmodel.SuggestTopic);
    super.initState();
  }

  void _startTest(int minutes) async {
    if (minutes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Enter a valid time in integer formate and greater than "0"'),
        ),
      );
      _showTimerDialog();
    } else {
      widget._mockmodel.setIsTimer = true;
      widget._mockmodel.setTimerTime = minutes;

      await MockModelManager.updateMockModel(widget._mockmodel);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QuizScreen(widget._mockmodel)),
      );
    }
  }

  void _showTimerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Set Timer"),
          content: TextField(
            controller: _timerController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Enter time in minutes",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                String timerValue = _timerController.text;
                if (timerValue.isNotEmpty) {
                  int minutes = int.tryParse(timerValue) ?? 0;
                  Navigator.of(context).pop();
                  _startTest(minutes);
                }
              },
              child: const Text("Start Test"),
            ),
          ],
        );
      },
    );
  }

  void _New_topic_dialog(sugTopic) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Generate Question"),
          content: SizedBox(
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "" + sugTopic["Topic"],
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "Level: " + sugTopic["Difficulty"],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Number of Question: " + sugTopic["Num_Mcq"].toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _generateButtonPressed(sugTopic["Topic"],
                    sugTopic["Difficulty"], sugTopic["Num_Mcq"]);
              },
              child: const Text("Generate Mock"),
            ),
          ],
        );
      },
    );
  }

  void _generateButtonPressed(topic, difficulty, selectedNumber) async {
    if (topic == null ||
        topic == '' ||
        difficulty == null ||
        difficulty == "" ||
        selectedNumber <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the fiels to continue.')),
      );
      return;
    }

    // Show loading dialog
    Testwork().showLoadingDialog(context);

    // Call the async function to generate mock and wait for the result
    var newmockmodel =
        await Testwork().GenerateMock(topic, difficulty, selectedNumber);

    // Close the loading dialog
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
              "Some Problem occurs while generating mock. Try Again\n\nTips: Sometime it occurs due to max questions.So, try to generate less question from maximum question.",
          confirmBtnColor: const Color.fromARGB(255, 31, 77, 216));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get screen size
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("'" + widget._mockmodel.Topic + "'" + ' Preview',
            style: GoogleFonts.poppins()),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Text(
                            "Your test on '${widget._mockmodel.Topic}' is ready.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: screenWidth > 600
                                    ? 30
                                    : 20, // Responsive font size
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Flexible(
                              child: ElevatedButton(
                                onPressed: () {
                                  _showTimerDialog();
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                child: Text(
                                  "Set a Timer",
                                  style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                      fontSize: screenWidth > 600
                                          ? 20
                                          : 15, // Responsive font size
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: ElevatedButton(
                                onPressed: () async {
                                  widget._mockmodel.setIsTimer = false;
                                  await MockModelManager.updateMockModel(
                                      widget._mockmodel);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          QuizScreen(widget._mockmodel),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                child: Text(
                                  "Start Without Timer",
                                  style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                      fontSize: screenWidth > 600
                                          ? 20
                                          : 15, // Responsive font size
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Has_suggestion_pressed
                    ? const SizedBox.shrink()
                    : ElevatedButton(
                        onPressed: () {
                          setState(() {
                            Suggest_List = fetchData();
                            Has_suggestion_pressed = true;
                          });
                        },
                        child: const Text("Related Topics")),
                Ads.Show_Banner_Ads(),
                const SizedBox(height: 50),
                FutureBuilder<dynamic>(
                  future: Suggest_List,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('No Topic available to suggest.'));
                    }

                    // Data is loaded
                    List<dynamic> data = snapshot.data!;

                    return Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Column(
                        children: [
                          Text(
                            "Related Topics",
                            style: TextStyle(
                              fontSize: screenWidth > 600
                                  ? 35
                                  : 25, // Responsive font size
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(
                                data.length,
                                (index) => _buildCard(data[index], screenWidth),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Ads.Show_Banner_Ads(),
              ],
            ),
          )),
    );
  }

// Card design for each item
  Widget _buildCard(item, double screenWidth) {
    return GestureDetector(
      onTap: () {
        _New_topic_dialog(item);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        elevation: 4,
        child: Container(
          width: screenWidth > 600 ? 400 : 300, // Responsive card width
          padding: EdgeInsets.all(
              screenWidth > 600 ? 35.0 : 20.0), // Responsive padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item["Topic"],
                style: TextStyle(
                  fontSize: screenWidth > 600 ? 20 : 16, // Responsive font size
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "Level: " + item["Difficulty"],
                    style: TextStyle(
                      fontSize:
                          screenWidth > 600 ? 16 : 14, // Responsive font size
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "Number of Questions: ${item["Num_Mcq"]}",
                    style: TextStyle(
                      fontSize:
                          screenWidth > 600 ? 16 : 14, // Responsive font size
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}