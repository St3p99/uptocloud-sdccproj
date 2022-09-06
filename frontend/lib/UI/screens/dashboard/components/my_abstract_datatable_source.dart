import 'dart:collection';

import 'package:admin/models/document.dart';
import 'package:flutter/material.dart';


abstract class MyAbstractDataTableSource extends DataTableSource{
  List<Document>? result;
  HashSet<int> selectedFiles = new HashSet();
  bool sortAsc = true;
  int sortColumnIndex = 0;

  Future<List<Document>>? pullData();

  onSelected(int index, bool isSelected);

  void sort(int columnIndex, bool sortAscending);

  Document getSelectedFile() {
    assert(selectedFiles.length==1);
    return result!.elementAt(selectedFiles.first);
  }

  List<Document> getSelectedFiles() {
    return List.generate(selectedFiles.length, (index) => result!.elementAt(index));
  }
}