import 'package:admin/UI/constants.dart';
import 'package:admin/UI/screens/dashboard/components/feedback_dialog.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';

import '../../../../models/file_data_model.dart';
import '../../../responsive.dart';

class DropZoneWidget extends StatefulWidget {

  final ValueChanged<FileDataModel> onDroppedFile;

  const DropZoneWidget({Key? key,required this.onDroppedFile}):super(key: key);
  @override
  _DropZoneWidgetState createState() => _DropZoneWidgetState();
}

class _DropZoneWidgetState extends State<DropZoneWidget> {
  //controller to hold data of file dropped by user
  late DropzoneViewController controller;
  // a variable just to update UI color when user hover or leave the drop zone
  bool highlight = false;

  @override
  Widget build(BuildContext context) {

    return buildDecoration(
        child: Stack(
          children: [
            // dropzone area
            DropzoneView(
              // attach an configure the controller
              onCreated: (controller) => this.controller = controller,
              // call UploadedFile method when user drop the file
              onDrop: UploadedFile,
              onDropMultiple: (list) {
                if(list!= null && list.length>1)
                  _errorDialogOneFileAtTime();
              },
              // change UI when user hover file on dropzone
              onHover:() => setState(()=> highlight = true),
              onLeave: ()=> setState(()=>highlight = false),
              onLoaded: ()=> print('Zone Loaded'),
              onError: (err)=> print('run when error found : $err'),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 80,
                    color: highlight? Colors.white70: Colors.white,
                  ),
                  Text(
                    'Drop Files Here',
                    style: TextStyle(color: highlight? Colors.white70: Colors.white, fontSize: 24),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  // a button to pickfile from computer
                  ElevatedButton(
                    onPressed: () async {
                      final events = await controller.pickFiles(multiple: false);
                      if(events.isEmpty) return;
                      UploadedFile(events.first);
                    },
                    child: Text(
                      'Choose File',
                      style: TextStyle(color: highlight? Colors.white70: Colors.white, fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20
                        ),
                        primary: highlight? Colors.white70: primaryColor,
                        shape: RoundedRectangleBorder()
                    ),
                  )
                ],
              ),
            ),
          ],
        ));
  }

  void _errorDialogOneFileAtTime(){
    FeedbackDialog(
        type: CoolAlertType.error,
        context: context,
        title: "Upload one file at time!",
        message: "")
        .show();
  }

  Future UploadedFile(dynamic event) async {
    // this method is called when user drop the file in drop area in flutter

    final name = event.name;
    final mime = await controller.getFileMIME(event);
    final byte = await controller.getFileSize(event);
    final stream = controller.getFileStream(event).asBroadcastStream();
    final url = await controller.createFileUrl(event);


    print('Name : $name');
    print('Mime: $mime');
    print('Size : ${byte / (1024 * 1024)}');


    // update the data model with recent file uploaded
    final droppedFile = new FileDataModel(
        name: name, mime: mime, bytes: byte, stream: stream, url:url);

    //Update the UI
    widget.onDroppedFile(droppedFile);
    setState(() {
      highlight = false;
    });


  }

  Widget buildDecoration({required Widget child}){
    final colorBackground =  highlight? secondaryColor: bgColor;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(defaultPadding),
        width: Responsive.uploadDialogWidth(context)*2/3,
        height: Responsive.uploadDialogHeight(context)*2/3,
        child: DottedBorder(
            borderType: BorderType.RRect,
            color: highlight? Colors.white70: Colors.white,
            strokeWidth: 1.5,
            dashPattern: [10,5],
            radius: Radius.circular(10),
            padding: EdgeInsets.zero,
            child: child
        ),
        color: colorBackground,
      ),
    );
  }
}