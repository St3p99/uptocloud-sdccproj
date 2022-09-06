import 'dart:collection';

import 'package:admin/UI/screens/dashboard/components/readers_datatable_source.dart';
import 'package:admin/api/api_controller.dart';
import 'package:admin/models/document.dart';
import 'package:admin/support/constants.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';

import '../../../../models/user.dart';
import '../../../constants.dart';
import 'feedback_dialog.dart';

class ReadersList extends StatefulWidget {
  ReadersList(
      {Key? key,
        required this.title,
        required this.document
      })
      : super(key: key);

  String title;
  Document document;

  @override
  _ReadersListState createState() => _ReadersListState();
}

class _ReadersListState extends State<ReadersList> {
   late HashSet<int> _selectedUsers;
  late Future<List<User>> _future;

  ReadersDataTableSource datasource = new ReadersDataTableSource();

  @override
  initState() {
    fetch();
    datasource.addListener(_handleDataSourceChanged);
    super.initState();
    _handleDataSourceChanged();
  }

  Future<List<User>> fetch() {
    setState(() {
      _future = datasource.pullData(widget.document.id)!;
    });
    return _future;
  }

  void _handleDataSourceChanged() {
    setState(() {
      _selectedUsers = datasource.selectedUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(color: Colors.white10),
        ),
        child: _buildFutureBuilder(context));
  }

  Widget _buildFutureBuilder(BuildContext context) {
    return FutureBuilder<List<User>>(
        future: _future,
        initialData: [],
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(
                child: SizedBox(
                    height: 15,
                    width: 15,
                    child: CircularProgressIndicator()));
          }
          if (snapshot.hasError) {
            return Center(
                child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.20,
                    width: MediaQuery.of(context).size.width * 0.70,
                    child: Text('Error: ${snapshot.error}')));
          }
          if (snapshot.hasData) {
            return _buildContent(context, snapshot.data!);
          }
          return Center(
              child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.20,
                  width: MediaQuery.of(context).size.width * 0.30,
                  child: Text('No data')));
        });
  }

  Widget _buildContent(BuildContext context, List<User> readers) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.subtitle1,
            ),

          ]),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_selectedUsers.isNotEmpty) ...[
            deleteButton()
          ],
          IconButton(
            tooltip: "Refresh",
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              fetch();
            },
          ),
        ],
      ),
      readers.isEmpty
          ? Text('None', style: Theme.of(context).textTheme.labelLarge,)
          : _buildTable(),
    ]);
  }

  Widget _buildTable() {
    return InteractiveViewer(
      panEnabled: false,
      scaleEnabled: false,
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Theme(
          data: Theme.of(context).copyWith(
              cardColor: secondaryColor,
              selectedRowColor: primaryColor,
              checkboxTheme: CheckboxThemeData(
                side: MaterialStateBorderSide.resolveWith(
                        (_) => const BorderSide(width: 1, color: Colors.white)),
                fillColor: MaterialStateProperty.all(primaryColor),
                checkColor: MaterialStateProperty.all(Colors.white),
              ),
              textTheme: Theme.of(context)
                  .textTheme
                  .apply(displayColor: Colors.white, bodyColor: Colors.white)),
          child: PaginatedDataTable(
            showCheckboxColumn: _selectedUsers.length > 2,
            rowsPerPage: DEFAULT_PAGE_SIZE,
            columnSpacing: defaultPadding,
            columns: [
              DataColumn(
                  label: Text("Username"),
                  ),
              DataColumn(
                  label: Text("Email"),
              ),
            ],
            source: datasource,
          ),
        ),
      ),
    );
  }



  Widget deleteButton() {
    return IconButton(
      tooltip: _selectedUsers.length == 1 ? "Delete reader" : "Delete readers",
      icon: SvgPicture.asset("assets/icons/delete.svg", color: Colors.white, height: 20,),
      onPressed: () async{
        Response? response = await  new ApiController().deleteReaders(widget.document, datasource.getSelectedUsers());
        switch (response!.statusCode) {
          case 200:
            {
              FeedbackDialog(
                  type: CoolAlertType.success,
                  context: context,
                  title: "SUCCESS",
                  message: "")
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
      },
    );
  }
}
