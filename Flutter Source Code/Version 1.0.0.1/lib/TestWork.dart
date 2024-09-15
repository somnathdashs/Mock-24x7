import "package:mock24x7/MockModel.dart";
import "package:python_shell/python_shell.dart";

class Testwork {
  String cmdGenerater(String Topic, String level, String number_mcq) {
    Topic = Topic.toUpperCase();
    return '''Generate $number_mcq MCQs on the topic '$Topic' in valid JSON format. Each MCQ should be a dictionary with keys: 'Question', 'Options' (a list of 4 distinct options), 'Answer' (the correct answer from the options in string). Make sure all questions you generate must have difficulty level =  '$level'. Ensure all questions are unique, clear, and contextually accurate. Output should only be in JSON format without any additional text or special characters. Use single quotes for all strings. Return the JSON as a list of dictionaries. Make sure to not use any blank lines or new lines. ''';
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

    return Ret_Txt;
  }
}
