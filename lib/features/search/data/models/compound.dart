class Compound {
  final int id;
  final int areaId;
  final String name;
  final String? imagePath;

  Compound({
    required this.id,
    required this.areaId,
    required this.name,
    this.imagePath,
  });

  factory Compound.fromJson(Map<String, dynamic> json) {
    return Compound(
      id: json['id'] as int,
      areaId: json['area_id'] as int,
      name: json['name'] as String,
      imagePath: json['image_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'area_id': areaId, 'name': name, 'image_path': imagePath};
  }
}
