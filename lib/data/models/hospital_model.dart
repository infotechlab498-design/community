class HospitalLocation {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final double? distanceMeters;
  final String? distanceMiles;

  const HospitalLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.distanceMeters,
    this.distanceMiles,
  });

  factory HospitalLocation.fromJson(Map<String, dynamic> json) {
    return HospitalLocation(
      id: json['id'] as int,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  HospitalLocation copyWithDistance({
    required double distanceMeters,
    required String distanceMiles,
  }) {
    return HospitalLocation(
      id: id,
      name: name,
      latitude: latitude,
      longitude: longitude,
      distanceMeters: distanceMeters,
      distanceMiles: distanceMiles,
    );
  }
}
