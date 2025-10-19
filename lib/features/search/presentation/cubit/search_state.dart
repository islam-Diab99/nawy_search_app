import 'package:equatable/equatable.dart';
import '../../data/models/area.dart';
import '../../data/models/compound.dart';
import '../../data/models/property.dart';
import '../../data/models/filter_options.dart';

class SearchState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<Area> areas;
  final List<Compound> compounds;
  final List<Property> allProperties;
  final List<Property> properties;
  final FilterOptions? filterOptions;
  final List<int> selectedAreaIds;
  final List<int> selectedCompoundIds;
  final int? selectedMinPrice;
  final int? selectedMaxPrice;
  final int? selectedMinBedrooms;
  final int? selectedMaxBedrooms;
  final List<String> favorites;
  final bool hasSearched;

  const SearchState({
    this.isLoading = false,
    this.error,
    this.areas = const [],
    this.compounds = const [],
    this.allProperties = const [],
    this.properties = const [],
    this.filterOptions,
    this.selectedAreaIds = const [],
    this.selectedCompoundIds = const [],
    this.selectedMinPrice,
    this.selectedMaxPrice,
    this.selectedMinBedrooms,
    this.selectedMaxBedrooms,
    this.favorites = const [],
    this.hasSearched = false,
  });

  SearchState copyWith({
    bool? isLoading,
    String? error,
    List<Area>? areas,
    List<Compound>? compounds,
    List<Property>? allProperties,
    List<Property>? properties,
    FilterOptions? filterOptions,
    List<int>? selectedAreaIds,
    List<int>? selectedCompoundIds,
    int? selectedMinPrice,
    int? selectedMaxPrice,
    int? selectedMinBedrooms,
    int? selectedMaxBedrooms,
    List<String>? favorites,
    bool? hasSearched,
    bool clearError = false,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      areas: areas ?? this.areas,
      compounds: compounds ?? this.compounds,
      allProperties: allProperties ?? this.allProperties,
      properties: properties ?? this.properties,
      filterOptions: filterOptions ?? this.filterOptions,
      selectedAreaIds: selectedAreaIds ?? this.selectedAreaIds,
      selectedCompoundIds: selectedCompoundIds ?? this.selectedCompoundIds,
      selectedMinPrice: selectedMinPrice ?? this.selectedMinPrice,
      selectedMaxPrice: selectedMaxPrice ?? this.selectedMaxPrice,
      selectedMinBedrooms: selectedMinBedrooms ?? this.selectedMinBedrooms,
      selectedMaxBedrooms: selectedMaxBedrooms ?? this.selectedMaxBedrooms,
      favorites: favorites ?? this.favorites,
      hasSearched: hasSearched ?? this.hasSearched,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    error,
    areas,
    compounds,
    allProperties,
    properties,
    filterOptions,
    selectedAreaIds,
    selectedCompoundIds,
    selectedMinPrice,
    selectedMaxPrice,
    selectedMinBedrooms,
    selectedMaxBedrooms,
    favorites,
    hasSearched,
  ];
}
