import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomBottomSheet extends StatefulWidget {
  final LatLng latLng;
  final LatLng? selected;
  final VoidCallback onTap;
  const CustomBottomSheet({
    super.key,
    required this.onTap,
    required this.latLng,
    this.selected,
  });

  @override
  State<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  final _controller = DraggableScrollableController();
  bool _isExpanding = false;
  List<double>? _snapSizes; // Store snapSizes here

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    if (_snapSizes == null) return; // Ensure snapSizes is initialized

    final currentSize = _controller.size;
    if (currentSize <= 0.05) {
      _collapse();
    }

    // Prevent expanding beyond the anchor point (0.25 in this case)
    if (_controller.size > 0.25 && !_isExpanding) {
      _anchor();
    }
  }

  void _collapse() {
    if (_snapSizes != null && _snapSizes!.isNotEmpty) {
      _animateSheet(_snapSizes!.first);
    }
  }

  void _anchor() {
    if (_snapSizes != null && _snapSizes!.isNotEmpty) {
      _animateSheet(_snapSizes!.last);
    }
  }

  void _animateSheet(double size) {
    _controller
        .animateTo(
          size,
          duration: const Duration(milliseconds: 50),
          curve: Curves.easeInOut,
        )
        .then((_) {
          _isExpanding = false;
        });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return DraggableScrollableSheet(
          initialChildSize: 0.25,
          maxChildSize:
              0.25, // Set this to the same as anchor size to prevent expanding
          minChildSize: 0,
          expand: false,
          snap: true,
          snapSizes: [40 / constraints.maxHeight, 0.25],
          controller: _controller,
          shouldCloseOnMinExtent: true,
          builder: (BuildContext context, ScrollController scrollController) {
            return DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                physics: const ClampingScrollPhysics(),
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            height: 8,
                            width: 40,
                            margin: EdgeInsets.only(top: 15),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          widget.selected == null
                              ? "Where To"
                              : "${widget.latLng.latitude},${widget.latLng.longitude}",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 15),
                        SizedBox(
                          height: 60,
                          child: widget.selected != null
                              ? null
                              : GestureDetector(
                                  onTap: widget.onTap,
                                  child: TextField(
                                    enabled: false,
                                    decoration: InputDecoration(
                                      label: Text("Select Your Location"),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
