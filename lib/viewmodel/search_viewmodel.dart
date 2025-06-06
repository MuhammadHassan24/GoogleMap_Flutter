import 'dart:async';
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
  // Add these for debounce functionality
  Timer? _debounceTimer;
  final Duration _debounceDelay = const Duration(milliseconds: 300);

  void initState() {
    controller.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    controller.removeListener(_onSearchTextChanged);
    controller.dispose();

    // Cancel any pending debounce timers when disposing
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchTextChanged() {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(_debounceDelay, () {
      final currentText = controller.text;

      // Only proceed if text hasn't changed during the delay
      if (currentText == controller.text) {
        if (currentText.isEmpty) {
          _clearSuggestions();
        } else {
          placeSuggestions(currentText);
        }
      }
    });
  }

  void _clearSuggestions() {
    if (placeSuggestionsList.isNotEmpty || isLoading) {
      placeSuggestionsList = [];
      isLoading = false;
      rebuildUi(); // Only rebuild if there's actually a change
    }
  }

  Future<void> placeSuggestions(String input) async {
    // Early return if same search is already in progress
    if (isLoading) return;

    try {
      isLoading = true;
      rebuildUi(); // First rebuild for loading state

      final response = await http.get(
        Uri.parse(
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$API_KEY",
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newSuggestions = data['predictions'] ?? [];

        // Only update if suggestions actually changed
        if (!_listEquals(placeSuggestionsList, newSuggestions)) {
          placeSuggestionsList = newSuggestions;
          rebuildUi();
        }
      }
    } catch (e) {
      log("Error: $e");
    } finally {
      if (isLoading) {
        isLoading = false;
        rebuildUi();
      }
    }
  }

  // Helper to compare lists deeply
  bool _listEquals(List list1, List list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (jsonEncode(list1[i]) != jsonEncode(list2[i])) {
        return false;
      }
    }
    return true;
  }

  Future<void> getPlaceDetails(String placeId) async {
    try {
      isLoading = true;
      rebuildUi();

      String baseURL =
          "https://maps.googleapis.com/maps/api/place/details/json";
      String request = "$baseURL?place_id=$placeId&key=$API_KEY";

      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == 'OK') {
        selectedLatitude = data['result']['geometry']['location']['lat'];
        selectedLongitude = data['result']['geometry']['location']['lng'];
      }
    } catch (e) {
      log("Error getting place details: $e");
    } finally {
      isLoading = false;
      rebuildUi();
    }
  }
}
