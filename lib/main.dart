import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_assets.dart';
import 'core/di/injection_container.dart';
import 'presentation/screens/watch_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final injectionContainer = InjectionContainer();

    return MultiProvider(
      providers: injectionContainer.getProviders(),
      child: MaterialApp(
        title: 'TenTwenty Task',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: AppAssets.fontFamilyPoppins,
          textTheme: ThemeData.light().textTheme.apply(fontFamily: AppAssets.fontFamilyPoppins),
          primarySwatch: Colors.blue,
        ),
        home: const WatchScreen(),
      ),
    );
  }
}
