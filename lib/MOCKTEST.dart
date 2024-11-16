import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mock24x7/Ads.dart';
import 'package:mock24x7/MockModel.dart';
import 'package:mock24x7/MockModelManager.dart';
import 'package:mock24x7/TestWork.dart';

class QuizScreen extends StatefulWidget {
  final Mockmodel _mockmodel;
  const QuizScreen(this._mockmodel, {super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  int currentQuestion = 0;
  Map<int, int?> answers = {}; // Store user's answers
  late Stopwatch timer;
  var countdownTimer;
  late Duration remainingTime; // Set 10 minutes timer
  bool quizEnded = false;
  bool quizSubmitted = false;
  Icon flot_icon = const Icon(Icons.check);
  final FocusNode _focusNode = FocusNode();
  var submitText = "SUBMIT";
  String CurrentExplain = "";
  bool CurrentExplain_isload = false;
  TabController? tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    if (widget._mockmodel.IsTimer) {
      remainingTime = Duration(minutes: widget._mockmodel.Timer_Time);
      startTimer();
    } else {
      remainingTime = Duration.zero;
    }
  }

  // Start the 10 minutes countdown
  void startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime.inSeconds > 0) {
        setState(() {
          remainingTime -= const Duration(seconds: 1);
        });
      } else {
        endQuiz();
      }
    });
  }

  void endQuiz() {
    setState(() {
      quizEnded = true;
    });
    countdownTimer.cancel();
    _showEndQuizOptions();
  }

  // Show options when time is up
  void _showEndQuizOptions() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Time Up!'),
        content:
            const Text('You have run out of time. What do you want to do?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (quizEnded || answers.length == widget._mockmodel.QNA.length) {
                int score = 0;
                answers.forEach((index, answer) {
                  if (widget._mockmodel.QNA[index]["Options"]
                          .indexOf(widget._mockmodel.QNA[index]['Answer']) ==
                      answer) {
                    score++;
                  }
                });
                _checkAnswers(score, widget._mockmodel.QNA.length);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please answer all questions!')),
                );
              }
            },
            child: const Text('Submit'),
          ),
          TextButton(
            onPressed: () {
              _restart();
              Navigator.pop(context);
            },
            child: const Text('Restart Test'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // _showExitConfirmationDialog(context);
            },
            child: const Text('close'),
          ),
        ],
      ),
    );
  }

  void _restart() {
    setState(() {
      // Reset everything for a new attempt
      currentQuestion = 0;
      tabController!.index = 0;
      CurrentExplain = "";
      answers.clear();
      quizEnded = false;
      flot_icon = const Icon(Icons.check);
      submitText = "SUBMIT";
      quizSubmitted = false;
      if (widget._mockmodel.IsTimer) {
        remainingTime = Duration(minutes: widget._mockmodel.Timer_Time);
        startTimer();
      } else {
        remainingTime = Duration.zero;
      }
    });
  }

  // Check all answers
  void _checkAnswers(int rightans, int totalmcq) async {
    // await Ads.show_Interstitial_Ads();
    CoolAlert.show(
        context: context,
        type: CoolAlertType.confirm,
        text: 'Are you sure to submit?',
        confirmBtnText: 'Yes',
        cancelBtnText: 'No',
        width: 400.0,
        confirmBtnColor: Colors.green,
        onConfirmBtnTap: () async {

          setState(() {
            quizSubmitted = true;
            submitText = "RESET";
            flot_icon = const Icon(Icons.restart_alt_outlined);
          });
          var title = "Good Job!";
          var icos = CoolAlertType.success;
          widget._mockmodel.setLastDateAttempt = DateTime.now();
          widget._mockmodel.setNumCorrectMCQ = rightans;
          widget._mockmodel.setNumIncorrectMCQ = totalmcq - rightans;
          await MockModelManager.updateMockModel(widget._mockmodel);

          if (((rightans / totalmcq) * 100).toInt() < 85) {
            title = "Keep Trying!";
            icos = CoolAlertType.info;
          }

          if (((rightans / totalmcq) * 100).toInt() < 40) {
            title = "Don't Give Up!";
            icos = CoolAlertType.warning;
          }

          CoolAlert.show(
              title: title,
              confirmBtnText: "View Answer",
              cancelBtnText: "Back",
              showCancelBtn: true,
              context: context,
              width: 400.0,
              animType: CoolAlertAnimType.slideInDown,
              type: icos,
              text: "$rightans right answer out of $totalmcq.",
              confirmBtnColor: const Color.fromARGB(255, 31, 77, 216),
              onCancelBtnTap: () {
                Navigator.pop(context);
              });

          if (widget._mockmodel.IsTimer) {
            countdownTimer.cancel();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance.addPostFrameCallback((x) async {
    //   // await Ads.Load_Interstitial_Ads();
    // });
    void showExitConfirmationDialog() async {
      CoolAlert.show(
          context: context,
          width: 400.0,
          type: CoolAlertType.confirm,
          text: 'Are you really want to exit test?',
          confirmBtnText: 'Yes',
          cancelBtnText: 'No',
          confirmBtnColor: Colors.blueAccent,
          onConfirmBtnTap: () async {
            // await Ads.show_Interstitial_Ads();

            Navigator.pop(context);
          });
    }

    final List<Map<String, dynamic>> questions = widget._mockmodel.QNA;

    // Method to select a question based on number pressed
    void selectQuestionByNumber(int number) {
      if (questions[currentQuestion]["Options"].length >= number) {
        setState(() {
          answers[currentQuestion] = number - 1;
          tabController!.index = 0;
          CurrentExplain = "";
        });
      }
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          // Add your custom back button logic here
          showExitConfirmationDialog();
        },
        child: Scaffold(
          drawer: Drawer(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                ),
                Text(
                  "Questions",
                  style: TextStyle(fontSize: 24),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: (screenWidth > 600)
                          ? 5
                          : 3, // Adjust grid based on screen size
                      childAspectRatio: 2,
                    ),
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      bool attempted = answers.containsKey(index);
                      bool isCorrect = quizSubmitted &&
                          answers[index] ==
                              questions[index]['Options']
                                  .indexOf(questions[index]['Answer']);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            currentQuestion = index;
                            tabController!.index = 0;
                            CurrentExplain = "";
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: EdgeInsets.all(screenWidth > 600 ? 2 : 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: quizSubmitted
                                  ? (isCorrect ? Colors.green : Colors.red)
                                  : (attempted ? Colors.blue : Colors.grey),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Q${index + 1}',
                              style: TextStyle(
                                  fontSize: screenWidth > 600 ? 16 : 12),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          )),
          appBar: AppBar(
            actions: [
              ElevatedButton(
                  onPressed: quizSubmitted
                      ? () {
                          _restart();
                        }
                      : () {
                          int score = 0;
                          answers.forEach((index, answer) {
                            if (questions[index]["Options"]
                                    .indexOf(questions[index]['Answer']) ==
                                answer) {
                              score++;
                            }
                          });
                          _checkAnswers(score, questions.length);
                        },
                  child: Text(
                    submitText,
                    style: TextStyle(color: Colors.greenAccent.shade400),
                  ))
            ],
            leading: Builder(
              builder: (context) {
                return Row(children: [
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  )
                ]);
              },
            ),
            // leading: IconButton(
            //     icon: const Icon(Icons.arrow_back),
            //     onPressed: () async {
            //       // Handle back button in the app bar
            //       showExitConfirmationDialog();
            //     }),
            title: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(widget._mockmodel.Topic),
            ),
          ),
          body: Focus(
            focusNode: _focusNode,
            autofocus: true,
            onKey: (FocusNode node, RawKeyEvent event) {
              if (event is RawKeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                  if (currentQuestion < questions.length - 1 && !quizEnded) {
                    setState(() {
                      currentQuestion++;
                    });
                  }
                } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                  if (currentQuestion > 0 && !quizEnded) {
                    setState(() {
                      currentQuestion--;
                    });
                  }
                } else if (event.logicalKey == LogicalKeyboardKey.enter) {
                  if (!quizSubmitted) {
                    if (quizEnded || answers.length == questions.length) {
                      int score = 0;
                      answers.forEach((index, answer) {
                        if (questions[index]["Options"]
                                .indexOf(questions[index]['Answer']) ==
                            answer) {
                          score++;
                        }
                      });
                      _checkAnswers(score, questions.length);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please answer all questions!')),
                      );
                    }
                  }
                } else if (event.logicalKey == LogicalKeyboardKey.digit1 ||
                    event.logicalKey == LogicalKeyboardKey.numpad1) {
                  selectQuestionByNumber(1);
                } else if (event.logicalKey == LogicalKeyboardKey.digit2 ||
                    event.logicalKey == LogicalKeyboardKey.numpad2) {
                  selectQuestionByNumber(2);
                } else if (event.logicalKey == LogicalKeyboardKey.digit3 ||
                    event.logicalKey == LogicalKeyboardKey.numpad3) {
                  selectQuestionByNumber(3);
                } else if (event.logicalKey == LogicalKeyboardKey.digit4 ||
                    event.logicalKey == LogicalKeyboardKey.numpad4) {
                  selectQuestionByNumber(4);
                } else if (event.logicalKey == LogicalKeyboardKey.digit5 ||
                    event.logicalKey == LogicalKeyboardKey.numpad5) {
                  selectQuestionByNumber(5);
                } else if (event.logicalKey == LogicalKeyboardKey.digit6 ||
                    event.logicalKey == LogicalKeyboardKey.numpad6) {
                  selectQuestionByNumber(6);
                } else if (event.logicalKey == LogicalKeyboardKey.digit7 ||
                    event.logicalKey == LogicalKeyboardKey.numpad7) {
                  selectQuestionByNumber(7);
                } else if (event.logicalKey == LogicalKeyboardKey.digit8 ||
                    event.logicalKey == LogicalKeyboardKey.numpad8) {
                  selectQuestionByNumber(8);
                } else if (event.logicalKey == LogicalKeyboardKey.digit9 ||
                    event.logicalKey == LogicalKeyboardKey.numpad9) {
                  selectQuestionByNumber(9);
                }
              }
              return KeyEventResult.handled;
            },
            child: Row(children: [
              // Left Side: Questions and Options
              Expanded(
                  flex: 8,
                  child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
                      child: Column(
                        children: [
                          (widget._mockmodel.IsTimer)
                              ? Padding(
                                  padding: EdgeInsets.all(screenWidth * 0.03),
                                  child: Center(
                                    child: Text(
                                      'Time Left: ${remainingTime.inMinutes}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                          fontSize: screenWidth > 600 ? 22 : 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )
                              : Center(),
                          Container(
                            width: screenWidth > 600 ? 200 : 220,
                            height: 40,
                            child: TabBar(
                              labelColor: Colors.white,
                              indicatorColor: Colors.transparent,
                              indicator: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  color: Colors.purple.shade500),
                              tabs: const [
                                Tab(
                                  text: "Question",
                                ),
                                Tab(
                                  text: "Explanation",
                                ),
                              ],
                              controller: tabController,
                              indicatorSize: TabBarIndicatorSize.tab,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          Expanded(
                            child: TabBarView(
                              controller: tabController,
                              children: [
                                Center(
                                    child: Column(
                                  children: [
                                    Text(
                                      "Q${currentQuestion + 1}. " +
                                          questions[currentQuestion]
                                              ['Question'],
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              screenWidth > 600 ? 22 : 15),
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: questions[currentQuestion]
                                                ['Options']
                                            .length,
                                        itemBuilder: (context, index) {
                                          bool isCorrect =
                                              questions[currentQuestion]
                                                      ['Answer'] ==
                                                  questions[currentQuestion]
                                                      ['Options'][index];
                                          bool isSelected =
                                              answers[currentQuestion] == index;
                                          return RadioListTile<int>(
                                            title: Text(
                                              questions[currentQuestion]
                                                  ['Options'][index],
                                              style: TextStyle(
                                                  fontSize: screenWidth > 600
                                                      ? 20
                                                      : 15),
                                            ),
                                            value: index,
                                            groupValue:
                                                answers[currentQuestion],
                                            onChanged:
                                                quizEnded || quizSubmitted
                                                    ? null
                                                    : (val) {
                                                        setState(() {
                                                          answers[currentQuestion] =
                                                              val!;
                                                        });
                                                      },
                                            tileColor: quizSubmitted &&
                                                    isCorrect
                                                ? Colors.green.withOpacity(0.3)
                                                : null,
                                          );
                                        },
                                      ),
                                    )
                                  ],
                                )),
                                Center(
                                  child: (CurrentExplain.isEmpty)
                                      ? (CurrentExplain_isload)
                                          ? CircularProgressIndicator()
                                          : ElevatedButton(
                                              onPressed:
                                                  (quizSubmitted || quizEnded)
                                                      ? () async {
                                                          if (!await Testwork
                                                              .Has_Internet(
                                                                  context)) {
                                                            return;
                                                          }
                                                          setState(() {
                                                            CurrentExplain_isload =
                                                                true;
                                                          });
                                                          var temp = await Testwork().Explain_A_Question(
                                                              questions[
                                                                      currentQuestion]
                                                                  ['Question'],
                                                              questions[
                                                                      currentQuestion]
                                                                  ['Answer'],
                                                              questions[currentQuestion]
                                                                      [
                                                                      'Options']
                                                                  .toString());
                                                          CurrentExplain =
                                                              "Explanation: \n";
                                                          setState(() {
                                                            try {
                                                              if (temp !=
                                                                  false) {
                                                                CurrentExplain += temp
                                                                    .toString()
                                                                    .replaceAll(
                                                                        "**",
                                                                        "");
                                                              } else {
                                                                CurrentExplain =
                                                                    "Can't fetch explanation for this time.";
                                                              }
                                                            } catch (error) {
                                                              CurrentExplain =
                                                                  "Can't fetch explanation for this time.";
                                                            }
                                                            CurrentExplain_isload =
                                                                false;
                                                          });
                                                        }
                                                      : null,
                                              child: Text("View explanation"))
                                      : SingleChildScrollView(
                                          child: Text(
                                            CurrentExplain,
                                            textAlign: TextAlign.justify,
                                            style: TextStyle(
                                                fontSize: screenWidth > 600
                                                    ? 22
                                                    : 15),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: currentQuestion > 0
                                    ? () {
                                        setState(() {
                                          currentQuestion--;
                                          tabController!.index = 0;
                                          CurrentExplain = "";
                                        });
                                      }
                                    : null,
                                child: Text('Previous',
                                    style: TextStyle(
                                        fontSize: screenWidth > 600 ? 20 : 15)),
                              ),
                              ElevatedButton(
                                onPressed:
                                    currentQuestion < questions.length - 1
                                        ? () {
                                            setState(() {
                                              currentQuestion++;
                                              tabController!.index = 0;
                                              CurrentExplain = "";
                                            });
                                          }
                                        : null,
                                child: Text('Next',
                                    style: TextStyle(
                                        fontSize: screenWidth > 600 ? 20 : 15)),
                              ),
                            ],
                          ),
                          // Expanded(
                          //   flex: 8,
                          //   child: Padding(
                          //     padding: EdgeInsets.symmetric(
                          //         horizontal: 15.0, vertical: 4.0),
                          //     child: Column(
                          //       crossAxisAlignment: CrossAxisAlignment.center,
                          //       children: [
                          //         (widget._mockmodel.IsTimer)
                          //             ? Padding(
                          //                 padding: EdgeInsets.all(
                          //                     screenWidth * 0.07),
                          //                 child: Center(
                          //                   child: Text(
                          //                     'Time Left: ${remainingTime.inMinutes}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                          //                     style: TextStyle(
                          //                         fontSize: screenWidth > 600
                          //                             ? 22
                          //                             : 20,
                          //                         fontWeight: FontWeight.bold),
                          //                   ),
                          //                 ),
                          //               )
                          //             : Center(),
                          //         // SizedBox(height: screenHeight * 0.03),
                          //         // Text(
                          //         //   "Q${currentQuestion + 1}. " +
                          //         //       questions[currentQuestion]['Question'],
                          //         //   textAlign: TextAlign.justify,
                          //         //   style: TextStyle(
                          //         //       fontSize: screenWidth > 600 ? 22 : 15),
                          //         // ),
                          //         // SizedBox(height: screenHeight * 0.02),
                          //  ,

                          //         // Ads.Show_Banner_Ads(),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                        ],
                      )))
            ]),
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    if (widget._mockmodel.IsTimer) {
      countdownTimer.cancel();
    }
  }
}
