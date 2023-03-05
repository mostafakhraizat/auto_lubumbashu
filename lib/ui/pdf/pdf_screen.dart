import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_share/flutter_share.dart';

class PDFScreen extends StatefulWidget {
  PDFScreen({Key? key, required this.pdf, required this.title})
      : super(key: key);
  File pdf;
  String title;

  @override
  State<PDFScreen> createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  late PDFViewController controller;

  Future<void> shareFile() async {
    File result = widget.pdf;
    await FlutterShare.shareFile(
      title: 'Share ${widget.title}',
      text: 'Share Generated PDF',
      filePath: result.path.replaceFirst("files-", "DNN  :#"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: InkWell(
          child: const Icon(Icons.close),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
              onPressed: () async {
                shareFile();
              },
              child: const Text(
                "Share",
                style: TextStyle(color: Colors.white),
              )),
          const SizedBox(
            width: 12,
          ),
          // TextButton(
          //     onPressed: () {},
          //     child:const Text(
          //       "Send to server",
          //       style: TextStyle(color: Colors.white),
          //     )),
        ],
      ),
      body: PDFView(
        filePath: "file:///${widget.pdf.path}",
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageFling: false,
        onRender: (pages) {},
        onError: (error) {
          print(error.toString());
        },
        onPageError: (page, error) {
          print('$page: ${error.toString()}');
        },
        onViewCreated: (PDFViewController pdfViewController) {
          setState(() {
            controller = pdfViewController;
          });
        },
        onPageChanged: (int? page, int? total) {
          print('page change: $page/$total');
        },
      ),
    );
  }
}
