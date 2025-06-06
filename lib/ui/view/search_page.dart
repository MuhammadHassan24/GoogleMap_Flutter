import 'package:flutter/material.dart';
import 'package:gmap_app/viewmodel/search_viewmodel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stacked/stacked.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      onViewModelReady: (viewModel) => viewModel.initState(),
      viewModelBuilder: () => SearchViewmodel(),
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Colors.white,

          body: Padding(
            padding: const EdgeInsets.only(top: 50, left: 15, right: 15),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSearchField(viewModel),
                  _buildSearchResults(viewModel),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchField(SearchViewmodel viewModel) {
    return TextField(
      controller: viewModel.controller,
      autofocus: true,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(10),
        filled: true,
        fillColor: Colors.grey[100],
        prefixIcon: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        suffixIcon: _buildSuffixIcon(viewModel),
        hintText: 'Search for places...',
        hintStyle: TextStyle(color: Colors.grey[500]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.blue, width: 1.5),
        ),
      ),
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget? _buildSuffixIcon(SearchViewmodel viewModel) {
    if (viewModel.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return viewModel.controller.text.isNotEmpty
        ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.black54),
            onPressed: () {
              viewModel.controller.clear();
              viewModel.placeSuggestionsList = [];
              viewModel.rebuildUi();
            },
          )
        : const Icon(Icons.search, color: Colors.black54);
  }

  Widget _buildSearchResults(SearchViewmodel viewModel) {
    if (viewModel.controller.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Search for places, addresses, or landmarks',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (viewModel.placeSuggestionsList.isEmpty &&
        viewModel.controller.text.isNotEmpty) {
      return Center(
        child: Text(
          viewModel.isLoading ? 'Searching...' : 'No results found',
          style: TextStyle(color: Colors.grey[500], fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 8),
      itemCount: viewModel.placeSuggestionsList.length,
      itemBuilder: (context, index) {
        final place = viewModel.placeSuggestionsList[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: const Icon(Icons.location_on, color: Colors.blue),
            title: Text(
              place["description"],
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            onTap: () async {
              await viewModel.getPlaceDetails(place['place_id']);
              if (viewModel.selectedLatitude != null &&
                  viewModel.selectedLongitude != null) {
                Navigator.pop(
                  context,
                  LatLng(
                    viewModel.selectedLatitude!,
                    viewModel.selectedLongitude!,
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
