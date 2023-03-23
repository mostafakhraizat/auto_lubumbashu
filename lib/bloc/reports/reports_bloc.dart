import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';
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
      emit(ReportsListSuccessState((await allReports()).reversed.toList()));
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
              path: file.path,
          siteName: event.formInputViewModel.formInput.siteName.toString()
          );
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
                      MaterialPageRoute(builder: (c) => const GeneratedReports()));
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
        height: 120,
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
                          width: 100, height: 100))),
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

                        pw.SizedBox(height: 14),
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
                                formInputViewModel.formInput.dnn.toString(),
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


      ///deliver note image

      if(formInputViewModel.formData.deliverNoteNumber!=null &&formInputViewModel.formData.deliverNoteNumber !="" ){
        widgets.add(pw.Text("Deliver Note Number",
            style:
            pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 15)));
        widgets.add(pw.SizedBox(height: 32));
        widgets.add(pw.Center(
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Image(
                pw.MemoryImage(
                  (File(formInputViewModel.formData.deliverNoteNumber.toString()).readAsBytesSync()),
                ),
                height: 580,
                fit: pw.BoxFit.contain
              ),
            )));


        pdf.addPage(pw.MultiPage(
            pageFormat: PdfPageFormat.a4.copyWith(
              marginRight: 14,
              marginLeft: 14,
              marginBottom: 14,
              marginTop: 12,
            ), build: (context) => widgets));
      }




      ///requisition added images
      List<pw.Widget> requisitionImagesWidgets = [];
      if(formInputViewModel.formData.requisitionImages.isNotEmpty){
        requisitionImagesWidgets.add(pw.Text("Requisition/Work Order",
            style:
            pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 15)));

        if(formInputViewModel.formData.requisitionImages.first.toString()!="null"
            && formInputViewModel.formData.requisitionImages.first.toString()!=""){
          var requisitionImagesWidget = pw.Column(children: [

            pw.SizedBox(height: 6),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
              pw.Center(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Image(
                        pw.MemoryImage(
                          (File(formInputViewModel.formData.requisitionImages.first).readAsBytesSync()),
                        ),
                        height: 680,
                        width: 440,
                        fit: pw.BoxFit.contain),
                  ))
            ])
          ]);
          requisitionImagesWidgets.add(requisitionImagesWidget);
        }





        pdf.addPage(pw.MultiPage(
            pageFormat: PdfPageFormat.a4.copyWith(
              marginRight: 14,
              marginLeft: 14,
              marginBottom: 14,
              marginTop: 12,
            ), build: (context) => requisitionImagesWidgets));
      }



      for (FormItem item in formInputViewModel.formData.formItems) {
        List<pw.Widget> widgets = [];

        var itemDescription =
            pw.Column(mainAxisSize: pw.MainAxisSize.max, children: [
          pw.Row(children: [
            pw.Text(
                "${formInputViewModel.formData.formItems.indexOf(item) + 1}- ",
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
            item.oldImages, item.newImages);


        if(images.oldImages.isNotEmpty){
          for(var oldImageUInt8List in images.oldImages){
            var oldImageWidget = pw.Column(children: [
              pw.Builder(builder: (v){
                if(oldImageUInt8List==images.oldImages.first){
                  return  pw.Text("Old Hoses ",
                      style:
                      pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 15));
                }else{
                  return pw.Container();
                }
              }),
              pw.SizedBox(height: 6),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                pw.Center(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Image(
                          pw.MemoryImage(
                            (oldImageUInt8List.imagesData),
                          ),
                          width: 660,
                          height: 400,
                          fit: pw.BoxFit.contain),
                    ))
              ])
            ]);
            widgets.add(oldImageWidget);
          }


        }



        pdf.addPage(pw.MultiPage(
            pageFormat: PdfPageFormat.a4.copyWith(
              marginRight: 14,
              marginLeft: 14,
              marginBottom: 14,
              marginTop: 12,
            ), build: (context) => widgets));

        List<pw.Widget> newImagesWidgets = [];

        if(images.newImages.isNotEmpty){
          for(var newImageUInt8List in images.newImages){
            var newImageWidget = pw.Column(children: [
              pw.Builder(builder: (v){
                if(newImageUInt8List==images.newImages.first){

                  return  pw.Text("New Hoses ",
                      style:
                      pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 15));
                }else{
                  return pw.Container();
                }
              }),

              pw.SizedBox(height: 6),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                pw.Center(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Image(
                          pw.MemoryImage(
                            (newImageUInt8List.imagesData),
                          ),
                          width: 660,
                          height: 400,
                          fit: pw.BoxFit.contain),
                    ))
              ])
            ]);
            newImagesWidgets.add(newImageWidget);
          }
        }
        newImagesWidgets.add(pw.SizedBox(height: 22));
        pdf.addPage(pw.MultiPage(
            pageFormat: PdfPageFormat.a4.copyWith(
                marginRight: 14,
                marginLeft: 14,
                marginBottom: 14,
                marginTop: 12,
            ), build: (context) => newImagesWidgets));
      }

      ///reportTests added images
      List<pw.Widget> reportTestsImagesWidgets = [];
      if(formInputViewModel.formData.testsProjectImages.isNotEmpty){
        reportTestsImagesWidgets.add(pw.Text("Test Reports",
            style:
            pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 15)));
      }

      for(String reportTestsImagesItem in (formInputViewModel.formData.testsProjectImages??[])){
        if(reportTestsImagesItem.isNotEmpty){


            var reportTestsImagesWidget = pw.Column(children: [

              pw.SizedBox(height: 6),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                pw.Center(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Image(
                          pw.MemoryImage(
                            (File(reportTestsImagesItem).readAsBytesSync()),
                          ),
                          width: 660,
                          height: 400,
                          fit: pw.BoxFit.contain),
                    ))
              ])
            ]);
            reportTestsImagesWidgets.add(reportTestsImagesWidget);
        }
      }
      pdf.addPage(pw.MultiPage(
          pageFormat: PdfPageFormat.a4.copyWith(
              marginRight: 14,
              marginLeft: 8,
              marginBottom: 8,
              marginTop: 12,
          ), build: (context) => reportTestsImagesWidgets));




      final directory = await getExternalStorageDirectory();
      String newPath = path.join(directory!.path,
          "${formInputViewModel.formInput.dnn}-${formInputViewModel.formInput.siteName.toString()}_${formInputViewModel.formInput.date.toString()}.pdf");
      final file = File(newPath);
      await file.writeAsBytes(await pdf.save());
      return file;
    } catch (e, s) {
      print(e);
      print(s);
    }
    return null;
  }


  
  
  Future<DataImagesModel> pdfItemImages(
      List<String> oldImages, List<String> newImages) async {
    List<PDFItemImages> oldImagesData = [];
    List<PDFItemImages> newImagesData = [];

      ////



    for(var oldImage in oldImages){
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
      oldImagesData.add(oldImageFile);
    }
     for(var newImage in newImages){
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
       newImagesData.add(newImageFile);
     }
/////

    DataImagesModel imagesModel=   DataImagesModel(oldImages: oldImagesData,newImages: newImagesData);
    return imagesModel;
  }
}



class DataImagesModel{
  List<PDFItemImages> oldImages;
  List<PDFItemImages> newImages;
  DataImagesModel(
      {required this.oldImages, required this.newImages});

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
