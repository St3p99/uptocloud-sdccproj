import 'dart:html';
import 'dart:ui' as ui;

import 'package:admin/UI/responsive.dart';
import 'package:admin/UI/screens/dashboard/components/drop_zone_widget.dart';
import 'package:admin/UI/screens/dashboard/components/dropped_file_widget.dart';
import 'package:admin/api/api_controller.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../../../../models/file_data_model.dart';
import '../../../constants.dart';
import 'feedback_dialog.dart';

class PopupUpload extends StatefulWidget {
  PopupUpload({
    Key? key,
  }) : super(key: key);

  @override
  _PopupUploadState createState() => _PopupUploadState();
}

class _PopupUploadState extends State<PopupUpload> {
  FileDataModel? file;

  refreshState(ui.VoidCallback fn) {
    if (mounted) setState(fn);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _pushData() {}

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context),
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        scrollable: true,
        contentPadding: EdgeInsets.all(defaultPadding * 2),
        actionsPadding: EdgeInsets.all(defaultPadding * 2),
        backgroundColor: secondaryColor,
        content: Container(
          width: Responsive.uploadDialogWidth(context),
          height: Responsive.uploadDialogHeight(context),
          child: SingleChildScrollView(
              child: Center(
                  child: Column(
            children: [
              // here DropZoneWidget is statefull widget file
              Container(
                height: 300,
                child: DropZoneWidget(
                  onDroppedFile: (file) => setState(() => this.file = file),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: defaultPadding),
              ),
              DroppedFileWidget(file: file)
            ],
          ))),
        ),
        actions: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            ButtonTheme(
              minWidth: 25.0,
              height: 25.0,
              child: ElevatedButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: defaultPadding * 1.5,
                    vertical:
                    defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
                  ),
                ),
                onPressed: () {Navigator.of(context).pop();},
                child: Text("Close"),
              ),
            ),
            if (file != null) ...[
              Padding(
                padding: EdgeInsets.only(right: defaultPadding),
              ),
              ButtonTheme(
                minWidth: 25.0,
                height: 25.0,
                child: ElevatedButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: defaultPadding * 1.5,
                      vertical: defaultPadding /
                          (Responsive.isMobile(context) ? 2 : 1),
                    ),
                  ),
                  onPressed: () {
                    _upload();
                  },
                  child: Text("Confirm"),
                ),
              ),
            ]
          ])
        ],
      ),
    );
  }

  Future<void> _upload() async {
    StreamedResponse? response = await new ApiController().uploadFile(file!);
    switch (response!.statusCode) {
      case HttpStatus.ok:
        {
          FeedbackDialog(
              type: CoolAlertType.success,
              context: context,
              title: "SUCCESS",
              message: "")
              .show().whenComplete(() => Navigator.pop(context));
        }
        break;
      case HttpStatus.conflict:
        {
          FeedbackDialog(
              type: CoolAlertType.error,
              context: context,
              title: "CONFLICT!",
              message: "File with this name already exists")
              .show();
        }
        break;
      default:
        {
          FeedbackDialog(
                  type: CoolAlertType.error,
                  context: context,
                  title: "UNKNOWN ERROR",
                  message: "")
              .show();
        }
        break;
    }
  }
}
