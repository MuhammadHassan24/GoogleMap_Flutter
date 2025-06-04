// import 'dart:developer';

// import 'package:flutter/widgets.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:stacked/stacked.dart';

// class SearchViewmodel extends BaseViewModel {
//   String _selectedAddress = "Select Location"; // Initialize with default text
//   double? _selectedLatitude;
//   double? _selectedLongitude;
//   final TextEditingController _searchController = TextEditingController();
//   List<dynamic> _placeSuggestions = [];
//   bool _isSearching = false;
//   final TextEditingController searchController = TextEditingController();
//   bool _isMapMoving = false;

//   Future<void> _confirmLocation(BuildContext context) async {
//     if (_selectedLatitude != null && _selectedLongitude != null) {
//       // Return the selected location instead of navigating to StoreListView
//       Navigator.pop(context, LatLng(_selectedLatitude!, _selectedLongitude!));
//     } else {
//       log("Loaction Is Not Selected");
//     }
//   }
// }
