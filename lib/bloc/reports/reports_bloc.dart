import 'dart:convert';
import 'dart:io';
import 'package:auto_lubumbashi/ui/reports/reports_screen/reports_screen.dart';
import 'package:path/path.dart' as path;
import 'package:auto_lubumbashi/models/form_item.dart';
import 'package:auto_lubumbashi/models/report.dart';
import 'package:auto_lubumbashi/themes/app_theme.dart';
import 'package:auto_lubumbashi/ui/pdf/pdf_screen.dart';
import 'package:auto_lubumbashi/view_models/form_input_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

part 'reports_event.dart';

part 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  ReportsBloc() : super(ReportsInitial()) {
    on<ReportScreenInitialEvent>((event, emit) async {
      emit(ReportsListSuccessState(await allReports()));
    });
    on<DeleteReportEvent>((event, emit) async{
      var reports = await allReports();
      reports.removeWhere((element) => element.path==event.reportPath);
      writeReports(reports);
      emit(ReportsInitial());
    });
    on<GenerateReportEvent>((event, emit) async {
      showDialog(
          context: event.context,
          builder: (c) {
            return AlertDialog(
              content: Container(
                height: 42,
                color: Colors.white,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(
                      color: MyAppTheme.primaryRed,
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Text(
                      "Generating...",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          });

      await Future.delayed(const Duration(seconds: 1));
      try {
        var image = await logoImage();
        File? file =
            await generatePDF1(image, event.context, event.formInputViewModel);
        if (file != null) {
          List<Report> reports = await allReports();

          Report report = Report(
              dnn: event.formInputViewModel.formInput.dnn.toString(),
              date: DateTime.now().toString(),
              path: file.path);
          reports.add(report);
          writeReports(reports);

          Navigator.pop(event.context);
          ScaffoldMessenger.of(event.context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 5),
              content: const Text(
                "Report generated successfully",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.black,
              action: SnackBarAction(
                onPressed: () async {
                  Navigator.of(event.context).push(
                      MaterialPageRoute(builder: (c) => GeneratedReports()));
                },
                label: 'All Reports',
                textColor: Colors.white,
              ),
            ),
          );
          Navigator.of(event.context).push(MaterialPageRoute(
              builder: (c) => PDFScreen(pdf: file, title: 'PDF Viewer')));
        } else {
          Navigator.of(event.context).pop();
          ScaffoldMessenger.of(event.context).showSnackBar(const SnackBar(
              content: Text('Failed to generate PDF, please try again!')));
        }
      } catch (e, s) {
        print(s);
        Navigator.of(event.context).pop();
      }
    });
  }

  Future<bool> writeReports(List<Report> reports) async {
    try {
      var rootPath = await getApplicationDocumentsDirectory();
      File file = File("${rootPath.path}/reports.json");
      file.writeAsString(jsonEncode(reports));
      return true;
    } catch (e, s) {
      print(s);
      return false;
    }
  }

  Future<Uint8List> logoImage() async {
    final imageData = await rootBundle.load('assets/images/logo.png');
    return imageData.buffer.asUint8List();
  }

  static ReportsBloc instance(context) => BlocProvider.of(context);

  Future<List<Report>> allReports() async {
    var rootPath = await getApplicationDocumentsDirectory();
    File forms = File("${rootPath.path}/reports.json");
    //read forms in string var
    String formsDataString = forms.readAsStringSync();
    //convert the json list into FormData List
    Iterable iter = jsonDecode(formsDataString);
    //data list is all forms in forms.json
    List<Report> reports =
        List<Report>.from(iter.map((model) => Report.fromJson(model)));
    return reports;
  }

  Future<File?> generatePDF1(
      image, context, FormInputViewModel formInputViewModel) async {
    final pdf = pw.Document();
    try {
      List<pw.Widget> widgets = [];
      var header = pw.Container(
        width: MediaQuery.of(context).size.width * 2.0,
        height: 240,
        decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColor.fromHex("000000"))),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
          children: [
            pw.Expanded(
              flex: 3,
              child: pw.Container(
                  decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColor.fromHex("000000"))),
                  child: pw.Center(
                      child: pw.Image(pw.MemoryImage(image),
                          width: 140, height: 140))),
            ),
            pw.Expanded(
              flex: 3,
              child: pw.Container(
                  decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColor.fromHex("000000"))),
                  child: pw.Center(
                      child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                        // pw.Text("Cylinder Inspection",
                        //     style: pw.TextStyle(
                        //         fontWeight: pw.FontWeight.bold, fontSize: 18)),
                        pw.SizedBox(height: 32),
                        pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Flexible(
                                child: pw.Text("Detailed Work in Progress",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 18)),
                              )
                            ])
                      ]))),
            ),
            pw.Expanded(
              flex: 5,
              child: pw.Container(
                  decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColor.fromHex("000000"))),
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 12),
                    child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Row(children: [
                            pw.Text("DNN: ",
                                style: pw.TextStyle(
                                    fontSize: 16,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text(
                                "${formInputViewModel.formInput.dnn.toString()}",
                                style: const pw.TextStyle(
                                  fontSize: 14,
                                )),
                          ]),
                          pw.Row(children: [
                            pw.Text("Site Name: ",
                                style: pw.TextStyle(
                                    fontSize: 16,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text(
                                formInputViewModel.formInput.siteName
                                    .toString(),
                                style: const pw.TextStyle(
                                  fontSize: 14,
                                )),
                          ]),
                          pw.Row(children: [
                            pw.Text("Customer Name: ",
                                style: pw.TextStyle(
                                    fontSize: 16,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text(
                                formInputViewModel.formInput.customer
                                    .toString(),
                                style: const pw.TextStyle(
                                  fontSize: 14,
                                )),
                          ]),
                          pw.Row(children: [
                            pw.Text("Hose Assembler: ",
                                style: pw.TextStyle(
                                    fontSize: 16,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text(
                                formInputViewModel.formInput.hoseAssembler
                                    .toString(),
                                style: const pw.TextStyle(
                                  fontSize: 14,
                                )),
                          ]),
                          pw.Row(children: [
                            pw.Text("Requisition Number: ",
                                style: pw.TextStyle(
                                    fontSize: 16,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.FittedBox(
                                child: pw.Text(
                                    formInputViewModel.formInput.requisitionNb
                                        .toString(),
                                    style: const pw.TextStyle(
                                      fontSize: 14,
                                    )),
                                fit: pw.BoxFit.contain)
                          ]),
                          pw.Row(children: [
                            pw.Text("Date: ",
                                style: pw.TextStyle(
                                    fontSize: 16,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text(
                                formInputViewModel.formInput.date.toString(),
                                style: const pw.TextStyle(
                                  fontSize: 14,
                                )),
                          ]),
                        ]),
                  )),
            ),
          ],
        ),
      );
      widgets.add(header);
      widgets.add(pw.SizedBox(height: 36));

      pdf.addPage(pw.MultiPage(
          pageFormat: PdfPageFormat.a3, build: (context) => widgets));

      for (var item in formInputViewModel.formData.formItems) {
        List<pw.Widget> widgets = [];

        var itemDescription =
            pw.Column(mainAxisSize: pw.MainAxisSize.max, children: [
          pw.Row(children: [
            pw.Text(
                "${formInputViewModel.formData.formItems.indexOf(item) + 1} ",
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 15)),
            pw.Text("${item.description} ",
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
          ])
        ]);
        widgets.add(itemDescription);
        widgets.add(pw.SizedBox(height: 22));
        var images = await pdfItemImages(
            item.oldImagePath.toString(), item.newImagePath.toString());

        try {
          if(images.length>0){
            var oldImage = images.first;
            var oldImageWidget = pw.Column(children: [
              pw.Text("Old Image ",
                  style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 15)),
              pw.SizedBox(height: 6),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                pw.Center(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Image(
                          pw.MemoryImage(
                            (oldImage.imagesData),
                          ),
                          width: 660,
                          height: 400,
                          fit: pw.BoxFit.contain),
                    ))
              ])
            ]);
            widgets.add(oldImageWidget);
          }




          if(images.length>1){

            var newImage = images.last;

            var newImageWidget = pw.Column(children: [
              pw.Text("New Image ",
                  style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 15)),
              pw.SizedBox(height: 6),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                pw.Center(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Image(
                          pw.MemoryImage(
                            (newImage.imagesData),
                          ),
                          width: 660,
                          height: 400,
                          fit: pw.BoxFit.contain),
                    ))
              ])
            ]);
            widgets.add(newImageWidget);
          }
        } catch (e, s) {
          print(s);
          print(e);
        }

        widgets.add(pw.SizedBox(height: 22));
        widgets.add(pw.Divider());
        pdf.addPage(pw.MultiPage(
            pageFormat: PdfPageFormat.a3, build: (context) => widgets));
      }

      // pdf.addPage(pw.MultiPage(
      //     pageFormat: PdfPageFormat.a3,
      //     build: (pw.Context context) => widgets));
      final directory = await getExternalStorageDirectory();
      String newPath = path.join(directory!.path,
          "PDF-${formInputViewModel.formInput.dnn.toString()}_${DateTime.now().toString()}.pdf");
      final file = File(newPath);
      await file.writeAsBytes(await pdf.save());
      return file;
    } catch (e, s) {
      print(e);
      print(s);
    }
    return null;
  }

  Future<List<PDFItemImages>> pdfItemImages(
      String oldImage, String newImage) async {
    List<PDFItemImages> imagesData = [];

    if (oldImage.isNotEmpty) {
      var decodedOldImage =
          await decodeImageFromList(File(oldImage).readAsBytesSync());
      PDFItemImages oldImageFile = PDFItemImages(
        width: 0,
        imagesData: File(oldImage).readAsBytesSync(),
        height: 0,
      );

      int oldWidth = decodedOldImage.width;
      int oldHeight = decodedOldImage.height;
      oldImageFile.height = oldHeight;
      oldImageFile.width = oldWidth;
      imagesData.add(oldImageFile);
    }

    if (newImage.isNotEmpty) {
      var decodedNewImage =
          await decodeImageFromList(File(newImage).readAsBytesSync());
      PDFItemImages newImageFile = PDFItemImages(
        width: 0,
        imagesData: File(newImage).readAsBytesSync(),
        height: 0,
      );
      int newWidth = decodedNewImage.width;
      int newHeight = decodedNewImage.height;
      newImageFile.height = newHeight;
      newImageFile.width = newWidth;
      imagesData.add(newImageFile);
    }

    return imagesData;
  }
}

class PDFItemImages {
  Uint8List imagesData;
  int height;
  int width;

  PDFItemImages(
      {required this.imagesData, required this.height, required this.width});
}

class ItemWidgets {
  String description;
  String oldImage;
  String newImage;

  ItemWidgets(this.oldImage, this.description, this.newImage);
}

class PdfImages {
  List<Uint8List>? imagesData;
  int? index;

  PdfImages({this.index, this.imagesData});
}
