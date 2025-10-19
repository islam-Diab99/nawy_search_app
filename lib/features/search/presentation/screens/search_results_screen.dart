import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nawy_search_app/core/app_colors.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import '../../data/models/property.dart';
import '../../data/models/compound.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_sharp, size: 16),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Results',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF1A1A1A)),
            onPressed: () {
              context.read<SearchCubit>().clearFilters();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (state.properties.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No properties found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your filters',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildActiveFilters(context, state),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPropertiesTab(state),
                    _buildCompoundsTab(state),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'PROPERTIES'),
          Tab(text: 'COMPOUNDS'),
        ],
      ),
    );
  }

  Widget _buildPropertiesTab(SearchState state) {
    if (state.properties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No properties found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.properties.length,
      itemBuilder: (context, index) {
        return _buildPropertyCard(context, state.properties[index], state);
      },
    );
  }

  Widget _buildCompoundsTab(SearchState state) {
    final filteredCompounds = state.selectedCompoundIds.isEmpty
        ? state.compounds
        : state.compounds
              .where((c) => state.selectedCompoundIds.contains(c.id))
              .toList();

    if (filteredCompounds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.apartment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No compounds found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredCompounds.length,
      itemBuilder: (context, index) {
        return _buildCompoundCard(context, filteredCompounds[index], state);
      },
    );
  }

  Widget _buildActiveFilters(BuildContext context, SearchState state) {
    final filters = <String>[];

    if (state.selectedAreaIds.isNotEmpty) {
      final areaNames = state.areas
          .where((a) => state.selectedAreaIds.contains(a.id))
          .map((a) => a.name)
          .join(', ');
      filters.add('Areas: $areaNames');
    }

    if (state.selectedCompoundIds.isNotEmpty) {
      final compoundNames = state.compounds
          .where((c) => state.selectedCompoundIds.contains(c.id))
          .map((c) => c.name)
          .join(', ');
      filters.add('Compounds: $compoundNames');
    }

    if (state.selectedMinPrice != null || state.selectedMaxPrice != null) {
      final minPrice = state.selectedMinPrice != null
          ? '${(state.selectedMinPrice! / 1000).toStringAsFixed(0)}K'
          : '0';
      final maxPrice = state.selectedMaxPrice != null
          ? '${(state.selectedMaxPrice! / 1000).toStringAsFixed(0)}K'
          : '∞';
      filters.add('Price: $minPrice - $maxPrice EGP');
    }

    if (state.selectedMinBedrooms != null ||
        state.selectedMaxBedrooms != null) {
      final minBed = state.selectedMinBedrooms?.toString() ?? 'Any';
      final maxBed = state.selectedMaxBedrooms?.toString() ?? 'Any';
      filters.add('Bedrooms: $minBed - $maxBed');
    }

    if (filters.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 8,
            children: filters.map((filter) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2196F3)),
                ),
                child: Text(
                  filter,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyCard(
    BuildContext context,
    Property property,
    SearchState state,
  ) {
    final isFavorite = context.read<SearchCubit>().isFavorite(
      property.id,
      'property',
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPropertyImage(property),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPriceAndFavorite(context, property, isFavorite),
                const SizedBox(height: 8),
                _buildMonthlyPayment(),
                const SizedBox(height: 12),
                _buildPropertyLocation(property),
                const SizedBox(height: 16),
                _buildPropertyDetails(property),
                const SizedBox(height: 16),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyImage(Property property) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: property.imagePath != null
          ? CachedNetworkImage(
              imageUrl: property.imagePath!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                color: Colors.grey[300],
                child: const Icon(Icons.home, size: 64, color: Colors.grey),
              ),
            )
          : Container(
              height: 200,
              color: Colors.grey[300],
              child: const Icon(Icons.home, size: 64, color: Colors.grey),
            ),
    );
  }

  Widget _buildPriceAndFavorite(
    BuildContext context,
    Property property,
    bool isFavorite,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _formatPrice(property.price),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        GestureDetector(
          onTap: () {
            context.read<SearchCubit>().toggleFavorite(property.id, 'property');
          },
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.grey[400],
            size: 28,
          ),
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    final millions = (price / 1000000).toStringAsFixed(0);
    final thousands = ((price % 1000000) / 1000)
        .toStringAsFixed(0)
        .padLeft(3, '0');
    final units = (price % 1000).toStringAsFixed(0).padLeft(3, '0');
    return 'EGP $millions,$thousands,$units';
  }

  Widget _buildMonthlyPayment() {
    return Text(
      '117,493 EGP/month over 7 years',
      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
    );
  }

  Widget _buildPropertyLocation(Property property) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          property.compoundName ?? 'Unknown Compound',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          property.areaName ?? 'Unknown Area',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildPropertyDetails(Property property) {
    return Row(
      children: [
        _buildDetailItem(Icons.bed_outlined, '${property.bedrooms}'),
        const SizedBox(width: 24),
        _buildDetailItem(Icons.bathroom_outlined, '${property.bedrooms}'),
        const SizedBox(width: 24),
        _buildDetailItem(Icons.straighten, '240-320 m²'),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.videocam,
            label: 'Zoom',
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            icon: Icons.phone,
            label: 'Call',
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            icon: Icons.chat,
            label: 'Whatsapp',
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blue,
        side: const BorderSide(color: Colors.blue),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildCompoundCard(
    BuildContext context,
    Compound compound,
    SearchState state,
  ) {
    final isFavorite = context.read<SearchCubit>().isFavorite(
      compound.id,
      'compound',
    );

    final area = state.areas.firstWhere(
      (a) => a.id == compound.areaId,
      orElse: () => state.areas.first,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCompoundImageWithFavorite(context, compound, isFavorite),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCompoundName(compound),
                const SizedBox(height: 8),
                _buildCompoundLocation(area),
                const SizedBox(height: 16),
                _buildViewDetailsButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompoundImageWithFavorite(
    BuildContext context,
    Compound compound,
    bool isFavorite,
  ) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: compound.imagePath != null
              ? CachedNetworkImage(
                  imageUrl: compound.imagePath!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.apartment,
                      size: 64,
                      color: Colors.grey,
                    ),
                  ),
                )
              : Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.apartment,
                    size: 64,
                    color: Colors.grey,
                  ),
                ),
        ),
        _buildFavoriteButton(context, compound.id, 'compound', isFavorite),
      ],
    );
  }

  Widget _buildFavoriteButton(
    BuildContext context,
    int id,
    String type,
    bool isFavorite,
  ) {
    return Positioned(
      top: 12,
      right: 12,
      child: GestureDetector(
        onTap: () {
          context.read<SearchCubit>().toggleFavorite(id, type);
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
            ],
          ),
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.grey[400],
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildCompoundName(Compound compound) {
    return Text(
      compound.name,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A1A),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCompoundLocation(dynamic area) {
    return Row(
      children: [
        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          area.name,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildViewDetailsButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Text(
          'View Compound Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
