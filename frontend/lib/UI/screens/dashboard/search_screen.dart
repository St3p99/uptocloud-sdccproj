import 'package:admin/UI/screens/dashboard/components/search_result_datatable_source.dart';
import 'package:admin/UI/screens/dashboard/components/shared_search_result_datatable_source.dart';
import 'package:admin/controllers/user_provider.dart';
import 'package:admin/support/extensions/string_capitalization.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../../../api/api_controller.dart';
import '../../../../models/document.dart';
import '../../constants.dart';
import '../../responsive.dart';
import 'components/feedback_dialog.dart';
import 'components/files_list.dart';
import 'components/header.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({
    Key? key,
    required this.input,
  }) : super(key: key);

  String? input;

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _textEditingController = TextEditingController();

  bool _searchInContent = false;
  late FocusNode _focusNode;

  String get _input => _textEditingController.text.trim();

  List<String> _tags = List.empty();
  List<String> _tagsSelected = List.empty(growable: true);
  List<String> _filesSuggestions = List.empty();
  List<String> _tagsSuggestions = List.empty();
  List<Document>? _searchResult;
  bool _searching = false;

  refreshState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _textEditingController.addListener(() => refreshState(() {}));
    if (widget.input != null && widget.input!.isNotEmpty) {
      _textEditingController.text = widget.input!;
      _search();
    }
    _initTagSuggestions();
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    _textEditingController.dispose();
  }

  _initTagSuggestions() async {
    List<String>? result = await new ApiController().getTagSuggestions();
    if (result != null)
      setState(() {
        _tags = result;
      });
    _filterTagSuggestions();
  }

  _search() async {
    setState(() {
      _searching = true;
    });

    List<Document>? result;
    if(_input.isEmpty && _tagsSelected.isNotEmpty)
      result = await new ApiController().searchByTags(_tagsSelected);
    else if (_input.isNotEmpty)
      result = await new ApiController()
        .search(_input, _tagsSelected, searchInContent: _searchInContent);
    else{
      setState(() {
        _searching = false;
      });
      return;
    }

    if (result != null) {
      result.forEach((file) {
        file.loadIcon();
      });
      setState(() {
        _searchResult = result;
      });
    } else {
      FeedbackDialog(
              type: CoolAlertType.error,
              context: context,
              title: "UNKNOWN ERROR",
              message: "")
          .show();
    }
    setState(() {
      _searching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            primary: false,
            padding: EdgeInsets.all(defaultPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Header(
                  title: 'search',
                ),
                SizedBox(height: defaultPadding),
                if (Responsive.isDesktop(context)) ...[
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Expanded(child: _tagsWidget()),
                  ]),
                  Row(children: [
                    Expanded(child: _formField()),
                    Padding(padding: EdgeInsets.only(right: defaultPadding/2)),
                    _searchButton(),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                    ),
                    Expanded(child: _displayTagSuggestions()),
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Expanded(
                      child: _switchSearchInContent(),
                    ),
                  ]),
                ] else ...[
                  _tagsWidget(),
                  Row(children: [
                    Expanded(child: _formField()),
                    Padding(padding: EdgeInsets.only(right: defaultPadding/2)),
                    _searchButton(),
                  ],),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: defaultPadding),
                  ),
                  _switchSearchInContent(),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: defaultPadding),
                  ),
                  _displayTagSuggestions()
                ],
                Padding(
                  padding: EdgeInsets.symmetric(vertical: defaultPadding),
                ),
                bottom()
              ],
            ),
          ),
        ),
      ),
    );
  }

  _searchButton(){
    return InkWell(
      child: Icon(
          Icons.search,
          color: primaryColor70
      ),
      onTap: () => _search(),
    );
  }

  _switchSearchInContent() {
    return Padding(
      padding: EdgeInsets.all(defaultPadding/2),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .05,
        child: Row(
          children: [
            Text(
              "Enable search in content",
            ),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * .02,
                child: CupertinoSwitch(
                  value: _searchInContent,
                  activeColor: primaryColor,
                  onChanged: (value) {
                    setState(() {
                      _searchInContent = value;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _formField() {
    return TypeAheadFormField(
      textFieldConfiguration: TextFieldConfiguration(
        onChanged: (String value) async {
          _autocomplete(value);
          _filterTagSuggestions();
        },
        onSubmitted: (value) => _search(),
        controller: _textEditingController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: 'Search',
          fillColor: secondaryColor,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
        ),
      ),
      suggestionsCallback: (text) async {
        return _autocomplete(text);
      },
      suggestionsBoxDecoration: SuggestionsBoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          shadowColor: Colors.white70,
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.3)),
      noItemsFoundBuilder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            'No Items Found!',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Theme.of(context).disabledColor,
                fontSize: Theme.of(context).textTheme.subtitle1!.fontSize),
          ),
        );
      },
      itemBuilder: (context, String suggestion) {
        return ListTile(
          title: Text(suggestion),
        );
      },
      onSuggestionSelected: (String suggestion) {
        _textEditingController.text = suggestion;
        _search();
      },
    );
  }

  Future<List<String>> _autocomplete(String text) async {
    if (text.isEmpty) return List.empty();
    List<String>? result = await new ApiController().autocomplete(text);
    setState(() {
      if (result != null)
        _filesSuggestions = result;
      else
        _filesSuggestions = List.empty();
    });
    return _filesSuggestions;
  }

  Widget bottom() {
    return _searching
        ? CircularProgressIndicator() // searching
        : _searchResult == null
            ? SizedBox.shrink()
            : _searchResult!.isEmpty
                ? noResult()
                : buildContent();
  }

  Widget noResult() {
    return Center(
        child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.10,
            width: MediaQuery.of(context).size.width * 0.10,
            child: Text("No result!")));
  }

  Widget buildContent() {
    List<Document> owned = List.empty(growable: true);
    List<Document> readable = List.empty(growable: true);
    _searchResult!.forEach((doc) {
      if (doc.owner == new UserProvider().currentUser!)
        owned.add(doc);
      else
        readable.add(doc);
    });
    return Column(
      children: [
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
                    title: "Find in My Files",
                    datasource: SearchResultDataTableSource(owned),
                    isOwner: true,
                  ),
                  SizedBox(height: defaultPadding),
                  FilesList(
                    title: "Find in Files Shared With Me",
                    datasource: SharedSearchResultDataTableSource(readable),
                    isOwner: false,
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _tagsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_tagsSelected.length > 0) ...[
          Wrap(
            alignment: WrapAlignment.start,
            children: _tagsSelected
                .map((tag) => tagChip(
                      tag: tag,
                      onTap: () => _removeTag(tag),
                      action: 'remove',
                    ))
                .toSet()
                .toList(),
          ),
        ] else
          SizedBox(),
      ],
    );
  }

  Widget tagChip({tag, onTap, action}) {
    return InkWell(
        onTap: onTap,
        hoverColor: Colors.white12,
        child: Stack(
          children: [
            Container(
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
                  color: secondaryColor,
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
            ),
            Positioned(
              right: 0,
              child: CircleAvatar(
                backgroundColor: primaryColor,
                radius: 8.0,
                child: Icon(
                  action == 'add' ? Icons.add : Icons.clear,
                  size: 10.0,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ));
  }

  _addTag(String tag) async {
    if (!_tagsSelected.contains(tag))
      setState(() {
        _tagsSelected.add(tag);
      });
  }

  _removeTag(String tag) async {
    if (_tagsSelected.contains(tag)) {
      setState(() {
        _tagsSelected.remove(tag);
      });
    }
  }

  _displayTagSuggestions() {
    return _tags.isNotEmpty
        ? _buildTagsSuggestionWidget()
        : Text('No Tags added');
  }

  void _filterTagSuggestions() {
    List<String> _tempList = [];
    for (int index = 0; _input.isNotEmpty && index < _tags.length; index++) {
      String tag = _tags[index];
      if (tag.toLowerCase().trim().contains(_input.toLowerCase())) {
        _tempList.add(tag);
      }
    }
    for (int index = 0; _tempList.length < 10 && index < _tags.length; index++) {
      String tag = _tags[index];
      if (!_tempList.contains(tag)) _tempList.add(tag);
    }
    setState(() {
      _tagsSuggestions = _tempList;
    });
  }

  Widget _buildTagsSuggestionWidget() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (_tagsSuggestions.length - _tagsSelected.length > 0) ...[
        Text(
          'Tag suggestions',
          style: Theme.of(context).textTheme.labelSmall,
        ),
        Padding(
          padding: EdgeInsets.only(bottom: defaultPadding),
        ),
        Wrap(
          alignment: WrapAlignment.start,
          children: _tagsSuggestions
              .where((tag) => !_tagsSelected.contains(tag))
              .map((tag) => tagChip(
                    tag: tag,
                    onTap: () {
                      _addTag(tag);
                    },
                    action: 'add',
                  ))
              .toList(),
        ),
      ]
    ]);
  }
}
