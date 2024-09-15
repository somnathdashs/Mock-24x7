import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/services.dart';
import 'package:mock24x7/MockModel.dart';
import 'package:mock24x7/MockModelManager.dart';

class QuizScreen extends StatefulWidget {
  final Mockmodel _mockmodel;
  const QuizScreen(this._mockmodel);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestion = 0;
  Map<int, int?> answers = {}; // Store user's answers
  late Stopwatch timer;
  var countdownTimer;
  late Duration remainingTime; // Set 10 minutes timer
  bool quizEnded = false;
  bool quizSubmitted = false;
  Icon flot_icon = Icon(Icons.check);
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget._mockmodel.IsTimer) {
      remainingTime = Duration(minutes: widget._mockmodel.Timer_Time);
      startTimer();
    } else {
      remainingTime = Duration.zero;
    }
  }

  // Start the 10 minutes countdown
  void startTimer() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime.inSeconds > 0) {
        setState(() {
          remainingTime -= Duration(seconds: 1);
        });
      } else {
        endQuiz();
      }
    });
  }

  void endQuiz() {
    setState(() {
      quizEnded = true;
      countdownTimer.cancel();
    });
    // Show options to submit or restart
    _showEndQuizOptions();
  }

  // Show options when time is up
  void _showEndQuizOptions() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Time Up!'),
        content: Text('You have run out of time. What do you want to do?'),
        actions: [
          TextButton(
            onPressed: quizSubmitted
                ? () {
                    _restart();
                  }
                : () {
                    if (quizEnded ||
                        answers.length == widget._mockmodel.QNA.length) {
                      int score = 0;
                      answers.forEach((index, answer) {
                        if (widget._mockmodel.QNA[index]["Options"].indexOf(
                                widget._mockmodel.QNA[index]['Answer']) ==
                            answer) {
                          score++;
                        }
                      });
                      _checkAnswers(score, widget._mockmodel.QNA.length);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please answer all questions!')),
                      );
                    }
                  },
            child: Text('Submit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Go Back'),
          ),
          TextButton(
            onPressed: () {
              _restart();
              Navigator.pop(context);
            },
            child: Text('Restart Test'),
          ),
        ],
      ),
    );
  }

  void _restart() {
    setState(() {
      // Reset everything for a new attempt
      currentQuestion = 0;
      answers.clear();
      quizEnded = false;
      flot_icon = Icon(Icons.check);
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
    setState(() {
      quizSubmitted = true;
      flot_icon = Icon(Icons.restart_alt_outlined);
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
        confirmBtnColor: Color.fromARGB(255, 31, 77, 216),
        onCancelBtnTap: () {
          Navigator.pop(context);
        });

    if (widget._mockmodel.IsTimer) {
      countdownTimer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> questions = widget._mockmodel.QNA;
    // Method to select a question based on number pressed
    void selectQuestionByNumber(int number) {
      if (questions[currentQuestion]["Options"].length >= number) {
        setState(() {
          answers[currentQuestion] = number - 1;
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget._mockmodel.Topic),
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
            } // Handle Number Keys (Digit0 to Digit9)
            else if (event.logicalKey == LogicalKeyboardKey.digit1 ||
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
          return KeyEventResult
              .handled; // Indicate that the key event was handled
        },
        child: Row(
          children: [
            // Left Side: Questions and Options
            Expanded(
              flex: 8,
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 50.0, left: 50.0, right: 50.0, bottom: 150.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Question No: ${currentQuestion + 1}/${questions.length}',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 30),
                    Text(
                      questions[currentQuestion]['Question'],
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: questions[currentQuestion]['Options'].length,
                        itemBuilder: (context, index) {
                          bool isCorrect = questions[currentQuestion]
                                  ['Answer'] ==
                              questions[currentQuestion]['Options'][index];
                          bool isSelected = answers[currentQuestion] == index;
                          return RadioListTile<int>(
                            title: Text(
                              questions[currentQuestion]['Options'][index],
                              style: TextStyle(fontSize: 18),
                            ),
                            value: index,
                            groupValue: answers[currentQuestion],
                            onChanged: quizEnded || quizSubmitted
                                ? null
                                : (val) {
                                    setState(() {
                                      answers[currentQuestion] = val;
                                    });
                                  },
                            // Highlight correct answers in green after submission
                            tileColor: quizSubmitted && isCorrect
                                ? Colors.green.withOpacity(0.3)
                                : null,
                          );
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: currentQuestion > 0 && !quizEnded
                              ? () {
                                  setState(() {
                                    currentQuestion--;
                                  });
                                }
                              : null,
                          child:
                              Text('Previous', style: TextStyle(fontSize: 20)),
                        ),
                        ElevatedButton(
                          onPressed: currentQuestion < questions.length - 1 &&
                                  !quizEnded
                              ? () {
                                  setState(() {
                                    currentQuestion++;
                                  });
                                }
                              : null,
                          child: Text('Next', style: TextStyle(fontSize: 20)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Right Side: Timer and Overview
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  // Timer display
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Center(
                      child: Text(
                        (widget._mockmodel.IsTimer)
                            ? 'Time Left: ${remainingTime.inMinutes}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}'
                            : "No Timer",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  // Overview of questions
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
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
                            if (!quizEnded) {
                              setState(() {
                                currentQuestion = index;
                              });
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: quizSubmitted
                                    ? (isCorrect ? Colors.green : Colors.red)
                                    : (attempted ? Colors.blue : Colors.grey),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text('Q${index + 1}'),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: quizSubmitted
            ? () {
                _restart();
              }
            : () {
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
              },
        child: flot_icon,
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    if (widget._mockmodel.IsTimer) {
      countdownTimer.cancel();
    }
    super.dispose();
  }
}
