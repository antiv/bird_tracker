import 'package:ciconia_tracker/service/data_service.dart';
import 'package:context_holder/context_holder.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'configuration/constants.dart';
import 'home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(ChangeNotifierProvider(
      create: (BuildContext context) => DataService(), child: EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn', countryCode: 'RS')],
      path: 'assets/translations',
      startLocale: const Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn', countryCode: 'RS'),
      fallbackLocale: const Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn', countryCode: 'RS'),
      child: const MyApp())));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Map<int, Color> get kSwatchGreen => {
        50: const Color(0xff7bc9a3),
        100: const Color(0xff6fc49b),
        200: const Color(0xff57ba8a),
        300: const Color(0xff3fb179),
        400: const Color(0xff27a769),
        500: const Color(0xff0f9d58),
        600: const Color(0xff0d8d4f),
        700: const Color(0xff0c7e46),
        800: const Color(0xff0a6e3e),
        900: const Color(0xff095e35)
      };

  @override
  Widget build(BuildContext context) {
    DataService().mapType ??= MapType.satellite;
    return MaterialApp(
      // on below line we are specifying title of our app
      title: kAppTitle,
      navigatorKey: ContextHolder.key,
      // on below line we are hiding debug banner
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // on below line we are specifying theme
        // primarySwatch: Colors.green,
        // primaryColor: Colors.green,
        colorScheme: ColorScheme.fromSwatch(
            primarySwatch: MaterialColor(0xFF0F9D58, kSwatchGreen)),
        useMaterial3: true,
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      // First screen of our app
      home: const HomePage(),
    );
  }
}
