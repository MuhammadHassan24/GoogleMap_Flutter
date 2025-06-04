import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gmap_app/ui/view/search_page.dart';
import 'package:gmap_app/viewmodel/location_viewmodel.dart';
import 'package:gmap_app/widget/bottom_sheet.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stacked/stacked.dart';

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({super.key});

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      onViewModelReady: (viewModel) => viewModel.initialize(context),
      viewModelBuilder: () => LocationViewModel(),
      builder: (context, viewModel, child) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "Google Map",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          body: GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              viewModel.mapController = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            initialCameraPosition: CameraPosition(
              target: viewModel.intialLocation,
              zoom: 13,
            ),
            markers: {
              Marker(
                markerId: MarkerId("value"),
                icon: BitmapDescriptor.defaultMarker,
                position: viewModel.intialLocation,
              ),
            },
          ),
          bottomSheet: CustomBottomSheet(
            latLng: viewModel.intialLocation,
            selected: viewModel.selectedLocation,
            onTap: () async {
              final result = await Navigator.push<LatLng>(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
              if (result != null) {
                viewModel.intialLocation = LatLng(
                  result.latitude,
                  result.longitude,
                );
                log(result.latitude.toString());
                log(result.longitude.toString());

                viewModel.updateSelectedLocation(
                  LatLng(result.latitude, result.longitude),
                );
              } else {
                log("NO Result Found");
              }
            },
          ),
        );
      },
    );
  }
}
