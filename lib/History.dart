// For isolate

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:mock24x7/Ads.dart';
import 'package:mock24x7/MockInfo.dart';
import 'package:mock24x7/MockModel.dart';
import 'package:mock24x7/MockModelManager.dart';

var mockModelList = MockModelManager.getMockModels(); // Retrieve saved models

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreen();
}

class _HistoryScreen extends State<HistoryScreen> {
  void Delete() {
    setState(() {
      mockModelList = MockModelManager.getMockModels();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mockModelList = MockModelManager.getMockModels(); // Retrieve saved models

  }

  @override
  Widget build(BuildContext context) {
    // print(mockModelList);
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
      ),
      body: FutureBuilder<List<Mockmodel>>(
          future: mockModelList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error loading mock models: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No history available.',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            var mockModels = snapshot.data!.reversed.toList();
            return ListView.builder(
                shrinkWrap: true,
                itemCount: mockModels.length,
                itemBuilder: (context, index) {
                  if ([3, 7, 9].contains(index)) {
                    int i = (index == 3)
                        ? 0
                        : (index == 7)
                            ? 1
                            : (index == 9)
                                ? 2
                                : 0;
                    return Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        MockCard(
                          mockModel: mockModels[index],
                          ondel: Delete,
                        ),
                      ],
                    );
                  } else {
                    return MockCard(
                      mockModel: mockModels[index],
                      ondel: Delete,
                    );
                  }
                });
          }),
    );
  }
}

class MockCard extends StatelessWidget {
  final Mockmodel mockModel;
  final ondel;

  const MockCard({super.key, required this.mockModel, required this.ondel});

  @override
  Widget build(BuildContext context) {
    // Get screen width and height for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onLongPress: () {
          CoolAlert.show(
              width: 150.0,
              title: "Are you sure to delete it?",
              context: context,
              type: CoolAlertType.confirm,
              onConfirmBtnTap: () {
                MockModelManager.deleteMockModel(mockModel);
                ondel();
              });
        },
        onTap: () {
          CoolAlert.show(
            autoCloseDuration: const Duration(seconds: 2),
            width: 150.0,
            title: "Loading...",
            context: context,
            type: CoolAlertType.loading,
          ).then((onValue) async {
            // await Ads.show_Interstitial_Ads();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SuccessScreen(mockModel),
              ),
            );
          });

          // Navigate to the quiz screen and pass the selected MockModel
        },
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mockModel.Topic,
                  style: TextStyle(
                    fontSize: screenWidth > 600 ? 24 : 18, // Dynamic font size
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                // Title and Date row
                const SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 3,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildInfoItem(
                              Icons.access_time,
                              'Date Generate',
                              mockModel.Date_Generated.year < 2020
                                  ? 'Date Not Found'
                                  : DateFormat('MMM dd, yyyy')
                                      .format(mockModel.Date_Generated)
                                      .toString(),
                            ),
                            const SizedBox(width: 20),
                            _buildInfoItem(
                              Icons.access_time,
                              'Last Attempt',
                              mockModel.LastDate_Attempt.year < 2020
                                  ? 'Date Not Found'
                                  : DateFormat('MMM dd, yyyy')
                                      .format(mockModel.LastDate_Attempt)
                                      .toString(),
                            ),
                            const SizedBox(width: 20),
                            _buildInfoItem(
                              Icons.question_answer,
                              'Total Questions',
                              mockModel.QNA.length.toString(),
                            ),
                            const SizedBox(width: 20),
                            _buildInfoItem(
                              Icons.timer,
                              'Timer',
                              (mockModel.Timer_Time == 0)
                                  ? "No timer"
                                  : "${mockModel.Timer_Time} Min",
                            ),
                            const SizedBox(width: 20),
                            _buildInfoItem(
                              Icons.check_circle,
                              'Correct',
                              "${mockModel.Num_Correct_MCQ}/${mockModel.QNA.length}",
                              correctColor: Colors.green,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value,
      {Color correctColor = Colors.white}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon,
                color: Colors.blue,
                size: 24), // Smaller icon for better responsiveness
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14, // Smaller font for better adaptability
              ),
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: label == 'Correct' ? correctColor : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
