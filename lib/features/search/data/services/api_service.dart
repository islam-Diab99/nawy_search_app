import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/area.dart';
import '../models/compound.dart';
import '../models/property.dart';
import '../models/filter_options.dart';

class ApiService {
  static const String baseUrl =
      'https://hiring-tasks.github.io/mobile-app-apis';

  Future<List<Area>> getAreas() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/areas.json'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Area.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load areas');
      }
    } catch (e) {
      throw Exception('Error fetching areas: $e');
    }
  }

  Future<List<Compound>> getCompounds() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/compounds.json'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Compound.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load compounds');
      }
    } catch (e) {
      throw Exception('Error fetching compounds: $e');
    }
  }

  Future<FilterOptions> getFilterOptions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/properties-get-filter-options.json'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return FilterOptions.fromJson(data);
      } else {
        throw Exception('Failed to load filter options');
      }
    } catch (e) {
      throw Exception('Error fetching filter options: $e');
    }
  }

  Future<List<Property>> searchProperties() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/properties-search.json'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['values'] as List<dynamic>;
        return data.map((json) => Property.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load properties');
      }
    } catch (e) {
      throw Exception('Error fetching properties: $e');
    }
  }
}
