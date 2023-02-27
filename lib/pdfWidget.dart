import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'dart:io';


class PdfWidget extends StatefulWidget {
  const PdfWidget({Key? key, required this.filePath}) : super(key: key);
  final String filePath;

  @override
  State<PdfWidget> createState() => _PdfWidgetState();
}

class _PdfWidgetState extends State<PdfWidget> {

  Future<File> fromAsset(String asset, String filename) async {
    // To open from assets, you can copy them to the app storage folder, and the access them "locally"
    Completer<File> completer = Completer();

    try {
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$filename");
      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  final Completer<PDFViewController> _controller = Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return PDFView(
      filePath: widget.filePath,
      enableSwipe: true,
      swipeHorizontal: true,
      autoSpacing: false,
      pageFling: true,
      pageSnap: true,
      defaultPage: currentPage!,
      fitPolicy: FitPolicy.BOTH,
      preventLinkNavigation: false,
      // if set to true the link is handled in flutter
      onRender: (pages) {
        setState(() {
          pages = pages;
          isReady = true;
        });
      },
      onError: (error) {
        setState(() {
          errorMessage = error.toString();
        });
        print(error.toString());
      },
      onPageError: (page, error) {
        setState(() {
          errorMessage = '$page: ${error.toString()}';
        });
        print('$page: ${error.toString()}');
      },
      onViewCreated: (PDFViewController pdfViewController) {
        _controller.complete(pdfViewController);
      },
      onLinkHandler: (String? uri) {
        print('goto uri: $uri');
      },
      onPageChanged: (int? page, int? total) {
        print('page change: $page/$total');
        setState(() {
          currentPage = page;
        });
      },
    );
  }
}
