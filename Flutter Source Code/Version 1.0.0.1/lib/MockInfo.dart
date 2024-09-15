import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mock24x7/MOCKTEST.dart';
import 'package:mock24x7/MockModel.dart';
import 'package:mock24x7/MockModelManager.dart';

class SuccessScreen extends StatefulWidget {
  final Mockmodel _mockmodel;
  const SuccessScreen(this._mockmodel);

  @override
  _SuccessScreenState createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  final TextEditingController timerController = TextEditingController();

  final TextEditingController _timerController = TextEditingController();

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

    // // Here you can add the logic for starting the test with the timer.
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text('Test started with a $minutes-minute timer'),
    //   ),
    // );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("'" + widget._mockmodel.Topic + "'" + ' Preview',
            style: GoogleFonts.poppins()),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Your test on '" + widget._mockmodel.Topic + "' is ready",
                style: GoogleFonts.poppins(textStyle: TextStyle(fontSize: 40)),
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
                      await MockModelManager.updateMockModel(widget._mockmodel);
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
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
