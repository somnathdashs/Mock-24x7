import "dart:convert";
import "dart:math";
import "dart:io";

import "package:cool_alert/cool_alert.dart";
import "package:flutter/material.dart";
import "package:google_generative_ai/google_generative_ai.dart";
import "package:mock24x7/MockModel.dart";
import "package:mock24x7/MockModelManager.dart";
// import "package:python_shell/python_shell.dart";
import "package:url_launcher/url_launcher.dart";
import "package:url_launcher/url_launcher_string.dart";

class Testwork {
  Future<void> openURL(String url) async {
    // For Web and Mobile platforms
    if (Platform.isIOS || Platform.isAndroid) {
      var i = await canLaunchUrlString(url);
      if (!await launchUrl(Uri.parse(url))) {
        throw Exception('Could not launch $url');
      }
      // if (i) {
      //   await launchUrlString(url);
      // } else {
      //   throw 'Could not launch $url';
      // }
    } else {
      // For Desktop platforms (Windows, macOS, Linux)
      if (Platform.isWindows) {
        await Process.run('start', [url], runInShell: true);
      } else if (Platform.isMacOS) {
        await Process.run('open', [url]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [url]);
      }
    }
  }

  String cmdGenerater(String Topic, String level, String numberMcq) {
    Topic = Topic.toUpperCase();
    return '''Generate $numberMcq MCQs on the topic '$Topic' in valid JSON format. Each MCQ should be a dictionary with keys: 'Question', 'Options' (a list of 4 distinct options), 'Answer' (the correct answer from the options in string). Make sure all questions you generate must have difficulty level =  '$level'. Ensure all questions are unique, clear, and contextually accurate. Output should only be in JSON format without any additional text or special characters. Use single quotes for all strings. Return the JSON as a list of dictionaries. Make sure to not use any blank lines or new lines. ''';
  }

  String cmd_related_denerater(String Topic, String numberOfTopic) {
    Topic = Topic.toUpperCase();
    return '''Generate $numberOfTopic topic related to '$Topic'. Make the randomness be 35% . Response in json format having a list of objects of keys 'Topic' (50 char), 'Difficulty' (10 Char),'Num_Mcq' (Max should be 15). Do not respond other than json format. Also, do not use new lines. ''';
  }

  Ask_Gemini(String cmd, [apiKey]) async {
    apiKey ??= await MockModelManager.get_gimini_key();
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: apiKey,
      );

      final content = [Content.text(cmd)];
      final res = await model.generateContent(content);
      return res.text!;
    } catch (e) {
      return false;
    }
  }

//   Future<String> runPythonShell(String cmd) async {
//     // Hypothetical method to run Python shell code
//     var shell = PythonShell(PythonShellConfig());
//     await shell.initialize();
//     String retTxt = "";
//     var instance = ShellManager.getInstance("default");
//     instance.installRequires(["meta-ai-api"], echo: true);
//     var result = await instance.runString("""
// from meta_ai_api import MetaAI
// ai = MetaAI() 
// response = ai.prompt(message="$cmd")
// print(response["message"])
//     """,
//         echo: true,
//         listener: ShellListener(
//             onMessage: (message) {
//               // Ret_Txt= message["message"]; // Assuming result.output contains the response
//               retTxt = message;

//               // if `echo` is `true`, log to console automatically
//             },
//             onError: (e, s) {
//               print("error!$e");
//             },
//             onComplete: () {}));
//     // print(result);

//     return retTxt;
//   }

  void showLoadingDialog(BuildContext context) {
    CoolAlert.show(
      width: 200.0,
      text: "Generating Mock. It may take a minute...",
      title: "Generating Mock. It may take a minute...",
      context: context,
      type: CoolAlertType.loading,
    );
  }

  Future GenerateMock(String topic, String difficulty, int number) async {
    String cmd = cmdGenerater(topic, difficulty, number.toString());
    String qnaString = await Ask_Gemini(cmd);

    if (qnaString == "") {
      qnaString = await Ask_Gemini(cmd);
      if (qnaString == "") {
        return;
      }
    }

    var tempQna;
    try {
      tempQna = jsonDecode(qnaString).cast<Map<String, dynamic>>();
    } catch (E) {
      print("Error: $E");
      return;
    }

    Mockmodel newmockmodel = Mockmodel(
      id: Random().nextInt(180000),
      Topic: topic,
      Difficulty: difficulty,
      Num_MCQ: number,
      QNA: (tempQna == null) ? List.empty() : tempQna,
      Num_Correct_MCQ: 0,
      Num_attempt_MCQ: 0,
      Num_Incorrect_MCQ: 0,
      LastDate_Attempt: DateTime(1900),
      Date_Generated: DateTime.now(),
      IsTimer: false,
      Timer_Time: 0,
      is_upload: false,
    );

    await MockModelManager.saveMockModel(newmockmodel);

    return newmockmodel;
  }
}
