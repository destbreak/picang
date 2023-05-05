import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'widget/object_recognizer.dart';

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );

    return const MaterialApp(
      title: 'Picang',
      home: ObjectRecognizer(),
      debugShowCheckedModeBanner: false,
    );
  }
}