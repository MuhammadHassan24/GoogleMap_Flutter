import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gmap_app/utils/string.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  String token = "1234567890";
  List _placeSuggestionsList = [];
  double? _selectedLatitude;
  double? _selectedLongitude;
  String? _selectedPlaceId;
  bool _isLoading = false;

  @override
  void initState() {
    _controller.addListener(_onchange);
    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(_onchange);
    _controller.dispose();
    super.dispose();
  }

  void _onchange() {
    if (_controller.text.isEmpty) {
      setState(() {
        _placeSuggestionsList = [];
      });
    } else {
      _placeSuggestions(_controller.text);
    }
  }

  Future<void> _placeSuggestions(String input) async {
    try {
      if (input.isEmpty) {
        setState(() {
          _placeSuggestionsList = [];
          _isLoading = false;
        });
        return;
      }
      setState(() {
        _isLoading = true;
      });

      String baseURL =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json";
      String request = "$baseURL?input=$input&key=$API_KEY";

      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);

      log("Full API Response: ${response.body}");

      if (response.statusCode == 200) {
        setState(() {
          _placeSuggestionsList = data['predictions'] ?? [];
          _isLoading = false;
        });

        log("Suggestions: ${_placeSuggestionsList.toString()}");
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception("Failed to load data: ${data['error_message']}");
      }
    } catch (e) {
      log("Error Message : $e");
    }
  }

  Future<void> _getPlaceDetails(String placeId) async {
    try {
      String baseURL =
          "https://maps.googleapis.com/maps/api/place/details/json";
      String request =
          "$baseURL?place_id=$placeId&key=$API_KEY&sessiontoken=$token";

      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == 'OK') {
        setState(() {
          _selectedLatitude = data['result']['geometry']['location']['lat'];
          _selectedLongitude = data['result']['geometry']['location']['lng'];
          _selectedPlaceId = placeId;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      log("Error getting place details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 50, left: 15, right: 15),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(8),
                prefixIcon: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                suffixIcon: _isLoading
                    ? IconButton(
                        onPressed: () {
                          _controller.clear();
                          setState(() {
                            _placeSuggestionsList = [];
                          });
                        },
                        icon: Icon(Icons.clear),
                      )
                    : Icon(Icons.search),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
              ),
            ),
            Expanded(
              child:
                  _controller.text.isNotEmpty &&
                      _placeSuggestionsList.isNotEmpty
                  ? ListView.builder(
                      itemCount: _placeSuggestionsList.length,
                      itemBuilder: (context, index) {
                        final place = _placeSuggestionsList[index];
                        return ListTile(
                          title: Text(
                            place["description"],
                            style: const TextStyle(color: Colors.black),
                          ),
                          onTap: () async {
                            await _getPlaceDetails(place['place_id']);
                            if (_selectedLatitude != null &&
                                _selectedLongitude != null) {
                              Navigator.pop(
                                context,
                                LatLng(_selectedLatitude!, _selectedLongitude!),
                              );
                            }
                          },
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        'Start typing to search for places',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
