import 'dart:convert';
import 'package:mock24x7/MockModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockModelManager {
  static const String _key = 'mock_models';
  static const String _Gimini_key = 'Gimini_key';

  // Gimini api
  static Future<void> save_gimini_key(String apiKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convert the model to JSON and store it
    await prefs.setString(_Gimini_key, apiKey);
  }

// Retrieve mock models from SharedPreferences
  static Future<String> get_gimini_key() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.clear();

    // Retrieve the list of stored model JSON strings
    String apiKey = prefs.getString(_Gimini_key) ?? "";

    // Decode the JSON strings and map them to MockModel objects
    return apiKey;
  }

  // Save updated mock model to SharedPreferences
  static Future<void> updateMockModel(Mockmodel updatedModel) async {
    int id = updatedModel.id;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedModels = prefs.getStringList(_key) ?? [];

    // Find the index of the model with the matching ID
    int modelIndex = storedModels.indexWhere((jsonString) {
      final model = jsonDecode(jsonString);
      return model["id"] == id;
    });
    if (modelIndex != -1) {
      // Replace the old model with the updated model
      storedModels[modelIndex] = jsonEncode(updatedModel.toJson());
      await prefs.setStringList(_key, storedModels);
    } else {
      throw Exception('Model with id $id not found');
    }
  }

  static Future<void> saveMockModel(Mockmodel mockModel) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedModels = prefs.getStringList(_key) ?? [];

    // Convert the model to JSON and store it
    storedModels.add(jsonEncode(mockModel.toJson()));
    await prefs.setStringList(_key, storedModels);
  }

// Retrieve mock models from SharedPreferences
  static Future<List<Mockmodel>> getMockModels() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.clear();

    // Retrieve the list of stored model JSON strings
    List<String> storedModels = prefs.getStringList(_key) ?? [];

    // Decode the JSON strings and map them to MockModel objects
    return storedModels.map((jsonString) {
      // Decode the JSON string and convert it to a MockModel object
      return Mockmodel.fromJson(jsonDecode(jsonString));
    }).toList();
  }
}
