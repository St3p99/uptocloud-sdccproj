import 'package:admin/models/document.dart';
import 'package:flutter/material.dart';

import '../../../../api/api_controller.dart';
import '../../../constants.dart';
import 'my_abstract_datatable_source.dart';

class SharedFileDataTableSource extends MyAbstractDataTableSource {
  ApiController api = new ApiController();
  bool sortNameAsc = true;
  bool sortDateAsc = true;
  bool sortOwnerAsc = true;
  bool sortSizeAsc = true;


  @override
  DataRow? getRow(int index) {
    Document file = result!.elementAt(index);
    return DataRow(
      selected: selectedFiles.contains(index),
      onSelectChanged: (isSelected) {
        onSelected(index, isSelected!);
        notifyListeners();
      },
      cells: [
        DataCell(
          Container(
            constraints: BoxConstraints(minWidth: 200),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(defaultPadding/4),
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
        ),
        DataCell(Container(
            constraints: BoxConstraints(minWidth: 200),
            child: Text(file.metadata.uploadedAt.toString().split(".").first))),
        DataCell(Container(
            constraints: BoxConstraints(minWidth: 200),
            child: Text(file.owner.email+" ("+file.owner.username+")"))),
        DataCell(Container(
            constraints: BoxConstraints(minWidth: 200),
            child: Text(file.getFileSize()))),
        // DataCell(Options(file: file,))
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => result!.length;

  @override
  int get selectedRowCount => 1;

  onSelected(int index, bool isSelected){
    if (isSelected && selectedFiles.isEmpty) {
      selectedFiles.add(index);
    } else if(isSelected){
      selectedFiles.clear();
      selectedFiles.add(index);
    }
    else {
      selectedFiles.remove(index);
    }
  }

  @override
  Future<List<Document>>? pullData() async {
    List<Document>? recentFiles = await api.loadRecentFilesReadOnly();
    recentFiles!.forEach((file) {file.loadIcon();});
    result = recentFiles;
    notifyListeners();
    return result!;
  }

  @override
  void sort(int columnIndex, bool sortAscending) {
    switch(columnIndex){
      case 0: {
        if (columnIndex == sortColumnIndex) {
          sortAsc = sortNameAsc = sortAscending;
        } else {
          sortColumnIndex = columnIndex;
          sortAsc = sortNameAsc;
        }
        if (sortAscending)
          result!.sort((a, b) => a.name.compareTo(b.name));
        else
          result!.sort((a, b) => b.name.compareTo(a.name));
      } break;
      case 1: {
        if (columnIndex == sortColumnIndex) {
          sortAsc = sortDateAsc = sortAscending;
        } else {
          sortColumnIndex = columnIndex;
          sortAsc = sortDateAsc;
        }
        if (sortAscending)
          result!.sort((a, b) => a.metadata.uploadedAt.compareTo(b.metadata.uploadedAt));
        else
          result!.sort((a, b) => b.metadata.uploadedAt.compareTo(a.metadata.uploadedAt));
      } break;
      case 2: {
        if (columnIndex == sortColumnIndex) {
          sortAsc = sortOwnerAsc = sortAscending;
        } else {
          sortColumnIndex = columnIndex;
          sortAsc = sortOwnerAsc;
        }
        if (sortAscending)
          result!.sort((a, b) => a.owner.username.compareTo(b.owner.username));
        else
          result!.sort((a, b) => b.owner.username.compareTo(a.owner.username));
      } break;
      case 3: {
        if (columnIndex == sortColumnIndex) {
          sortAsc = sortSizeAsc = sortAscending;
        } else {
          sortColumnIndex = columnIndex;
          sortAsc = sortSizeAsc;
        }
        if (sortAscending)
          result!.sort((a, b) => a.metadata.fileSize.compareTo(b.metadata.fileSize));
        else
          result!.sort((a, b) => b.metadata.fileSize.compareTo(a.metadata.fileSize));
      } break;
      default: {
        return;
      }
    }
    notifyListeners();
  }
}
