import 'dart:html';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:admin/models/document.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../../../../api/api_controller.dart';
import 'feedback_dialog.dart';

class HandleDownloadWidget extends StatefulWidget {
  const HandleDownloadWidget({Key? key, required this.file}) : super(key: key);

  final Document file;

  @override
  _HandleDownloadWidgetState createState() => _HandleDownloadWidgetState();
}

class _HandleDownloadWidgetState extends State<HandleDownloadWidget> {
  int _byteReceived = 0;
  String _total = "0", _received = "0";
  StreamedResponse? _response;
  late String _mime;
  late String _filename;
  final List<int> _bytes = [];
  late Future _futureDownload;

  @override
  initState() {
    super.initState();
    _futureDownload = _download();
  }

  refreshState(ui.VoidCallback fn) {
    if (mounted) setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _futureDownload,
        initialData: [],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Processing data...');
          }
          else if(snapshot.connectionState == ConnectionState.done && _response != null)
            _handleDownload();
            return Text("Downloading... ${_received}/${_total} MB");
        });
  }

  Future _download() async {
    if (_response != null) return;
    StreamedResponse? response =
        (await new ApiController().downloadFile(widget.file));
    if (response != null && response.statusCode == HttpStatus.ok) {
      setState(() {
        _response = response;
      });
      int size = _response!.contentLength ?? 0;
      setState(() {
        _total = formatSize(size);
      });
    } else {
      FeedbackDialog(
          type: CoolAlertType.error,
          context: context,
          title: "UNKNOWN ERROR",
          onConfirmBtnTap: (){
            Navigator.pop(context);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          }
      ).show();

    }
    if (response != null) print(response.statusCode);
  }

  _handleDownload() async{
      _response!.stream.listen((value) async{
        setState(() {
          _bytes.addAll(value);
          _byteReceived += value.length;
          _received = formatSize(_byteReceived);
        });
      }, onDone: () {
        String contentDisp = _response!.headers["content-disposition"]!;
        setState(() {
          _mime = _response!.headers[HttpHeaders.contentTypeHeader].toString();
          _filename = contentDisp!.split('filename=')[1].split(';')[0];
        });
        anchorElementDownload();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }, onError: ((handleError){
        FeedbackDialog(
            type: CoolAlertType.error,
            context: context,
            title: "UNKNOWN ERROR",
          onConfirmBtnTap: (){
            Navigator.pop(context);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          }
        ).show();

      }));
  }

  String formatSize(int size) {
    return (size / 1048576)
        .toStringAsFixed(FILE_SIZE_FRACTION_DIGITS); //B -> MB
  }

  void anchorElementDownload() {
    new AnchorElement()
      ..href = '${Uri.dataFromBytes(_bytes, mimeType: _mime)}'
      ..download = _filename
      ..click();
  }
}
