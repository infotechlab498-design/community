class ContactCategory {
  ContactCategory._();

  static const String emergency = 'Emergency';
  static const String security = 'Security';
  static const String maintenance = 'Maintenance';
  static const String water = 'Water';
  static const String shuttle = 'Shuttle';

  static const List<String> all = [
    emergency,
    security,
    maintenance,
    water,
    shuttle,
  ];
}

class CommunityContact {
  final int id;
  final String category;
  final String name;
  final String? description;
  final String? phoneNumber;
  final String? secondaryNumber;
  final int sortOrder;

  const CommunityContact({
    required this.id,
    required this.category,
    required this.name,
    this.description,
    this.phoneNumber,
    this.secondaryNumber,
    this.sortOrder = 0,
  });

  factory CommunityContact.fromJson(Map<String, dynamic> json) {
    return CommunityContact(
      id: json['id'] as int,
      category: json['category'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      secondaryNumber: json['secondaryNumber'] as String?,
      sortOrder: (json['sortOrder'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toRequestJson() => {
        'category': category,
        'name': name,
        'description': description,
        'phoneNumber': phoneNumber,
        'secondaryNumber': secondaryNumber,
        'sortOrder': sortOrder,
      };
}
