import 'dart:io';
import 'dart:math';
import 'package:auto_lubumbashi/bloc/reports/reports_bloc.dart';
import 'package:auto_lubumbashi/themes/app_theme.dart';
import 'package:auto_lubumbashi/ui/pdf/pdf_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

class GeneratedReports extends StatefulWidget {
  const GeneratedReports({Key? key}) : super(key: key);

  @override
  State<GeneratedReports> createState() => _GeneratedReportsState();
}

class _GeneratedReportsState extends State<GeneratedReports> {
  String input = "";

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReportsBloc(),
      child: BlocConsumer<ReportsBloc, ReportsState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          if (state is ReportsInitial) {
            ReportsBloc.instance(context).add(ReportScreenInitialEvent());
          }
          return Scaffold(
            backgroundColor: Colors.grey.shade200,
            appBar: AppBar(
              elevation: 0,
              title: const Text('Generated Reports'),
            ),
            body: Builder(builder: (context) {
              if (state is ReportsListSuccessState) {
                if (state.reports.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.hourglass_empty,
                        size: 42,
                        color: MyAppTheme.primaryRed,
                      ),
                      const SizedBox(
                        height: 22,
                      ),
                      const Text(
                        'No Generated Reports Yet',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(
                        height: 42,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 62,
                            width: 320,
                            decoration: BoxDecoration(
                                color: MyAppTheme.primaryRed,
                                borderRadius: BorderRadius.circular(12)),
                            child: Center(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.sync,
                                  size: 24,
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                Text(
                                  'Sync Server',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            )),
                          )
                        ],
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      TextFormField(
                        onChanged: (value) {
                          setState(() {
                            input = value;
                          });
                        },
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.only(left: 20),
                            hintText: 'Search Reports'),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            if (state.reports
                                .elementAt(index)
                                .dnn
                                .contains(input)) {
                              return ListTile(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (c) => PDFScreen(
                                          pdf: File(state.reports
                                              .elementAt(index)
                                              .path),
                                          title:
                                              "${state.reports.elementAt(index).dnn}-${state.reports.elementAt(index).siteName.toString()}_${state.reports.elementAt(index).date.toString()}")));
                                },
                                title: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: Row(
                                    children: [
                                      Builder(builder: (context) {
                                        final f = DateFormat('dd-MM-yyyy');
                                        return Flexible(
                                          child: Text(

                                            "${state.reports.elementAt(index).dnn}-${state.reports.elementAt(index).siteName.toString()}_${state.reports.elementAt(index).date.substring(0,10).toString()}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      })
                                    ],
                                  ),
                                ),
                                subtitle: Text(formatBytes(
                                        File(state.reports
                                                .elementAt(index)
                                                .path)
                                            .lengthSync(),
                                        2)
                                    .toString()),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                        onTap: () async {
                                          File result = File(state.reports
                                              .elementAt(index)
                                              .path);
                                          await FlutterShare.shareFile(
                                            title:
                                                '#${(state.reports.elementAt(index).dnn).toString()}',
                                            text: 'Share Report',
                                            filePath: result.path,
                                          );
                                        },
                                        child: const Icon(
                                          Icons.share,
                                          color: MyAppTheme.primaryRed,
                                        )),
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    InkWell(
                                        onTap: () async {
                                          print(
                                              "Deleted: ${state.reports.elementAt(index).path}");
                                          ReportsBloc.instance(context).add(
                                              DeleteReportEvent(state.reports
                                                  .elementAt(index)
                                                  .path));
                                        },
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        )),
                                  ],
                                ),
                                leading: Container(
                                  height: 36,
                                  width: 36,
                                  decoration: BoxDecoration(
                                      color: MyAppTheme.primaryRed,
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Center(
                                    child: Text(
                                      "${index + 1}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Container();
                            }
                          },
                          itemCount: state.reports.length,
                        ),
                      ),
                    ],
                  );
                }
              }
              return Container();
            }),
          );
        },
      ),
    );
  }

  static String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
// }
}
