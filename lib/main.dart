import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nawy_search_app/core/app_colors.dart';
import 'package:nawy_search_app/core/service_locator.dart';
import 'features/search/presentation/cubit/search_cubit.dart';
import 'features/Home/presentation/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SearchCubit>()..initialize(),
      child: MaterialApp(
        title: 'Nawy Search',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          useMaterial3: true,
          fontFamily: 'SF Pro Text',
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
