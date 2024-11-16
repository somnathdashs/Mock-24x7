import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mock24x7/GiminiApi/Api_set_Screen.dart';
import 'package:video_player/video_player.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class Intro_Video_Screen extends StatefulWidget {
  final toggleTheme;
  Intro_Video_Screen({this.toggleTheme});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<Intro_Video_Screen> {
  late VideoPlayerController _controller;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assetss/intro.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.addListener(_updateProgress);
        _controller.setLooping(true);
        // _controller.
      });
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //     overlays: [SystemUiOverlay.bottom]);
  }

  void _updateProgress() {
    if (_controller.value.isInitialized) {
      setState(() {
        _progress = _controller.value.position.inSeconds /
            _controller.value.duration.inSeconds;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_updateProgress);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
            // statusBarColor: Colors.transparent,
            ),
        child: Scaffold(
          body: Stack(
            children: [
              // Video Player
              Center(
                child: _controller.value.isInitialized
                    ? VideoPlayer(_controller)
                    : CircularProgressIndicator(),
              ),
              // Progress Bar at the Top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearPercentIndicator(
                  lineHeight: 3.0,
                  percent: _progress,
                  backgroundColor: Colors.grey[300],
                  progressColor: Colors.blue,
                ),
              ),
              // Next Button at the Bottom Center
              // Positioned(
              //   bottom: 20,
              //   left: 0,
              //   right: 0,
              //   child: Center(
              //     child:
              //  ElevatedButton(
              //   onPressed: () {
              //     // _controller.pause();
              //     Navigator.pushReplacement(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) => GeminiAPIScreen(
              //               toggleTheme: widget.toggleTheme)),
              //     );
              //     // Add action for the "Next" button
              //   },
              //   child: Text("Next"),
              // ),
              // ),
              // ),
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton.extended(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(150.0),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        GeminiAPIScreen(toggleTheme: widget.toggleTheme)),
              );
            },
            backgroundColor: const Color.fromARGB(255, 17, 144, 249),
            label: const Text(
              "Enter Mock 24x7",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            icon: const Padding(
              padding: EdgeInsets.all(0),
              child: Icon(
                Icons.arrow_forward_sharp,
                size: 30.0,
              ),
            ),
          ),
        ));
  }
}
