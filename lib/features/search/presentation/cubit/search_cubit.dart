import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/api_service.dart';
import '../../data/services/cache_service.dart';
import '../../data/models/property.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final ApiService apiService;
  final CacheService cacheService;

  SearchCubit({required this.apiService, required this.cacheService})
    : super(const SearchState());

  Future<void> initialize() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final areas = await apiService.getAreas();
      final compounds = await apiService.getCompounds();
      final filterOptions = await apiService.getFilterOptions();
      final favorites = await cacheService.getFavorites();
      final allProperties = await apiService.searchProperties();

      emit(
        state.copyWith(
          isLoading: false,
          areas: areas,
          compounds: compounds,
          filterOptions: filterOptions,
          favorites: favorites,
          allProperties: allProperties,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void toggleAreaSelection(int areaId) {
    final selectedAreas = List<int>.from(state.selectedAreaIds);
    if (selectedAreas.contains(areaId)) {
      selectedAreas.remove(areaId);
    } else {
      selectedAreas.add(areaId);
    }
    emit(state.copyWith(selectedAreaIds: selectedAreas));
  }

  void toggleCompoundSelection(int compoundId) {
    final selectedCompounds = List<int>.from(state.selectedCompoundIds);
    if (selectedCompounds.contains(compoundId)) {
      selectedCompounds.remove(compoundId);
    } else {
      selectedCompounds.add(compoundId);
    }
    emit(state.copyWith(selectedCompoundIds: selectedCompounds));
  }

  void setPriceRange(int? minPrice, int? maxPrice) {
    emit(
      state.copyWith(selectedMinPrice: minPrice, selectedMaxPrice: maxPrice),
    );
  }

  void setBedroomRange(int? minBedrooms, int? maxBedrooms) {
    emit(
      state.copyWith(
        selectedMinBedrooms: minBedrooms,
        selectedMaxBedrooms: maxBedrooms,
      ),
    );
  }

  Future<void> searchProperties() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      List<Property> filteredProperties = List.from(state.allProperties);

      if (state.selectedAreaIds.isNotEmpty) {
        filteredProperties = filteredProperties
            .where((p) => state.selectedAreaIds.contains(p.areaId))
            .toList();
      }

      if (state.selectedCompoundIds.isNotEmpty) {
        filteredProperties = filteredProperties
            .where((p) => state.selectedCompoundIds.contains(p.compoundId))
            .toList();
      }

      if (state.selectedMinBedrooms != null) {
        filteredProperties = filteredProperties
            .where((p) => p.bedrooms >= state.selectedMinBedrooms!)
            .toList();
      }
      if (state.selectedMaxBedrooms != null) {
        filteredProperties = filteredProperties
            .where((p) => p.bedrooms <= state.selectedMaxBedrooms!)
            .toList();
      }

      if (state.selectedMinPrice != null) {
        filteredProperties = filteredProperties
            .where((p) => p.price >= state.selectedMinPrice!)
            .toList();
      }
      if (state.selectedMaxPrice != null) {
        filteredProperties = filteredProperties
            .where((p) => p.price <= state.selectedMaxPrice!)
            .toList();
      }

      emit(
        state.copyWith(
          isLoading: false,
          properties: filteredProperties,
          hasSearched: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> toggleFavorite(int id, String type) async {
    final key = '${type}_$id';
    final favorites = List<String>.from(state.favorites);

    if (favorites.contains(key)) {
      await cacheService.removeFavorite(id, type);
      favorites.remove(key);
    } else {
      await cacheService.saveFavorite(id, type);
      favorites.add(key);
    }

    emit(state.copyWith(favorites: favorites));
  }

  bool isFavorite(int id, String type) {
    final key = '${type}_$id';
    return state.favorites.contains(key);
  }

  void clearFilters() {
    emit(
      state.copyWith(
        selectedAreaIds: [],
        selectedCompoundIds: [],
        selectedMinPrice: null,
        selectedMaxPrice: null,
        selectedMinBedrooms: null,
        selectedMaxBedrooms: null,
        properties: [],
        hasSearched: false,
      ),
    );
  }
}
