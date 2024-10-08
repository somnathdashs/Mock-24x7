import 'dart:convert';

class Mockmodel {
  int id;
  String Topic;
  String Difficulty;
  int Num_MCQ;
  List<Map<String, dynamic>> QNA;
  int Num_Correct_MCQ;
  int Num_Incorrect_MCQ;
  int Num_attempt_MCQ;
  DateTime LastDate_Attempt;
  DateTime Date_Generated;
  bool IsTimer;
  int Timer_Time;
  bool is_upload;

  Mockmodel({
    required this.id,
    required this.Topic,
    required this.Difficulty,
    required this.Num_MCQ,
    required this.QNA,
    required this.Num_Correct_MCQ,
    required this.Num_Incorrect_MCQ,
    required this.Num_attempt_MCQ,
    required this.LastDate_Attempt,
    required this.Date_Generated,
    required this.IsTimer,
    required this.Timer_Time,
    required this.is_upload
  });

  // Setters
  set setNumCorrectMCQ(int numCorrectMCQ) => Num_Correct_MCQ = numCorrectMCQ;
  set setNumIncorrectMCQ(int numIncorrectMCQ) => Num_Incorrect_MCQ = numIncorrectMCQ;
  set setNumAttemptMCQ(int numAttemptMCQ) => Num_attempt_MCQ = numAttemptMCQ;
  set setLastDateAttempt(DateTime lastDateAttempt) => LastDate_Attempt = lastDateAttempt;
  set setDateGenerated(DateTime dateGenerated) => Date_Generated = dateGenerated;
  set setIsTimer(bool isTimer) => IsTimer = isTimer;
  set setTimerTime(int timerTime) => Timer_Time = timerTime;
  set set_is_upload(bool is_upload) => is_upload = is_upload;

  // Convert to JSON
  Map<String, dynamic> toJson() => {
        "id": id,
        "Topic": Topic,
        "Difficulty": Difficulty,
        "Num_MCQ": Num_MCQ,
        "QNA": jsonEncode(QNA),
        "Num_Correct_MCQ": Num_Correct_MCQ,
        "Num_Incorrect_MCQ": Num_Incorrect_MCQ,
        "Num_attempt_MCQ": Num_attempt_MCQ,
        "LastDate_Attempt": LastDate_Attempt.toString(),
        "Date_Generated": Date_Generated.toString(),
        "IsTimer": IsTimer,
        "Timer_Time": Timer_Time,
        "is_upload":is_upload,
      };

  // Create a factory constructor to initialize the model from JSON
  factory Mockmodel.fromJson(Map<String, dynamic> json) {
    // print( );
    var Temp=  Mockmodel(
      id: json['id'],
      Topic: json['Topic'],
      Difficulty: json['Difficulty'],
      Num_MCQ: json['Num_MCQ'],
      QNA: List<Map<String, dynamic>>.from(jsonDecode(json['QNA'])),
      Num_Correct_MCQ: json['Num_Correct_MCQ'],
      Num_Incorrect_MCQ: json['Num_Incorrect_MCQ'],
      Num_attempt_MCQ: json['Num_attempt_MCQ'],
      LastDate_Attempt: DateTime.parse(json['LastDate_Attempt']),
      Date_Generated: DateTime.parse(json['Date_Generated']),
      IsTimer: json['IsTimer'],
      Timer_Time: json['Timer_Time'],
      is_upload: (json['is_upload']==null)? false : json['is_upload'],
    );


    return Temp;
  }
}
