import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../api/api_controller.dart';
import '../../../../models/user.dart';
import '../../../constants.dart';

class ReadersDataTableSource extends DataTableSource{
  ApiController api = new ApiController();
  List<User>? result;
  HashSet<int> selectedUsers = new HashSet();
  bool sortAsc = true;
  int sortColumnIndex = 0;

  bool sortNameAsc = true;
  bool sortDateAsc = true;
  bool sortSizeAsc = true;
  @override
  DataRow? getRow(int index) {
    User reader = result!.elementAt(index);
    return DataRow(
      selected: selectedUsers.contains(index),
      onSelectChanged: (isSelected) {
        onSelected(index, isSelected!);
        notifyListeners();
      },
      cells: [
        DataCell(
          Container(
            constraints: BoxConstraints(minWidth: 100),
            child: Row(
              children: [
                SvgPicture.asset(
                  "icons/menu_profile.svg",
                  height: 20, color: Colors.white,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: Text(reader.username),
                ),
              ],
            ),
          ),
        ),
        DataCell(Container(
            constraints: BoxConstraints(minWidth: 200),
            child: Text(reader.email))),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => result!.length;

  @override
  int get selectedRowCount => selectedUsers.length;


  onSelected(int index, bool isSelected){
    if (isSelected) {
      selectedUsers.add(index);
    } else {
      selectedUsers.remove(index);
    }
  }

  Future<List<User>>? pullData(int docID) async {
    result = await api.getReadersByDoc(docID);
    return result!;
  }

  User getSelectedUser() {
    assert(selectedUsers.length==1);
    return result!.elementAt(selectedUsers.first);
  }

  List<User> getSelectedUsers() {
    return List.generate(selectedUsers.length, (index) => result!.elementAt(index));
  }
}