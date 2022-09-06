import 'package:flutter/material.dart';

import '../../constants.dart';
import 'components/file_datatable_source.dart';
import 'components/files_list.dart';
import 'components/header.dart';
import 'components/shared_file_datatable_source.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
              primary: false,
              padding: EdgeInsets.all(defaultPadding),
              child: Column(
                children: [
                  Header(
                    title: 'home',
                  ),
                  SizedBox(height: defaultPadding),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            // MyFiles(),
                            // SizedBox(height: defaultPadding),
                            FilesList(
                              title: "My Recent Files",
                              datasource: FileDataTableSource(),
                              isOwner: true,
                            ),
                            SizedBox(height: defaultPadding),
                            FilesList(
                              title: "Recent Files Shared With Me",
                              datasource: SharedFileDataTableSource(),
                              isOwner: false,
                            ),
                            // if (Responsive.isMobile(context))
                            //   SizedBox(height: defaultPadding),
                            // if (Responsive.isMobile(context)) StorageDetails(),
                          ],
                        ),
                      ),
                      // if (!Responsive.isMobile(context))
                      //   SizedBox(width: defaultPadding)  ,
                      // // On Mobile means if the screen is less than 850 we dont want to show it
                      // if (!Responsive.isMobile(context))
                      //   Expanded(
                      //     flex: 2,
                      //     child: StorageDetails(),
                      //   ),
                    ],
                  )
                ],
              )),
        ),
      ),
    );
  }
}
