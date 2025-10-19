import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nawy_search_app/core/app_colors.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import 'search_results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Search',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          if (state.isLoading && state.areas.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildSearchBar(context, state),
                const SizedBox(height: 24),
                _buildAreaSection(context, state),
                const SizedBox(height: 24),
                _buildCompoundSection(context, state),
                const SizedBox(height: 24),
                _buildPriceRangeSection(context, state),
                const SizedBox(height: 24),
                _buildBedroomsSection(context, state),
                const SizedBox(height: 32),
                _buildSearchButton(context, state),
                if (state.error != null) ...[
                  const SizedBox(height: 16),
                  Text(state.error!, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, SearchState state) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Area, Compound, Developer',
          prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildAreaSection(BuildContext context, SearchState state) {
    final searchQuery = _searchController.text.toLowerCase().trim();

    if (searchQuery.isEmpty && state.selectedAreaIds.isEmpty) {
      return const SizedBox.shrink();
    }

    final filteredAreas = searchQuery.isEmpty
        ? state.areas
              .where((area) => state.selectedAreaIds.contains(area.id))
              .toList()
        : state.areas
              .where((area) => area.name.toLowerCase().contains(searchQuery))
              .take(10)
              .toList();

    if (filteredAreas.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              searchQuery.isEmpty ? 'Selected Areas' : 'Areas',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            if (searchQuery.isNotEmpty)
              Text(
                '${filteredAreas.length} found',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filteredAreas.map((area) {
            final isSelected = state.selectedAreaIds.contains(area.id);
            return GestureDetector(
              onTap: () {
                context.read<SearchCubit>().toggleAreaSelection(area.id);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  area.name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCompoundSection(BuildContext context, SearchState state) {
    final searchQuery = _searchController.text.toLowerCase().trim();

    if (searchQuery.isEmpty && state.selectedCompoundIds.isEmpty) {
      return const SizedBox.shrink();
    }

    final filteredCompounds = searchQuery.isEmpty
        ? state.compounds
              .where(
                (compound) => state.selectedCompoundIds.contains(compound.id),
              )
              .toList()
        : state.compounds
              .where(
                (compound) => compound.name.toLowerCase().contains(searchQuery),
              )
              .take(10)
              .toList();

    if (filteredCompounds.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              searchQuery.isEmpty ? 'Selected Compounds' : 'Compounds',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            if (searchQuery.isNotEmpty)
              Text(
                '${filteredCompounds.length} found',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filteredCompounds.map((compound) {
            final isSelected = state.selectedCompoundIds.contains(compound.id);
            return GestureDetector(
              onTap: () {
                context.read<SearchCubit>().toggleCompoundSelection(
                  compound.id,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  compound.name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceRangeSection(BuildContext context, SearchState state) {
    if (state.filterOptions == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price Range',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPriceDropdown(
                context,
                'Min Price',
                state.selectedMinPrice,
                state.filterOptions!.minPriceList,
                (value) {
                  context.read<SearchCubit>().setPriceRange(
                    value,
                    state.selectedMaxPrice,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPriceDropdown(
                context,
                'Max Price',
                state.selectedMaxPrice,
                state.filterOptions!.maxPriceList,
                (value) {
                  context.read<SearchCubit>().setPriceRange(
                    state.selectedMinPrice,
                    value,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceDropdown(
    BuildContext context,
    String hint,
    int? selectedValue,
    List<int> options,
    Function(int?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          hint: Text(hint),
          value: selectedValue,
          items: [
            DropdownMenuItem<int>(
              value: null,
              child: Text('Any', style: TextStyle(color: Colors.grey[600])),
            ),
            ...options.map(
              (price) => DropdownMenuItem<int>(
                value: price,
                child: Text('${(price / 1000).toStringAsFixed(0)}K EGP'),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildBedroomsSection(BuildContext context, SearchState state) {
    if (state.filterOptions == null) return const SizedBox.shrink();

    final minBedrooms = state.filterOptions!.minBedrooms.toDouble();
    final maxBedrooms = state.filterOptions!.maxBedrooms.toDouble();

    final currentStart = state.selectedMinBedrooms?.toDouble() ?? minBedrooms;
    final currentEnd = state.selectedMaxBedrooms?.toDouble() ?? maxBedrooms;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Rooms',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF1A1A1A),
              ),
            ),
            Text(
              (state.selectedMinBedrooms != null ||
                      state.selectedMaxBedrooms != null)
                  ? '${state.selectedMinBedrooms ?? state.filterOptions!.minBedrooms} - ${state.selectedMaxBedrooms ?? state.filterOptions!.maxBedrooms}+ Rooms'
                  : '4 ~ 6+ Rooms',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600]!,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '${state.filterOptions!.minBedrooms}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.primary.withOpacity(.1),
                  thumbColor: AppColors.primary,
                  overlayColor: AppColors.primary.withOpacity(0.2),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 20,
                  ),
                  rangeThumbShape: const RoundRangeSliderThumbShape(
                    enabledThumbRadius: 10,
                  ),
                  rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
                ),
                child: RangeSlider(
                  values: RangeValues(currentStart, currentEnd),
                  min: minBedrooms,
                  max: maxBedrooms,
                  divisions: (maxBedrooms - minBedrooms).toInt(),
                  onChanged: (RangeValues values) {
                    context.read<SearchCubit>().setBedroomRange(
                      values.start.toInt(),
                      values.end.toInt(),
                    );
                  },
                ),
              ),
            ),
            Text(
              '${state.filterOptions!.maxBedrooms}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchButton(BuildContext context, SearchState state) {
    return ElevatedButton(
      onPressed: state.isLoading
          ? null
          : () async {
              await context.read<SearchCubit>().searchProperties();
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchResultsScreen(),
                  ),
                );
              }
            },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: state.isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text(
              'Show Results',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
    );
  }
}
