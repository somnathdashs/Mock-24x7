import 'dart:convert';
import 'package:mock24x7/MockModel.dart';
import 'package:mock24x7/MockModelManager.dart';
import 'package:http/http.dart' as http;

class UploadQNA {
  Future<void> uploadMockDatas() async {
    try {
      // Get the list of mock models from local storage
      List<Mockmodel> mockModels = await MockModelManager.getMockModels();

      // Iterate over each mock model and upload data
      for (Mockmodel mock in mockModels) {
        print(mock.is_upload);
        if (mock.is_upload) {
          continue;
        }
        // Convert mock model to JSON
        Map<String, dynamic> data = {
          "id": mock.id.toString(),
          "topic": mock.Topic,
          "level": mock.Difficulty,
          "qna": jsonEncode(mock.QNA),
        };

        // Send POST request to the API
        final response = await http.post(
          Uri.parse(
              'https://hitakhankhihomeohall.in/Api/MockDataSave/index.php'),
          headers: {},
          body: data, // Encode data as JSON
        );

        // Check the response status
        if (response.statusCode == 200) {
          mock.set_is_upload = (int.parse(response.body) != 1) ? false : true;
          MockModelManager.updateMockModel(mock);
          print(
              'Successfully uploaded: ${mock.id} and response ${response.body}');
        } else {
          print(
              'Failed to upload: ${mock.id}. Status Code: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  Future<void> uploadMockData(Mockmodel mock) async {
    try {
      if (mock.is_upload) {
        return;
      }
      // Convert mock model to JSON
      Map<String, dynamic> data = {
        "id": mock.id.toString(),
        "topic": mock.Topic,
        "level": mock.Difficulty,
        "qna": jsonEncode(mock.QNA),
      };

      // Send POST request to the API
      final response = await http.post(
        Uri.parse('https://hitakhankhihomeohall.in/Api/MockDataSave/index.php'),
        headers: {

        },
        body: data, // Encode data as JSON
      );

      // Check the response status
      if (response.statusCode == 200) {
        mock.set_is_upload = (int.parse(response.body) != 1) ? false : true;
        MockModelManager.updateMockModel(mock);
        print(
            'Successfully uploaded: ${mock.id} and response ${response.body}');
      } else {
        print(
            'Failed to upload: ${mock.id}. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }
}
