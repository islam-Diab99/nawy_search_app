class FilterOptions {
  final int minBedrooms;
  final int maxBedrooms;
  final List<int> minPriceList;
  final List<int> maxPriceList;

  FilterOptions({
    required this.minBedrooms,
    required this.maxBedrooms,
    required this.minPriceList,
    required this.maxPriceList,
  });

  factory FilterOptions.fromJson(Map<String, dynamic> json) {
    return FilterOptions(
      minBedrooms: json['min_bedrooms'] as int,
      maxBedrooms: json['max_bedrooms'] as int,
      minPriceList: (json['min_price_list'] as List)
          .map((e) => (e as num).toInt())
          .toList(),
      maxPriceList: (json['max_price_list'] as List)
          .map((e) => (e as num).toInt())
          .toList(),
    );
  }
}
