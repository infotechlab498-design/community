import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/location_service.dart';
import '../../data/models/hospital_model.dart';
import '../../data/repositories/community_repository.dart';

class HospitalMapWidget extends StatefulWidget {
  const HospitalMapWidget({super.key});

  @override
  State<HospitalMapWidget> createState() => _HospitalMapWidgetState();
}

class _HospitalMapWidgetState extends State<HospitalMapWidget> {
  bool? _permissionGranted;
  bool _isLoading = false;
  String? _errorMessage;

  UserLocationResult? _userLocation;
  HospitalLocation? _nearestHospital;
  String? _distanceMiles;
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _startTracking() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Get real location (or demo fallback on error/simulator)
      final locationResult = await LocationService.getUserLocation();

      // 2. Load hospitals dataset
      final hospitals = await CommunityRepository.loadHospitals();

      if (hospitals.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No hospitals available in database.';
        });
        return;
      }

      // 3. Compute distance to each hospital & sort ascending
      final List<HospitalLocation> calculated = hospitals.map((hospital) {
        final meters = LocationService.calculateDistanceInMeters(
          startLatitude: locationResult.latitude,
          startLongitude: locationResult.longitude,
          endLatitude: hospital.latitude,
          endLongitude: hospital.longitude,
        );
        final miles = LocationService.convertMetersToMiles(meters);
        return hospital.copyWithDistance(
          distanceMeters: meters,
          distanceMiles: miles,
        );
      }).toList();

      calculated.sort((a, b) =>
          (a.distanceMeters ?? double.infinity).compareTo(b.distanceMeters ?? double.infinity));

      final nearest = calculated.first;

      if (mounted) {
        setState(() {
          _userLocation = locationResult;
          _nearestHospital = nearest;
          _distanceMiles = nearest.distanceMiles;
          _permissionGranted = true;
          _isLoading = false;
        });

        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(locationResult.latitude, locationResult.longitude),
            13.0,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Unable to get location: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initial State: "Check Live Map" CTA card
    if (_permissionGranted == null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 40),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x26ACB3B6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nearest Hospital',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap to see the live location and route.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startTracking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Check Live Map',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Loading State
    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.only(bottom: 40),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x26ACB3B6)),
        ),
        alignment: Alignment.center,
        child: const Column(
          children: [
            CircularProgressIndicator(color: AppColors.primaryPurple),
            SizedBox(height: 12),
            Text(
              'Locating nearest hospital...',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }

    // Error State
    if (_errorMessage != null || _userLocation == null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 40),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x26ACB3B6)),
        ),
        child: Column(
          children: [
            Text(
              _errorMessage ?? 'Unable to determine location.',
              style: const TextStyle(color: AppColors.emergencyRed, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _startTracking,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Retry Location'),
            ),
          ],
        ),
      );
    }

    // Live Map View State
    final userLatLng = LatLng(_userLocation!.latitude, _userLocation!.longitude);
    final hospitalLatLng = _nearestHospital != null
        ? LatLng(_nearestHospital!.latitude, _nearestHospital!.longitude)
        : null;

    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('user_location'),
        position: userLatLng,
        infoWindow: InfoWindow(
          title: _userLocation!.isDemo ? 'Demo Location' : 'Your Location',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      ),
      if (hospitalLatLng != null)
        Marker(
          markerId: MarkerId('hospital_${_nearestHospital!.id}'),
          position: hospitalLatLng,
          infoWindow: InfoWindow(title: _nearestHospital!.name),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        ),
    };

    final Set<Polyline> polylines = {
      if (hospitalLatLng != null)
        Polyline(
          polylineId: const PolylineId('hospital_route'),
          points: [userLatLng, hospitalLatLng],
          color: AppColors.primaryPurple,
          width: 4,
        ),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 40),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x26ACB3B6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nearest Hospital',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_nearestHospital?.name ?? "Hospital"} — ${_distanceMiles ?? "0.0"} miles away',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: _startTracking,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Refresh',
                    style: TextStyle(
                      color: AppColors.primaryPurple,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Map Container
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 220,
              width: double.infinity,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: userLatLng,
                  zoom: 12.5,
                ),
                markers: markers,
                polylines: polylines,
                myLocationEnabled: !_userLocation!.isDemo,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                onMapCreated: (controller) => _mapController = controller,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
