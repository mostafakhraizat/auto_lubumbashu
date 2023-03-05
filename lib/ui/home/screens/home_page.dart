import 'package:auto_lubumbashi/themes/app_theme.dart';
import 'package:auto_lubumbashi/ui/forms/screens/report_data_input.dart';
import 'package:auto_lubumbashi/ui/forms/screens/saved_forms.dart';
import 'package:auto_lubumbashi/ui/reports/reports_screen/reports_screen.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      backgroundColor: Colors.grey.shade200,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 12,
          ),
          Image.asset(
            "assets/images/logo.png",
            width: 200,
          ),
          const SizedBox(
            height: 32,
          ),
          Row(
            children: const [
              SizedBox(
                width: 22,
              ),
              Text(
                'Welcome to ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                'Auto Lubumbashi',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: MyAppTheme.primaryRed,
                    fontSize: 18),
              ),
            ],
          ),
          const SizedBox(
            height: 32,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (c)=>const FormInputScreen()));
                },
                child: Container(
                  height: 62,
                  width: 320,
                  decoration: BoxDecoration(
                      color: MyAppTheme.primaryRed,
                      borderRadius: BorderRadius.circular(12)),
                  child: Center(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.picture_as_pdf, size: 24, color: Colors.white),
                      SizedBox(
                        width: 12,
                      ),
                      Text(
                        'Generate new Report',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  )),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () async {
                  Navigator.of(context).push(MaterialPageRoute(builder: (c)=>SavedFormsScreen()));
                },
                child: Container(
                  height: 62,
                  width: 320,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.save,
                          size: 24,
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Text(
                          'Check Forms',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: MyAppTheme.primaryRed),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () async {
                  Navigator.of(context).push(MaterialPageRoute(builder: (v)=>GeneratedReports()));
                },
                child: Container(
                  height: 62,
                  width: 320,
                  decoration: BoxDecoration(
                      color: MyAppTheme.primaryRed,
                      borderRadius: BorderRadius.circular(12)),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.history, size: 24, color: Colors.white),
                        SizedBox(
                          width: 12,
                        ),
                        Text(
                          'Reports History',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
