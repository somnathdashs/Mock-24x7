import 'dart:convert';
import 'package:mock24x7/MockModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockModelManager {
  static const String _key = 'mock_models';
  static const String _ads_key = 'Ads_Details_';
  static const String _Gimini_key = 'Gimini_key';

  static clear() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();

  }

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

  static Future<void> deleteMockModel(Mockmodel mockModel) async {
    int id = mockModel.id;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedModels = prefs.getStringList(_key) ?? [];

    // Find the index of the model with the matching ID
    int modelIndex = storedModels.indexWhere((jsonString) {
      final model = jsonDecode(jsonString);
      return model["id"] == id;
    });
    if (modelIndex != -1) {
      // Replace the old model with the updated model
      storedModels.removeAt(modelIndex);
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

  static Future<int> Num_of_Rads_in_24hr() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_ads_key + "in_24hr") ?? 0;
  }

  static Set_Num_of_Rads_in_24hr(int num) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(_ads_key + "in_24hr", num);
  }

  static Set_Last_day_Rads_activity(DateTime date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_ads_key + "last_day", date.toString());
  }

  static Future<String> Get_Last_day_Rads_activity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_ads_key + "last_day") ?? "";
  }

  static Set_is_ads_disable(bool is_ads_disable) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(_ads_key + "is_ads_disable", is_ads_disable);
  }

  static Future<bool> Get_is_ads_disable() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_ads_key + "is_ads_disable",false);
  }
}
