import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gmap_app/utils/string.dart';
import 'package:stacked/stacked.dart';
import 'package:http/http.dart' as http;

class SearchViewmodel extends BaseViewModel {
  final TextEditingController controller = TextEditingController();
  List placeSuggestionsList = [];
  double? selectedLatitude;
  double? selectedLongitude;
  bool isLoading = false;

  void initState() {
    controller.addListener(onchange);
  }

  @override
  void dispose() {
    controller.removeListener(onchange);
    controller.dispose();
    super.dispose();
  }

  void onchange() {
    if (controller.text.isEmpty) {
      placeSuggestionsList = [];
      rebuildUi();
    } else {
      placeSuggestions(controller.text);
    }
  }

  Future<void> placeSuggestions(String input) async {
    try {
      if (input.isEmpty) {
        placeSuggestionsList = [];
        isLoading = false;
        rebuildUi();
        return;
      }

      isLoading = true;
      rebuildUi();

      String baseURL =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json";
      String request = "$baseURL?input=$input&key=$API_KEY";

      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);

      log("Full API Response: ${response.body}");

      if (response.statusCode == 200) {
        placeSuggestionsList = data['predictions'] ?? [];
        isLoading = false;
        rebuildUi();

        log("Suggestions: ${placeSuggestionsList.toString()}");
      } else {
        isLoading = false;
        rebuildUi();
        // throw Exception("Failed to load data: ${data['errormessage']}");
      }
    } catch (e) {
      log("Error Message : $e");
    }
  }

  Future<void> getPlaceDetails(String placeId) async {
    try {
      String baseURL =
          "https://maps.googleapis.com/maps/api/place/details/json";
      String request = "$baseURL?place_id=$placeId&key=$API_KEY";

      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == 'OK') {
        selectedLatitude = data['result']['geometry']['location']['lat'];
        selectedLongitude = data['result']['geometry']['location']['lng'];
        rebuildUi();
      }
    } catch (e) {
      isLoading = false;
      rebuildUi();
      log("Error getting place details: $e");
    }
  }
}
