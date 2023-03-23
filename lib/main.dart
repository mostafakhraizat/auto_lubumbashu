import 'dart:developer';
import 'dart:io';

import 'package:auto_lubumbashi/ui/home/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await checkFiles();
  runApp(  const MyApp());
}

Future<void> checkFiles() async {
  var rootPath = await getApplicationDocumentsDirectory();
  //inputs
  File inputs = File("${rootPath.path}/inputs.json");
  if (inputs.existsSync()) {
    String fileData = inputs.readAsStringSync();
    if(fileData.isEmpty){
      inputs.writeAsString("[]");
    }
  }else{
    log("CREATED");
    File inputs = File("${rootPath.path}/inputs.json");
    inputs.writeAsString("[]");
  }

  //forms
  File forms = File("${rootPath.path}/forms.json");
  if (forms.existsSync()) {
    String fileData = forms.readAsStringSync();
    if(fileData.isEmpty){
      forms.writeAsString("[]");
    }
  }else{
    File forms = File("${rootPath.path}/forms.json");
    forms.writeAsString("[]");

  }

  //reports
  File reports = File("${rootPath.path}/reports.json");
  if (reports.existsSync()) {
    String fileData = reports.readAsStringSync();
    if(fileData.isEmpty){
      reports.writeAsString("[]");
    }
  }else{
    File reports = File("${rootPath.path}/reports.json");
    reports.writeAsString("[]");
  }
}

class MyApp extends StatelessWidget {
   const MyApp({super.key});
    final Color primaryColor = const Color(0xfffe0000);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: createMaterialColor(primaryColor),
      ),
      home: const HomePage(),
    );
  }
  MaterialColor createMaterialColor(Color color) {
    List<int> strengths = <int>[50, 100, 200, 300, 400, 500, 600, 700, 800, 900];
    Map<int, Color> swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (final int strength in strengths) {
      final double opacity = 0.1 + (strength / 1000.0);
      swatch[strength] = Color.fromRGBO(r, g, b, opacity);
    }

    return MaterialColor(color.value, swatch);
  }
}
