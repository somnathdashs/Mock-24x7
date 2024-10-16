import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:mock24x7/HomeScreen.dart';
import 'package:mock24x7/MockModelManager.dart';
import 'package:mock24x7/TestWork.dart';

class GeminiAPIScreen extends StatelessWidget {
  final VoidCallback toggleTheme;

  GeminiAPIScreen(
      {super.key, required this.toggleTheme});

  final TextEditingController _apiKeyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 70.0,horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {},
                  child: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/Google_Gemini_logo.svg/640px-Google_Gemini_logo.svg.png', // Replace with actual Gemini AI logo URL
                    height: 200,
                    width: 200,
                  ),
                ),

                // Gemini AI logo

                const SizedBox(height: 20),

                // Title text
                const Text(
                  'Enter Gemini API Key',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 20),

                // Textbox for API key
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _apiKeyController,
                    decoration: InputDecoration(
                      labelText: 'API Key',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      prefixIcon: const Icon(Icons.key),
                    ),
                  ),
                ),

                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        var url = "https://aistudio.google.com/app/apikey";
                        Testwork().openURL(url);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Get API Key',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Handle the API key submission
                        String apiKey = _apiKeyController.text;
                        if (apiKey.isNotEmpty) {
                          CoolAlert.show(
                            width: 200.0,
                            text:
                                "Checking Your API key. Make sure to connected to internet.",
                            title:
                                "Checking Your API key. Make sure to connected to internet.",
                            context: context,
                            type: CoolAlertType.loading,
                          );
                          var Bool = await Testwork()
                              .Ask_Gemini("Response just word 'true'", apiKey);
                          if (Bool.toString().contains("true")) {
                            Navigator.pop(context);
                            MockModelManager.save_gimini_key(apiKey);
                            Future.delayed(Duration.zero, () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyHomePage(
                                        toggleTheme: toggleTheme)),
                              );
                            });
                          } else {
                            Navigator.pop(context);
                            CoolAlert.show(
                                title: "Check API key",
                                confirmBtnText: "Ok",
                                showCancelBtn: true,
                                context: context,
                                width: 400.0,
                                animType: CoolAlertAnimType.slideInDown,
                                type: CoolAlertType.error,
                                text:
                                    "Check your API and internet connection and try again.",
                                confirmBtnColor:
                                    const Color.fromARGB(255, 27, 162, 81));
                          }
                        } else {
                          // Show error message
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Error'),
                              content: const Text('Please enter your API key'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Testwork().openURL(
              "https://somnathdashs.github.io/Mock247/How-to-use.html");
        },
        icon: Icon(Icons.help),
        label: Text("Help"),
      ),
    );
  }
}
