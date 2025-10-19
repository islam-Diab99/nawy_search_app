import 'package:get_it/get_it.dart';
import '../features/search/data/services/api_service.dart';
import '../features/search/data/services/cache_service.dart';
import '../features/search/presentation/cubit/search_cubit.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  sl.registerLazySingleton<ApiService>(() => ApiService());
  sl.registerLazySingleton<CacheService>(() => CacheService());

  sl.registerFactory<SearchCubit>(
    () => SearchCubit(
      apiService: sl<ApiService>(),
      cacheService: sl<CacheService>(),
    ),
  );
}
