import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _favoritesKey = 'favorites';

  Future<void> saveFavorite(int id, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    final key = '${type}_$id';

    if (!favorites.contains(key)) {
      favorites.add(key);
      await prefs.setStringList(_favoritesKey, favorites);
    }
  }

  Future<void> removeFavorite(int id, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    final key = '${type}_$id';

    favorites.remove(key);
    await prefs.setStringList(_favoritesKey, favorites);
  }

  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  Future<bool> isFavorite(int id, String type) async {
    final favorites = await getFavorites();
    final key = '${type}_$id';
    return favorites.contains(key);
  }
}
