import 'package:admin/UI/screens/dashboard/components/shared_file_datatable_source.dart';
import 'package:admin/models/document.dart';

class SharedSearchResultDataTableSource extends SharedFileDataTableSource {

  SharedSearchResultDataTableSource(this.result);

  @override
  List<Document>? result;

  @override
  Future<List<Document>>? pullData()  {
    notifyListeners();
    return Future.value(result!);
  }


}
