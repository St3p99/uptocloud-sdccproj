import 'package:admin/UI/screens/dashboard/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';

import '../../../../api/api_controller.dart';
import '../../../../controllers/menu_controller.dart';
import '../../../constants.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    Key? key,
  }) : super(key: key);

  @override
  _SearchFieldState createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {

  final TextEditingController _textEditingController = TextEditingController();

  String get _input => _textEditingController.text.trim();

  late List<String> _filesSuggestions = ["test1.pdf"];

  refreshState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _textEditingController.addListener(() => refreshState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadFormField<String>(
      textFieldConfiguration: TextFieldConfiguration(
        onChanged: (String value) async {
          if(value.isNotEmpty)
            _autocomplete(value);
        },
        onSubmitted: (value) =>
            Provider.of<MenuController>(context, listen: false).updateWidget(SearchScreen(input: value,)),
        controller: _textEditingController,
        autofocus: false,
        decoration: InputDecoration(
          labelText: 'Search',
          fillColor: secondaryColor,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
                Radius.circular(10)),
          ),
        ),
      ),
      suggestionsCallback: (text) async {
        if(text.isNotEmpty)
          return _autocomplete(text);
        else return List.empty();
      },
      suggestionsBoxDecoration: SuggestionsBoxDecoration(
          borderRadius:
          BorderRadius.all(Radius.circular(10)),
          shadowColor: Colors.white70,
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height*0.1)),
      noItemsFoundBuilder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            'No Items Found!',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Theme.of(context).disabledColor,
                fontSize: Theme.of(context)
                    .textTheme
                    .subtitle1!
                    .fontSize),
          ),
        );
      },
      itemBuilder: (context, String suggestion) {
        return ListTile(
          // leading: SvgPicture.asset(
          //   "icons/menu_profile.svg",
          //   color: Colors.white,
          //   height: 20,
          // ),
          title: Text(suggestion),
        );
      },
      onSuggestionSelected: (String suggestion) {
        _textEditingController.text = suggestion;
      },
    );
  }

  Future<List<String>> _autocomplete(String text) async{
    if(text.isEmpty) return List.empty();
    List<String>? result = await new ApiController().autocomplete(text);
    setState((){
      if(result!=null)
        _filesSuggestions = result;
      else
        _filesSuggestions = List.empty();
    });
    return _filesSuggestions;
  }

}