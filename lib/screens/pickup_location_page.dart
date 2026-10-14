import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_sdk_plus/google_places_sdk_plus.dart'
    as places_sdk;
import 'package:http/http.dart' as http;

// ======================================================
// PICKUP LOCATION PAGE
// ======================================================


class PickupLocationPage extends StatefulWidget {
  final LatLng? initialLocation;

  const PickupLocationPage({
    super.key,
    this.initialLocation,
  });

  @override
  State<PickupLocationPage> createState() =>
      _PickupLocationPageState();
}

class _PickupLocationPageState
    extends State<PickupLocationPage> {
  // Replace this placeholder with the same restricted API key
  // already used in AndroidManifest.xml.
  static const String _googlePlacesApiKey =
      'AIzaSyD2Y7p14xjRo5cLM9upml6KWOyQCpy0JJE';

  late final places_sdk.FlutterGooglePlacesSdk _places;

  late LatLng selectedLocation;
  GoogleMapController? _mapController;

  final TextEditingController _searchController =
      TextEditingController();

  Timer? _searchDebounce;

  List<places_sdk.AutocompletePrediction> _predictions = [];

  String selectedAddress =
      'Move the map or search for an address';

  String? _searchError;

  bool isLoadingAddress = false;
  bool isSearching = false;
  bool _movingToSearchResult = false;

  @override
  void initState() {
    super.initState();

    selectedLocation = widget.initialLocation ??
        const LatLng(22.3569, 91.7832);

    _places = places_sdk.FlutterGooglePlacesSdk(
      _googlePlacesApiKey,
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // Search Google Places suggestions.
  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    if (value.trim().length < 3) {
      setState(() {
        _predictions = [];
        _searchError = null;
        isSearching = false;
      });
      return;
    }

    _searchDebounce = Timer(
      const Duration(milliseconds: 450),
      () => _searchPlaces(value.trim()),
    );
  }

  Future<void> _searchPlaces(String query) async {
    if (!mounted) return;

    setState(() {
      isSearching = true;
      _searchError = null;
    });

    try {
      final result =
          await _places.findAutocompletePredictions(
        query,
        countries: ['bd'],
        newSessionToken: true,
      );

      if (!mounted) return;

      setState(() {
        _predictions = result.predictions;
        isSearching = false;

        if (_predictions.isEmpty) {
          _searchError = 'No matching places found.';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSearching = false;
        _predictions = [];
        _searchError =
            'Could not search places. Check internet and API setup.';
      });

      debugPrint('Places search error: $e');
    }
  }

  // Select a suggestion, get its address and coordinates,
  // then move the Google Map to that location.
  
  Future<void> _selectPlace(
    places_sdk.AutocompletePrediction prediction,
  ) async {
    FocusScope.of(context).unfocus();

    final placeId = prediction.placeId;

    if (placeId == null || placeId.isEmpty) {
      setState(() {
        _searchError = 'Could not identify this place.';
      });
      return;
    }

    setState(() {
      isSearching = true;
      _searchError = null;
      _predictions = [];
    });

    try {
      final result = await _places.fetchPlace(
        placeId,
        fields: const [
          places_sdk.PlaceField.FormattedAddress,
          places_sdk.PlaceField.Location,
          places_sdk.PlaceField.DisplayName,
        ],
      );

      final place = result.place;
      final placeLocation = place?.latLng;

      if (placeLocation == null) {
        throw Exception('Selected place has no coordinates.');
      }

      final newLocation = LatLng(
        placeLocation.lat,
        placeLocation.lng,
      );

      _movingToSearchResult = true;

      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(newLocation, 17),
      );

      if (!mounted) return;

      setState(() {
        selectedLocation = newLocation;

        selectedAddress = place?.address?.isNotEmpty == true
            ? place!.address!
            : (prediction.fullText ?? 'Selected location');

        _searchController.text = prediction.fullText ?? '';
        _predictions = [];
        _searchError = null;
        isSearching = false;
        _movingToSearchResult = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSearching = false;
        _movingToSearchResult = false;
        _searchError =
            'Could not load this place. Please try another result.';
      });

      debugPrint('Place details error: $e');
    }
  }

  // Fallback reverse geocoding for a manually moved map pin.
  Future<void> getAddressFromLocation(
    LatLng location,
  ) async {
    setState(() {
      isLoadingAddress = true;
    });

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=jsonv2'
        '&lat=${location.latitude}'
        '&lon=${location.longitude}'
        '&zoom=18'
        '&addressdetails=1'
        '&accept-language=en',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'LaundryLoop/1.0',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          selectedAddress =
              data['display_name'] ?? 'Address not found';
        });
      } else {
        if (!mounted) return;

        setState(() {
          selectedAddress = 'Address could not be found';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        selectedAddress = 'Unable to get address';
      });

      debugPrint('Reverse geocoding error: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoadingAddress = false;
        });
      }
    }
  }

  Future<void> confirmLocation() async {
    if (isLoadingAddress) return;

    // Search selection already has an address.
    // Only reverse-geocode when the user manually moves the map.
    if (selectedAddress == 'Move the map or search for an address' ||
        selectedAddress == 'Address not found' ||
        selectedAddress == 'Address could not be found' ||
        selectedAddress == 'Unable to get address') {
      await getAddressFromLocation(selectedLocation);
    }

    if (!mounted) return;

    Navigator.pop(
      context,
      {
        'location': selectedLocation,
        'address': selectedAddress,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Pickup Location',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: selectedLocation,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: (LatLng position) async {
              setState(() {
                selectedLocation = position;
                selectedAddress = 'Getting address...';
                _searchError = null;
              });

              await getAddressFromLocation(position);
            },
            onCameraMove: (position) {
              selectedLocation = position.target;
            },
            onCameraIdle: () {
              if (_movingToSearchResult || !mounted) return;

              setState(() {
                selectedAddress =
                    'Move or zoom the map, or tap to select a location.';
              });
            },
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            scrollGesturesEnabled: true,
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: true,
            mapToolbarEnabled: false,
          ),


          // Address search and suggestions
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(14),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search pickup address...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchDebounce?.cancel();
                                _searchController.clear();

                                setState(() {
                                  _predictions = [];
                                  _searchError = null;
                                  isSearching = false;
                                });
                              },
                            ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),

                  if (_predictions.isNotEmpty)
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 240,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _predictions.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final prediction = _predictions[index];

                          return ListTile(
                            leading: const Icon(
                              Icons.location_on_outlined,
                              color: Colors.teal,
                            ),
                            title: Text(prediction.primaryText ?? ''),
                            subtitle: Text(prediction.secondaryText ?? ''),
                            onTap: () => _selectPlace(prediction),
                          );
                        },
                      ),
                    ),

                  if (_searchError != null)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        _searchError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Selected coordinates and address
          Positioned(
            left: 16,
            right: 16,
            bottom: 84,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Your pickup location',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${selectedLocation.latitude.toStringAsFixed(5)}, '
                    '${selectedLocation.longitude.toStringAsFixed(5)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedAddress,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'You can also move the map to adjust the pin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          // Confirm selected pickup location
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isLoadingAddress || isSearching
                    ? null
                    : confirmLocation,
                icon: const Icon(Icons.check),
                label: Text(
                  isLoadingAddress
                      ? 'Getting Address...'
                      : 'Confirm Pickup Location',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}