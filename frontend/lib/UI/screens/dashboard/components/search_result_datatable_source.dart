import 'package:admin/UI/screens/dashboard/components/file_datatable_source.dart';
import 'package:admin/models/document.dart';

class SearchResultDataTableSource extends FileDataTableSource{

  SearchResultDataTableSource(this.result);

  @override
  List<Document>? result;

  @override
  Future<List<Document>>? pullData()  {
    notifyListeners();
    return Future.value(result!);
  }

}
