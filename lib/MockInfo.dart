import 'dart:convert';
import 'dart:isolate';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mock24x7/AddTODB/addtodb.dart';
import 'package:mock24x7/MOCKTEST.dart';
import 'package:mock24x7/MockModel.dart';
import 'package:mock24x7/MockModelManager.dart';
import 'package:mock24x7/TestWork.dart';

class SuccessScreen extends StatefulWidget {
  final Mockmodel _mockmodel;
  const SuccessScreen(this._mockmodel);

  @override
  _SuccessScreenState createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  final TextEditingController timerController = TextEditingController();

  final TextEditingController _timerController = TextEditingController();

  // late Future<List<Map<String, dynamic>>> Suggest_List;
  late Future<dynamic> Suggest_List;

  Future fetchData() async {
    String cmdTopicGen =
        Testwork().cmd_related_denerater(widget._mockmodel.Topic, "5");
    print(cmdTopicGen);

    // Return a Future that resolves to the result of the Python shell command
    return Testwork().runPythonShell(cmdTopicGen).then((result) {
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
    Suggest_List = fetchData();
    super.initState();
  }

  void _startTest(int minutes) async {
    if (minutes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
          title: Text("Set Timer"),
          content: TextField(
            controller: _timerController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Enter time in minutes",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
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
              child: Text("Start Test"),
            ),
          ],
        );
      },
    );
  }

  void _New_topic_dialog(Sug_Topic) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Generate Question"),
          content: Container(
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "" + Sug_Topic["Topic"],
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "Level: " + Sug_Topic["Difficulty"],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Number of Question: " + Sug_Topic["Num_Mcq"].toString(),
                      style: TextStyle(
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
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _generateButtonPressed(Sug_Topic["Topic"],
                    Sug_Topic["Difficulty"], Sug_Topic["Num_Mcq"]);
              },
              child: Text("Generate Mock"),
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
        SnackBar(content: Text('Please fill all the fiels to continue.')),
      );
      return;
    }

    // Show loading dialog
    Testwork().showLoadingDialog(context);

    // Call the async function to generate mock and wait for the result
    var _newmockmodel =
        await Testwork().GenerateMock(topic, difficulty, selectedNumber);

    // Close the loading dialog
    Navigator.pop(context);

    if (_newmockmodel != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SuccessScreen(_newmockmodel)),
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
          confirmBtnColor: Color.fromARGB(255, 31, 77, 216));
    }
  }

  @override
  Widget build(BuildContext context) {
    UploadQNA().uploadMockData(widget._mockmodel);

    return Scaffold(
      appBar: AppBar(
        title: Text("'" + widget._mockmodel.Topic + "'" + ' Preview',
            style: GoogleFonts.poppins()),
      ),
      body: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
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
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: Text(
                          "Your test on '" +
                              widget._mockmodel.Topic +
                              "' is ready.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              textStyle: TextStyle(fontSize: 35)),
                        ),
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _showTimerDialog();
                            },
                            child: Text(
                              "Set a Timer",
                              style: GoogleFonts.cabin(
                                textStyle: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              widget._mockmodel.setIsTimer = false;
                              await MockModelManager.updateMockModel(
                                  widget._mockmodel);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        QuizScreen(widget._mockmodel)),
                              );
                            },
                            child: Text(
                              "Start Without Timer",
                              style: GoogleFonts.cabin(
                                textStyle: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              // backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // TextField(
                      //   controller: timerController,
                      //   keyboardType: TextInputType.number,
                      //   decoration: InputDecoration(
                      //     hintText: "Set timer (in minutes)",
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(30.0),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 50),
              FutureBuilder<dynamic>(
                future: Suggest_List,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                        child: Text('No Topic available to suggest.'));
                  }

                  // Data is loaded
                  List<dynamic> data = snapshot.data!;

                  return Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Column(
                      children: [
                        Text(
                          "Related Topics",
                          style: TextStyle(
                              fontSize: 35, fontWeight: FontWeight.bold),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(
                              data.length,
                              (index) => _buildCard(data[index]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          )),
    );
  }

  // Card design for each item
  Widget _buildCard(item) {
    return GestureDetector(
      onTap: () {
        _New_topic_dialog(item);
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        elevation: 4,
        child: Container(
          width: 400,
          padding: EdgeInsets.all(35.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item["Topic"],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "Level: " + item["Difficulty"],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "Number of Question: " + item["Num_Mcq"].toString(),
                    style: TextStyle(
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
      ),
    );
  }
}
