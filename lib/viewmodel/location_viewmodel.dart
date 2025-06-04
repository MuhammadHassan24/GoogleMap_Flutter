import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationViewModel extends BaseViewModel {
  Future<void> initialize(BuildContext context) async {
    await _getCurrentPosition(context);
  }

  GoogleMapController? mapController;

  String? currentAddress;
  Position? currentPosition;

  LatLng? selectedLocation;
  Set<Marker> markers = {};

  LatLng intialLocation = LatLng(24.9054, 66.9670);

  Future<bool> _handleLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location services are disabled. Please enable the services',
          ),
        ),
      );
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location permissions are permanently denied, we cannot request permissions.',
          ),
        ),
      );
      return false;
    }
    return true;
  }

  Future _getCurrentPosition(BuildContext context) async {
    final hasPermission = await _handleLocationPermission(context);
    if (!hasPermission) return;

    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
          currentPosition = position;
          _getAddressFromLaglng(currentPosition!);
          rebuildUi();
        })
        .catchError((e) {
          debugPrint(e);
        });
  }

  Future<void> _getAddressFromLaglng(Position position) async {
    await placemarkFromCoordinates(
          currentPosition!.latitude,
          currentPosition!.longitude,
        )
        .then((List<Placemark> placemarks) {
          Placemark place = placemarks[0];

          currentAddress =
              "${place.street}, ${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}";
          debugPrint(currentAddress);
          rebuildUi();
        })
        .catchError((e) {
          debugPrint(e);
        });
  }

  void updateSelectedLocation(LatLng newLocation) {
    selectedLocation = newLocation;
    markers.clear();
    markers.add(
      Marker(
        markerId: const MarkerId('selectedLocation'),
        position: newLocation,
      ),
    );
    try {
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(newLocation, 15),

        duration: const Duration(milliseconds: 500),
      );
      rebuildUi();
    } catch (e) {
      debugPrint("Error moving camera: $e");
    }
  }
}
