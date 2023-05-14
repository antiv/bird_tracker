import 'package:bird_tracker/service/data_service.dart';
import 'package:context_holder/context_holder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'configuration/constants.dart';
import 'home_page.dart';

void main() {
  runApp(ChangeNotifierProvider(create: (BuildContext context) => DataService(),
  child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // on below line we are specifying title of our app
      title: kAppTitle,
      navigatorKey: ContextHolder.key,
      // on below line we are hiding debug banner
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // on below line we are specifying theme
        primarySwatch: Colors.green,
      ),
      // First screen of our app
      home: const HomePage(),
    );
  }
}
