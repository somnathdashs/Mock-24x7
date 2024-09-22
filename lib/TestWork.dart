import "dart:convert";
import "dart:math";

import "package:cool_alert/cool_alert.dart";
import "package:flutter/material.dart";
import "package:mock24x7/MockModel.dart";
import "package:mock24x7/MockModelManager.dart";
import "package:python_shell/python_shell.dart";

class Testwork {
  String cmdGenerater(String Topic, String level, String number_mcq) {
    Topic = Topic.toUpperCase();
    return '''Generate $number_mcq MCQs on the topic '$Topic' in valid JSON format. Each MCQ should be a dictionary with keys: 'Question', 'Options' (a list of 4 distinct options), 'Answer' (the correct answer from the options in string). Make sure all questions you generate must have difficulty level =  '$level'. Ensure all questions are unique, clear, and contextually accurate. Output should only be in JSON format without any additional text or special characters. Use single quotes for all strings. Return the JSON as a list of dictionaries. Make sure to not use any blank lines or new lines. ''';
  }

  String cmd_related_denerater(String Topic, String number_of_topic) {
    Topic = Topic.toUpperCase();
    return '''Generate $number_of_topic topic related to '$Topic'. Make the randomness be 35% . Response in json format having a list of objects of keys 'Topic' (50 char), 'Difficulty' (10 Char),'Num_Mcq' (Max should be 15). Do not respond other than json format. Also, do not use new lines. ''';
  }

  Future<String> runPythonShell(String cmd) async {
    // Hypothetical method to run Python shell code
    var shell = PythonShell(PythonShellConfig());
    await shell.initialize();
    String Ret_Txt = "";
    var instance = ShellManager.getInstance("default");
    instance.installRequires(["meta-ai-api"], echo: true);
    var result = await instance.runString("""
from meta_ai_api import MetaAI
ai = MetaAI()
response = ai.prompt(message="$cmd")
print(response["message"])
    """,
        echo: true,
        listener: ShellListener(
            onMessage: (message) {
              // Ret_Txt= message["message"]; // Assuming result.output contains the response
              Ret_Txt = message;

              // if `echo` is `true`, log to console automatically
            },
            onError: (e, s) {
              print("error!" + e.toString());
            },
            onComplete: () {}));
    // print(result);

    return Ret_Txt;
  }

  void showLoadingDialog(BuildContext context) {
    CoolAlert.show(
      width: 200.0,
      text: "Generating Mock. It may take a minute...",
      title: "Generating Mock. It may take a minute...",
      context: context,
      type: CoolAlertType.loading,
    );
    // showDialog(
    //   context: context,
    //   barrierDismissible: false, // Prevent dismissing by tapping outside
    //   builder: (BuildContext context) {
    //     return const AlertDialog(
    //       content: Row(
    //         children: [
    //           CircularProgressIndicator(),
    //           SizedBox(width: 20),
    //           Text("Generating Mock. It may take a minute..."),
    //         ],
    //       ),
    //     );
    //   },
    // );
  }

  Future GenerateMock(String topic, String difficulty, int number) async {
    String cmd = cmdGenerater(topic, difficulty, number.toString());
    String QNA_string = await runPythonShell(cmd);

    if (QNA_string == "" || QNA_string == null) {
      QNA_string = await runPythonShell(cmd);
      if (QNA_string == "" || QNA_string == null) {
        return;
      }
    }

    var _temp_QNA;
    try {
      _temp_QNA = jsonDecode(QNA_string).cast<Map<String, dynamic>>();
    } catch (E) {
      print("Error: " + E.toString());
      return;
    }

    Mockmodel _newmockmodel = Mockmodel(
      id: Random().nextInt(180000),
      Topic: topic,
      Difficulty: difficulty,
      Num_MCQ: number,
      QNA: (_temp_QNA == null) ? List.empty() : _temp_QNA,
      Num_Correct_MCQ: 0,
      Num_attempt_MCQ: 0,
      Num_Incorrect_MCQ: 0,
      LastDate_Attempt: DateTime(1900),
      Date_Generated: DateTime.now(),
      IsTimer: false,
      Timer_Time: 0,
      is_upload: false,
    );

    await MockModelManager.saveMockModel(_newmockmodel);

    return _newmockmodel;
  }
}
