import 'package:admin/api/api_controller.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';

import '../../../../models/document.dart';
import '../../../constants.dart';
import '../../../responsive.dart';

class DeleteFilesAlertDialog{
  DeleteFilesAlertDialog({Key? key, required this.files, required this.context});

  List<Document> files;
  BuildContext context;

  Future show(){
    String title = files.length == 1?
    "Are you sure want to delete \""+ files.first.name+"\"?" :
    "Are you sure want to continue?";

    String list = "";
    if(files.length>1) files.forEach((file) { list+=" - "+file.name+"\n"; });

    String? message1 = files.length == 1?
    "This item will be deleted permanently!":
    "This items will be deleted permanently!";

    String? message2 =
      files.length == 1? "": list;


    return CoolAlert.show(
        context: context,
        type: CoolAlertType.confirm,
        title: title,
        text: message1+"\n"+message2,
        width: Responsive.isMobile(context) ? MediaQuery.of(context).size.width*.8 :
        Responsive.isTablet(context) ? MediaQuery.of(context).size.width*.6 :
        MediaQuery.of(context).size.width*.2,
        backgroundColor: bgColor,
        confirmBtnColor: primaryColor,
        onConfirmBtnTap: () {
          if(files.length==1)
            new ApiController().deleteFile(files.first);
          else
            new ApiController().deleteFiles(files);
          Navigator.pop(context);
        });
  }
}
