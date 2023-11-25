import 'dart:io';
import 'dart:typed_data';

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
    download();
  }

  void download() async {
    String filePath = '';
    if (Platform.isAndroid || Platform.isIOS) {
      String? firstPart;
      final deviceInfoPlugin = DeviceInfoPlugin();
      final deviceInfo = await deviceInfoPlugin.deviceInfo;
      final allInfo = deviceInfo.data;
      if (allInfo['version']["release"].toString().contains(".")) {
        int indexOfFirstDot = allInfo['version']["release"].indexOf(".");
        firstPart = allInfo['version']["release"].substring(0, indexOfFirstDot);
      } else {
        firstPart = allInfo['version']["release"];
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
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
                      onPressed: () async {
                        print("=====filePath======$filePath");
                        if (filePath == "") {
                          download();
                        } else {
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
                            print('LOCATOR: $locator');
                          });

                          VocsyEpub.open(
                            filePath,
                            lastLocation: EpubLocator.fromJson({
                              "bookId": "2239",
                              "href": "/OEBPS/ch06.xhtml",
                              "created": 1539934158390,
                              "locations": {
                                "cfi": "epubcfi(/0!/4/4[simple_book]/2/2/6)"
                              }
                            }),
                          );
                        }
                      },
                      child: const Text('Open Online E-pub'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
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
                          print('LOCATOR: $locator');
                        });
                        await VocsyEpub.openAsset(
                          'assets/4.epub',
                          lastLocation: EpubLocator.fromJson({
                            "bookId": "2239",
                            "href": "/OEBPS/ch06.xhtml",
                            "created": 1539934158390,
                            "locations": {
                              "cfi": "epubcfi(/0!/4/4[simple_book]/2/2/6)"
                            }
                          }),
                        );
                      },
                      child: const Text('Open Assets E-pub'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

//   startDownload() async {
//     Directory? appDocDir = Platform.isAndroid ? await getExternalStorageDirectory() : await getApplicationDocumentsDirectory();

//     String path = appDocDir!.path + '/sample.epub';
//     File file = File(path);

//     if (!File(path).existsSync()) {
//       await file.create();
//       await dio.download(
//         "https://vocsyinfotech.in/envato/cc/flutter_ebook/uploads/22566_The-Racketeer---John-Grisham.epub",
//         path,
//         deleteOnError: true,
//         onReceiveProgress: (receivedBytes, totalBytes) {
//           setState(() {
//             loading = true;
//           });
//         },
//       ).whenComplete(() {
//         setState(() {
//           loading = false;
//           filePath = path;
//         });
//       });
//     } else {
//       setState(() {
//         loading = false;
//         filePath = path;
//       });
//     }
//   }
// }

  Future<String> startDownload(String url, {String? filename}) async {
    final response = http.get(url: url);
    String dir = (await getApplicationDocumentsDirectory()).path;
    String filePath = '';

    List<List<int>> chunks = [];
    int downloaded = 0;

    response.asStream().listen((r) {
      r.stream.listen((List<int> chunk) {
        // Display percentage of completion
        debugPrint('downloadPercentage: ${downloaded / r.contentLength * 100}');

        chunks.add(chunk);
        downloaded += chunk.length;
      }, onDone: () async {
        // Display percentage of completion
        debugPrint('downloadPercentage: ${downloaded / r.contentLength * 100}');

        // Save the file
        File file =
            File('$dir/${filename?.replaceAll(' ', '_').toLowerCase()}');
        final Uint8List bytes = Uint8List(r.contentLength);
        int offset = 0;
        for (List<int> chunk in chunks) {
          bytes.setRange(offset, offset + chunk.length, chunk);
          offset += chunk.length;
        }
        await file.writeAsBytes(bytes);
        return filePath = file.path;
      });
    });
    return filePath;
  }
}
