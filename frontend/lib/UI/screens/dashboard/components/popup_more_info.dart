import 'package:admin/UI/responsive.dart';
import 'package:admin/controllers/user_provider.dart';
import 'package:flutter/material.dart';

import '../../../../models/document.dart';
import '../../../constants.dart';

class PopupMoreInfo extends StatelessWidget {
  PopupMoreInfo({
    Key? key,
    required this.file,
  }) : super(key: key);
  Document file;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context),
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        backgroundColor: secondaryColor,
        scrollable: true,
        contentPadding: EdgeInsets.all(defaultPadding * 2),
        actionsPadding: EdgeInsets.all(defaultPadding * 2),
        content: Container(
          width: Responsive.metadataDialogWidth(context),
          height: Responsive.metadataDialogHeight(context),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      constraints: BoxConstraints(minWidth: 200),
                      child: Row(
                        children: [
                          Container(
                            height: 30,
                            child: Image.asset(
                              "assets/icons/filetype/"+file.icon!,
                            ),
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: defaultPadding),
                            child: Text(file.name),
                          ),
                        ],
                      ),
                    ),
                Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: defaultPadding)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                        child: Text("Description",    style: Theme.of(context).textTheme.titleSmall,)),
                    Expanded(
                      flex: 4,
                      child:  Text(
                          file.metadata.description == null || file.metadata.description!.isEmpty?
                      " ":file.metadata.description!, style: Theme.of(context).textTheme.bodyMedium,
                      )
                    ),
                  ],
                ),
                if (file.metadata.tags != null &&
                    file.metadata.tags!.length > 0) ...[
                  Padding(
                      padding:
                      EdgeInsets.symmetric(vertical: defaultPadding)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 2,
                          child: Text("Tags",style: Theme.of(context).textTheme.titleSmall,)),
                      Expanded(
                        flex: 4,
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          children: file.metadata.tags!
                              .map((tag) => tagChip(tag, context))
                              .toSet()
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ],
                    Padding(
                        padding:
                        EdgeInsets.symmetric(vertical: defaultPadding)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 2,
                            child: Text("Size",    style: Theme.of(context).textTheme.titleSmall,)),
                        Expanded(
                            flex: 4,
                            child:  Text(
                              file.getFileSize(), style: Theme.of(context).textTheme.bodyMedium,
                            )
                        ),
                      ],
                    ),
                    Padding(
                        padding:
                        EdgeInsets.symmetric(vertical: defaultPadding)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 2,
                            child: Text("Date uploaded (UTC)",style: Theme.of(context).textTheme.titleSmall,)),
                        Expanded(
                            flex: 4,
                            child:Text(file.metadata.uploadedAt.toString().split(".").first, style: Theme.of(context).textTheme.bodyMedium,)
                        ),
                      ],
                    ),
                    if (file.owner != new UserProvider().currentUser) ...[
                      Padding(
                          padding:
                          EdgeInsets.symmetric(vertical: defaultPadding)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text("Owner",style: Theme.of(context).textTheme.titleSmall,)),
                          Expanded(
                            flex: 4,
                            child:Text(file.owner.email+" ("+file.owner.username+")", style: Theme.of(context).textTheme.bodyMedium,)
                          ),
                        ],
                      ),
                    ],
              ]),
            ),
          ),
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
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Close"),
              ),
            ),
          ])
        ],
      ),
    );
  }

  Widget tagChip(String tag, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 5.0,
        horizontal: 5.0,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 10.0,
        ),
        decoration: BoxDecoration(
          color: primaryColor70,
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Text(
          tag,
          style: TextStyle(
            color: Colors.white,
            fontSize: Theme.of(context).textTheme.bodyText1!.fontSize,
          ),
        ),
      ),
    );
  }

}
