import 'dart:collection';
import 'dart:io';

import 'package:admin/UI/screens/dashboard/components/delete_files_alert_dialog.dart';
import 'package:admin/UI/screens/dashboard/components/file_datatable_source.dart';
import 'package:admin/UI/screens/dashboard/components/handle_download_widget.dart';
import 'package:admin/UI/screens/dashboard/components/popup_edit_metadata_.dart';
import 'package:admin/UI/screens/dashboard/components/popup_more_info.dart';
import 'package:admin/UI/screens/dashboard/components/popup_share.dart';
import 'package:admin/UI/screens/dashboard/components/popup_upload.dart';
import 'package:admin/UI/screens/dashboard/components/search_result_datatable_source.dart';
import 'package:admin/UI/screens/dashboard/components/shared_file_datatable_source.dart';
import 'package:admin/UI/screens/dashboard/components/shared_search_result_datatable_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../models/document.dart';
import '../../../../support/constants.dart';
import '../../../constants.dart';
import '../../../responsive.dart';
import 'my_abstract_datatable_source.dart';

class FilesList extends StatefulWidget {
  FilesList(
      {Key? key,
      required this.title,
      required this.datasource,
      required this.isOwner})
      : super(key: key);

  String title;
  MyAbstractDataTableSource datasource;
  bool isOwner;

  @override
  _FilesListState createState() => _FilesListState();
}

class _FilesListState extends State<FilesList> {
  // double _scrollOffset = 0;
  // late ScrollController _scrollController;

  late HashSet<int> _selectedFiles;
  late Future<List<Document>> _future;
  // late List<Document>? _result;
  late bool _sortAsc;
  late int _sortColumnIndex;
  late MyAbstractDataTableSource datasource;
  String? _selectedOption = null;
  bool _searchPage = false;

  @override
  initState() {
    if( widget.datasource is SearchResultDataTableSource){
      datasource = new SearchResultDataTableSource(widget.datasource.result);
      _searchPage = true;
    }
    else if(widget.datasource is SharedSearchResultDataTableSource){
      datasource = new SharedSearchResultDataTableSource(widget.datasource.result);
      _searchPage = true;
    }
    else if (widget.datasource is FileDataTableSource)
      datasource = new FileDataTableSource();
    else
      datasource = new SharedFileDataTableSource();

    datasource.addListener(_handleDataSourceChanged);
    super.initState();
    fetch();
    _handleDataSourceChanged();
  }

  Future<List<Document>> fetch() {
    setState(() {
      _future = datasource.pullData()!;
    });
    return _future;
  }

  void _handleDataSourceChanged() {
    setState(() {
      // _result = datasource.result;
      _selectedFiles = datasource.selectedFiles;
      _sortAsc = datasource.sortAsc;
      _sortColumnIndex = datasource.sortColumnIndex;
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
    return FutureBuilder<List<Document>>(
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

  Widget _buildContent(BuildContext context, List<Document> files) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.subtitle1,
        ),
      ]),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_selectedFiles.isNotEmpty) ...[
            optionButtons(),
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
          Padding(padding: EdgeInsets.only(right: defaultPadding)),
          if (widget.isOwner && !_searchPage) ...[
            ElevatedButton.icon(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: defaultPadding * 1.5,
                  vertical:
                      defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
                ),
              ),
              onPressed: () {
                showDialog(
                    context: context, builder: (context) => PopupUpload()).whenComplete(() => fetch());
              },
              icon: Icon(Icons.add),
              label: Text("Add New"),
            ),
          ]// visible only if is owner
        ],
      ),
      files.isEmpty
          ? Text(
              'No files',
              style: Theme.of(context).textTheme.labelLarge,
            )
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
            rowsPerPage: DEFAULT_PAGE_SIZE,
            showCheckboxColumn: _selectedFiles.length > 1,
            columnSpacing: defaultPadding,
            columns: [
              DataColumn(
                  label: Text("File Name"),
                  onSort: (columnIndex, sortAscending) =>
                      datasource.sort(columnIndex, sortAscending)),
              DataColumn(
                  label: Text("Date uploaded (UTC)"),
                  onSort: (columnIndex, sortAscending) =>
                      datasource.sort(columnIndex, sortAscending)),
              if (!widget.isOwner) ...[
                DataColumn(
                    label: Text("Owner"),
                    onSort: (columnIndex, sortAscending) =>
                        datasource.sort(columnIndex, sortAscending)),
              ],
              DataColumn(
                  label: Text("Size"),
                  onSort: (columnIndex, sortAscending) =>
                      datasource.sort(columnIndex, sortAscending)),
            ],
            source: datasource,
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAsc,
          ),
        ),
      ),
    );
  }

  Widget optionMenu() {
    return DropdownButton<String>(
      value: _selectedOption,
      icon: Icon(
        Icons.more_horiz,
        color: Colors.white,
      ),
      items: [
        if (widget.isOwner && _selectedFiles.isNotEmpty) ...[
          DropdownMenuItem(child: shareMenuButton(), value: "share"),
          DropdownMenuItem(child: deleteMenuButton(), value: "delete"),
        ],
        if (_selectedFiles.length == 1) ...[
          DropdownMenuItem(child: downloadMenuButton(), value: "download"),
          if (widget.isOwner) ...[
            DropdownMenuItem(child: metadataMenuButton(), value: "metadata"),
          ],
          DropdownMenuItem(child: moreInfoMenuButton(), value: "moreInfo"),
        ],
      ],
      onChanged: (value) {
        _selectedOption = value;
      },
    );
  }

  Widget optionButtons() {
    return Responsive.isMobile(context)
        ? optionMenu()
        : Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (widget.isOwner && _selectedFiles.isNotEmpty) ...[
              deleteButton()
            ],
            if (_selectedFiles.length == 1) ...[
              downloadButton(),
              if (widget.isOwner) ...[
                shareButton(),
                metadataButton(),
              ],
              moreInfoButton(),
            ],
          ],
        );
  }

  Widget shareButton() {
    return IconButton(
      tooltip: "Share file",
      icon: SvgPicture.asset(
        "assets/icons/add_user.svg",
        color: Colors.white,
        height: 20,
      ),
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) =>
                PopupShare(file: datasource.getSelectedFile())).whenComplete(() async{
          await Future.delayed(Duration(seconds:1));
          fetch();
        });
      },
    );
  }

  Widget deleteButton() {
    return IconButton(
      tooltip: _selectedFiles.length == 1 ? "Delete file" : "Delete files",
      icon: SvgPicture.asset(
        "assets/icons/delete.svg",
        color: Colors.white,
        height: 20,
      ),
      onPressed: () {
        DeleteFilesAlertDialog(
            context: context,
          files: datasource.getSelectedFiles()
        ).show().whenComplete(() async{
          await Future.delayed(Duration(seconds:1));
          fetch();
        });
      }
    );
  }

  Widget downloadButton() {
    return IconButton(
      tooltip: "Download file",
      icon: SvgPicture.asset(
        "assets/icons/download.svg",
        color: Colors.white,
        height: 20,
      ),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          new SnackBar(
              duration: Duration(days: 1),
              content: HandleDownloadWidget(file: datasource.getSelectedFile(),)
          ),
        );
      },
    );
  }

  Widget metadataButton() {
    return IconButton(
      tooltip: "Edit metadata",
      icon: SvgPicture.asset(
        "assets/icons/tags.svg",
        color: Colors.white,
        height: 20,
      ),
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) =>
                PopupEditMetadata(file: datasource.getSelectedFile())).whenComplete(() async{
          await Future.delayed(Duration(seconds:1));
          fetch();
        });
      },
    );
  }

  Widget moreInfoButton() {
    return IconButton(
      tooltip: "More info",
      icon: SvgPicture.asset(
        "assets/icons/info.svg",
        color: Colors.white,
        height: 20,
      ),
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) =>
                PopupMoreInfo(file: datasource.getSelectedFile()));
      },
    );
  }

  // MenuButtons
  Widget moreInfoMenuButton() {
    return TextButton.icon(
      label: Text("More info", style: TextStyle(color: Colors.white)),
      icon: SvgPicture.asset(
        "assets/icons/info.svg",
        color: Colors.white,
        height: 20,
      ),
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) =>
                PopupMoreInfo(file: datasource.getSelectedFile()));
      },
    );
  }

  Widget shareMenuButton() {
    return TextButton.icon(
      label: Text("Share file", style: TextStyle(color: Colors.white)),
      icon: SvgPicture.asset(
        "assets/icons/add_user.svg",
        color: Colors.white,
        height: 20,
      ),
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) =>
                PopupShare(file: datasource.getSelectedFile())).whenComplete(() async{
          await Future.delayed(Duration(seconds:1));
          fetch();
        });
      },
    );
  }

  Widget deleteMenuButton() {
    return TextButton.icon(
      label: Text(_selectedFiles.length == 1 ? "Delete file" : "Delete files",
          style: TextStyle(color: Colors.white)),
      icon: SvgPicture.asset(
        "assets/icons/delete.svg",
        color: Colors.white,
        height: 20,
      ),
      onPressed: () {
        DeleteFilesAlertDialog(
            context: context,
            files: datasource.getSelectedFiles()
        ).show().whenComplete(() async{
          await Future.delayed(Duration(seconds:1));
          fetch();
        });
      },
    );
  }

  Widget downloadMenuButton() {
    return TextButton.icon(
      label: Text("Download file", style: TextStyle(color: Colors.white)),
      icon: SvgPicture.asset(
        "assets/icons/download.svg",
        color: Colors.white,
        height: 20,
      ),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
            new SnackBar(content: HandleDownloadWidget(file: datasource.getSelectedFile()))
        );
      },
    );
  }

  Widget metadataMenuButton() {
    return TextButton.icon(
      label: Text("Edit metadata", style: TextStyle(color: Colors.white)),
      icon: SvgPicture.asset(
        "assets/icons/tags.svg",
        color: Colors.white,
        height: 20,
      ),
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) =>
                PopupEditMetadata(file: datasource.getSelectedFile())).whenComplete(() async{
          await Future.delayed(Duration(seconds:1));
          fetch();
        });
      },
    );
  }



}
