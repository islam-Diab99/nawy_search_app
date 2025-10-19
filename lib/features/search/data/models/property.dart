class Property {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int bedrooms;
  final String? imagePath;
  final int? compoundId;
  final String? compoundName;
  final int? areaId;
  final String? areaName;

  Property({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.bedrooms,
    this.imagePath,
    this.compoundId,
    this.compoundName,
    this.areaId,
    this.areaName,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    final compound = json['compound'] as Map<String, dynamic>?;
    final area = json['area'] as Map<String, dynamic>?;

    return Property(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['slug'] as String?,
      price: (json['min_price'] as num?)?.toDouble() ?? 0.0,
      bedrooms: json['number_of_bedrooms'] as int? ?? 0,
      imagePath: json['image'] as String?,
      compoundId: compound?['id'] as int?,
      compoundName: compound?['name'] as String?,
      areaId: area?['id'] as int?,
      areaName: area?['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'bedrooms': bedrooms,
      'image_path': imagePath,
      'compound_id': compoundId,
      'compound_name': compoundName,
      'area_id': areaId,
      'area_name': areaName,
    };
  }
}
