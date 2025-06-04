import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
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

  @override
  void initState() {
    _controller.addListener(() {
      _onchange();
    });
    super.initState();
  }

  void _onchange() {
    _placeSuggestions(_controller.text);
  }

  void _placeSuggestions(String input) async {
    try {
      String baseURL =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json";
      String request = "$baseURL?input=$input&key=$API_KEY&sessiontoken=$token";
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);
      log("Full API Response: ${response.body}");
      if (kDebugMode) {
        log(data);
      }
      if (response.statusCode == 200) {
        setState(() {
          _placeSuggestionsList = data['predictions'] ?? [];
          _selectedLatitude = data['result']['geometry']['location']['lat'];
          _selectedLongitude = data['result']['geometry']['location']['lng'];
        });
        log("Suggestions: ${_placeSuggestionsList.toString()}");
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      log("Error Message : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 50, left: 15, right: 15),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(8),
                prefixIcon: Icon(Icons.arrow_back),
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
              ),
            ),
            Visibility(
              visible: _controller.text.isNotEmpty ? true : false,
              child: Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _placeSuggestionsList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      minTileHeight: 50,
                      title: Text(
                        _placeSuggestionsList[index]["description"],
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  },
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(
                  context,
                  LatLng(
                    _selectedLatitude ?? 24.9114,
                    _selectedLongitude ?? 66.9822,
                  ),
                );
                setState(() {});
              },
              child: Text("Back"),
            ),
          ],
        ),
      ),
    );
  }
}
