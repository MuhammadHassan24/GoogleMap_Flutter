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
          body: Padding(
            padding: const EdgeInsets.only(top: 50, left: 15, right: 15),
            child: Column(
              children: [
                TextField(
                  controller: viewModel.controller,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(8),
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    suffixIcon: viewModel.isLoading
                        ? IconButton(
                            onPressed: () {
                              viewModel.controller.clear();
                              setState(() {
                                viewModel.placeSuggestionsList = [];
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
                      viewModel.controller.text.isNotEmpty &&
                          viewModel.placeSuggestionsList.isNotEmpty
                      ? ListView.builder(
                          itemCount: viewModel.placeSuggestionsList.length,
                          itemBuilder: (context, index) {
                            final place = viewModel.placeSuggestionsList[index];
                            return ListTile(
                              title: Text(
                                place["description"],
                                style: const TextStyle(color: Colors.black),
                              ),
                              onTap: () async {
                                await viewModel.getPlaceDetails(
                                  place['place_id'],
                                );
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
      },
    );
  }
}
