class Hospital {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int sortOrder;

  const Hospital({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.sortOrder = 0,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      sortOrder: (json['sortOrder'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toRequestJson() => {
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'sortOrder': sortOrder,
      };

  /// Opens in the external Maps app or browser; no location permission needed.
  Uri get mapsUri => Uri.https('www.google.com', '/maps/search/', {
        'api': '1',
        'query': '$latitude,$longitude',
      });
}
