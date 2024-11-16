import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mock24x7/Ads.dart';
import 'package:mock24x7/MockModel.dart';
import 'package:mock24x7/MockModelManager.dart';
import 'package:mock24x7/TestWork.dart';

class QuizScreen_NoTimer extends StatefulWidget {
  final Mockmodel _mockmodel;
  const QuizScreen_NoTimer(this._mockmodel, {super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen_NoTimer>
    with SingleTickerProviderStateMixin {
  int currentQuestion = 0;
  Map<int, int?> answers = {}; // Store user's answers
  Map<int, int?> submitted_questions = {}; // Store user's answers
  bool quizEnded = false;
  bool quizSubmitted = false;
  Icon flot_icon = const Icon(Icons.check);
  final FocusNode _focusNode = FocusNode();
  var submitText = "SUBMIT";
  int Score = 0;
  // String Score_Board
  String CurrentExplain = "";
  bool CurrentExplain_isload = false;
  TabController? tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
   
  }

  void endQuiz() {
    setState(() {
      quizEnded = true;
    });
  }

  void _restart() {
    setState(() {
      // Reset everything for a new attempt
      currentQuestion = 0;
      Score = 0;
      tabController!.index = 0;
      CurrentExplain = "";
      answers.clear();
      quizEnded = false;
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
                      bool isCorrect = answers[index] ==
                          questions[index]['Options']
                              .indexOf(questions[index]['Answer']);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            currentQuestion = index;
                            CurrentExplain = "";
                            tabController!.index = 0;
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: EdgeInsets.all(screenWidth > 600 ? 2 : 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: attempted
                                  ? (isCorrect ? Colors.green : Colors.red)
                                  : Colors.grey,
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  "SCORE: " +
                      Score.toString() +
                      " of " +
                      questions.length.toString(),
                  style: TextStyle(color: Colors.greenAccent.shade400),
                ),
              )
            ],
            leading: Builder(
              builder: (context) {
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    )
                  ],
                );
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
              child: Text(widget._mockmodel.Topic.toUpperCase()),
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
            child: Row(
              children: [
                // Left Side: Questions and Options
                Expanded(
                  flex: 8,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: screenHeight * 0.02),
                        Container(
                          width: screenWidth > 600 ? 200 : 220,
                          height: 40,
                          child: TabBar(
                            labelColor: Colors.white,
                            indicatorColor: Colors.transparent,
                            indicator: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
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
                                        questions[currentQuestion]['Question'],
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenWidth > 600 ? 22 : 15),
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
                                            answers[currentQuestion] != null;
                                        // print(answers[index]);
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
                                          groupValue: answers[currentQuestion],
                                          onChanged: answers[currentQuestion] !=
                                                  null
                                              ? null
                                              : (val) {
                                                  setState(() {
                                                    answers[currentQuestion] =
                                                        val!;
                                                    if (isCorrect) {
                                                      Score++;
                                                    }
                                                    if (answers.length ==
                                                        questions.length) {
                                                      var title = "Good Job!";
                                                      var icos =
                                                          CoolAlertType.success;
                                                      widget._mockmodel
                                                              .setLastDateAttempt =
                                                          DateTime.now();
                                                      widget._mockmodel
                                                              .setNumCorrectMCQ =
                                                          Score;
                                                      widget._mockmodel
                                                              .setNumIncorrectMCQ =
                                                          questions.length -
                                                              Score;
                                                      MockModelManager
                                                          .updateMockModel(
                                                              widget
                                                                  ._mockmodel);

                                                      if (((Score /
                                                                      questions
                                                                          .length) *
                                                                  100)
                                                              .toInt() <
                                                          85) {
                                                        title = "Keep Trying!";
                                                        icos =
                                                            CoolAlertType.info;
                                                      }

                                                      if (((Score /
                                                                      questions
                                                                          .length) *
                                                                  100)
                                                              .toInt() <
                                                          40) {
                                                        title =
                                                            "Don't Give Up!";
                                                        icos = CoolAlertType
                                                            .warning;
                                                      }

                                                      CoolAlert.show(
                                                          title: title,
                                                          confirmBtnText:
                                                              "Close",
                                                          cancelBtnText:
                                                              "Reset",
                                                          showCancelBtn: true,
                                                          context: context,
                                                          width: 400.0,
                                                          animType:
                                                              CoolAlertAnimType
                                                                  .slideInDown,
                                                          type: icos,
                                                          text:
                                                              "$Score right answer out of ${questions.length}.",
                                                          confirmBtnColor:
                                                              const Color
                                                                  .fromARGB(255,
                                                                  234, 223, 28),
                                                          onCancelBtnTap: () {
                                                            _restart();
                                                          });
                                                    }
                                                  });
                                                },
                                          tileColor: isSelected && isCorrect
                                              ? Colors.green.withOpacity(0.3)
                                              : null,
                                          // hoverColor: Colors.red.withOpacity(0.3),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              )),
                              Center(
                                child: (CurrentExplain.isEmpty)
                                    ? (CurrentExplain_isload)
                                        ? CircularProgressIndicator()
                                        : ElevatedButton(
                                            onPressed: (answers[
                                                        currentQuestion] !=
                                                    null)
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
                                                    var temp = await Testwork()
                                                        .Explain_A_Question(
                                                            questions[
                                                                    currentQuestion]
                                                                ['Question'],
                                                            questions[
                                                                    currentQuestion]
                                                                ['Answer'],
                                                            questions[currentQuestion]
                                                                    ['Options']
                                                                .toString());
                                                    CurrentExplain =
                                                        "Explanation: \n";
                                                    setState(() {
                                                      try {
                                                        if (temp != false) {
                                                          CurrentExplain += temp
                                                              .toString()
                                                              .replaceAll(
                                                                  "**", "");
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
                                              fontSize:
                                                  screenWidth > 600 ? 22 : 15),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),

// BUtton
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              onPressed: currentQuestion > 0
                                  ? () {
                                      setState(() {
                                        currentQuestion--;
                                        CurrentExplain = "";
                                        tabController!.index = 0;
                                      });
                                    }
                                  : null,
                              child: Text('Previous',
                                  style: TextStyle(
                                      fontSize: screenWidth > 600 ? 20 : 15)),
                            ),
                            ElevatedButton(
                              onPressed: currentQuestion < questions.length - 1
                                  ? () {
                                      setState(() {
                                        currentQuestion++;
                                        CurrentExplain = "";
                                        tabController!.index = 0;
                                      });
                                    }
                                  : null,
                              child: Text('Next',
                                  style: TextStyle(
                                      fontSize: screenWidth > 600 ? 20 : 15)),
                            ),
                          ],
                        ),
                        // Ads.Show_Banner_Ads(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
