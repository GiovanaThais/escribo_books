import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:escribo_books/http/http_client.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';

class ReaderPage extends StatefulWidget {
  const ReaderPage(
      {super.key,
      required this.fiileUrl,
      required this.bookName,
      required this.http});
  final String fiileUrl;
  final String bookName;
  final IHttpClient http;

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  bool loading = false;
  String filePath = "";
  String get fileUrl => widget.fiileUrl;
  String get bookName => widget.bookName;
  IHttpClient get http => widget.http;

  @override
  void initState() {
    super.initState();
    openEbook();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocsy Plugin E-pub example'),
      ),
      body: Center(
        child: loading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text('Downloading.... E-pub'),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: openEbook,
                    child: const Text('Open E-pub'),
                  ),
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     VocsyEpub.setConfig(
                  //       themeColor: Theme.of(context).primaryColor,
                  //       identifier: "iosBook",
                  //       scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
                  //       allowSharing: true,
                  //       enableTts: true,
                  //       nightMode: true,
                  //     );
                  //     // get current locator
                  //     VocsyEpub.locatorStream.listen((locator) {
                  //       log('LOCATOR: $locator');
                  //     });
                  //     await VocsyEpub.openAsset(
                  //       'assets/4.epub',
                  //       lastLocation: EpubLocator.fromJson({
                  //         "bookId": "2239",
                  //         "href": "/OEBPS/ch06.xhtml",
                  //         "created": 1539934158390,
                  //         "locations": {"cfi": "epubcfi(/0!/4/4[simple_book]/2/2/6)"}
                  //       }),
                  //     );
                  //   },
                  //   child: const Text('Open Assets E-pub'),
                  // ),
                ],
              ),
      ),
    );
  }

  Future<String> startDownload(String url, {String? filename}) async {
    final response = await http.get(url: url);
    String dir = (await getApplicationDocumentsDirectory()).path;
    String filePath = '';

    File file = File('$dir/${filename?.replaceAll(' ', '_').toLowerCase()}');
    await file.writeAsBytes(response.bodyBytes);
    filePath = file.path;

    return filePath;
  }

  Future<void> download() async {
    setState(() {
      loading = true;
    });
    String filePath = '';
    if (Platform.isAndroid || Platform.isIOS) {
      String? firstPart;
      final deviceInfoPlugin = DeviceInfoPlugin();
      final deviceInfo = await deviceInfoPlugin.deviceInfo;
      final allInfo = deviceInfo.data;
      if (allInfo['systemVersion'].toString().contains(".")) {
        int indexOfFirstDot = allInfo['systemVersion'].indexOf(".");
        firstPart = allInfo['systemVersion'].substring(0, indexOfFirstDot);
      } else {
        firstPart = allInfo['systemVersion'];
      }
      int intValue = int.parse(firstPart!);
      if (intValue >= 13) {
        filePath = await startDownload(fileUrl, filename: bookName);
      } else {
        if (await Permission.storage.isGranted) {
          await Permission.storage.request();
          filePath = await startDownload(fileUrl, filename: bookName);
        } else {
          filePath = await startDownload(fileUrl, filename: bookName);
        }
      }
    } else {
      loading = false;
    }
    setState(() {
      this.filePath = filePath;
      loading = false;
    });
  }

  void openEbook() async {
    log("=====filePath======$filePath");
    if (filePath == "") {
      await download();
    }
    VocsyEpub.setConfig(
      themeColor: Theme.of(context).primaryColor,
      identifier: "iosBook",
      scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
      allowSharing: true,
      enableTts: true,
      nightMode: true,
    );

    // get current locator
    VocsyEpub.locatorStream.listen((locator) {
      log('LOCATOR: $locator');
    });

    VocsyEpub.open(
      filePath,
      lastLocation: EpubLocator.fromJson({
        "bookId": "2239",
        "href": "/OEBPS/ch06.xhtml",
        "created": 1539934158390,
        "locations": {"cfi": "epubcfi(/0!/4/4[simple_book]/2/2/6)"}
      }),
    );
  }
}
