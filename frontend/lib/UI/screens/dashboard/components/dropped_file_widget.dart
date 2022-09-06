import 'package:admin/UI/constants.dart';
import 'package:admin/support/file_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../models/file_data_model.dart';
import '../../../responsive.dart';

class DroppedFileWidget extends StatelessWidget {

  // here we get the uploaded file data
  final FileDataModel? file;

  const DroppedFileWidget({Key? key, required this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: _buildContent(context)),
      ],
    );
  }

  // a custom widget to show image
  Widget _buildContent(BuildContext context) {
    // will show no file selected when app is open for first time.
    if (file == null) return SizedBox();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if(file != null) _buildFileDetail(context),
        // if file dropped is Image then display image from data model URL variable
        Padding(padding: EdgeInsets.only(bottom: defaultPadding / 2),),
        Image.network(file!.url,
          width: Responsive.uploadDialogWidth(context) - defaultPadding * 2,
          fit: BoxFit.fitWidth,
          // if displaying image failed, that means there is not preview so display no preview
          errorBuilder: (context, error, _) => _buildEmptyFile('No Preview'),
        )

      ],
    );
  }

  //custom widget to show no file selected yet
  Widget _buildEmptyFile(String text) {
    return Center(child: Text(text)
    );
  }


  //a custom widget to show uploaded file details to user

  Widget _buildFileDetail(BuildContext context) {
    final style = TextStyle(fontSize: Theme
        .of(context)
        .textTheme
        .subtitle1!
        .fontSize);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('Selected File Preview ',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: Theme
                  .of(context)
                  .textTheme
                  .titleMedium!
                  .fontSize,), textAlign: TextAlign.start),
          Padding(padding: EdgeInsets.only(bottom: defaultPadding/2),),
          Container(
            height: 50,
              child: Image.asset("assets/icons/filetype/"+FileUtils.loadIcon(file!.mime))),
          Padding(padding: EdgeInsets.only(bottom: defaultPadding),),
          Text('Name: ${file?.name}',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: Theme
                  .of(context)
                  .textTheme
                  .titleMedium!
                  .fontSize), textAlign: TextAlign.start),
          Text('Type: ${file?.mime}', style: style, textAlign: TextAlign.start),
          Text('Size: ${file?.size}', style: style, textAlign: TextAlign.start),
        ],
      ),
    );
  }
}