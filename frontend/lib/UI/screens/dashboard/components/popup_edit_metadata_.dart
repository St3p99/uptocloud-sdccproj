import 'package:admin/UI/responsive.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../../../../api/api_controller.dart';
import '../../../../models/document.dart';
import '../../../constants.dart';
import 'feedback_dialog.dart';

class PopupEditMetadata extends StatefulWidget {
  PopupEditMetadata({
    Key? key,
    required this.file,
  }) : super(key: key);

  Document file;

  @override
  _PopupEditMetadataState createState() => _PopupEditMetadataState();
}

class _PopupEditMetadataState extends State<PopupEditMetadata> {
  final _formKey = GlobalKey<FormState>();
  late FocusNode _focusNode;
  final TextEditingController _tagsEditingController = TextEditingController();

  String get _inputTags => _tagsEditingController.text.trim();

  late String _filename;
  late String _description;
  late List<String> _tagsSelected = List.empty(growable: true);
  List<String> _tags = List.empty();
  List<String> _tagsSuggestions = List.empty(growable: true);

  refreshState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _initTagSuggestions();
    setState(() {
      _filename = widget.file.name;
      if (widget.file.metadata.description != null)
        _description = widget.file.metadata.description!;
      else
        _description = "";
      print(_description);
      if (widget.file.metadata.tags != null)
        _tagsSelected = widget.file.metadata.tags!;
      else
        _tagsSelected = List.empty(growable: true);
    });
    _focusNode = FocusNode();
    _tagsEditingController.addListener(() => refreshState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    _tagsEditingController.dispose();
  }

  _initTagSuggestions() async {
    List<String>? result = await new ApiController().getTagSuggestions();
    if (result != null)
      setState(() {
        _tags = result;
      });
    _filterTagSuggestions();
  }

  void _pushData() async {
    _formKey.currentState!.save();
    Response? response = await new ApiController()
        .setMetadata(widget.file.id, _filename, _description, _tagsSelected);
    switch (response!.statusCode) {
      case 200:
        {
          FeedbackDialog(
                  type: CoolAlertType.success,
                  context: context,
                  title: "SUCCESS",
                  message: "")
              .show()
              .whenComplete(() => Navigator.pop(context));
        }
        break;
      default:
        {
          FeedbackDialog(
                  type: CoolAlertType.error,
                  context: context,
                  title: "UNKNOWN ERROR",
                  message: "Try to remove special characters or diacritics")
              .show();
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context),
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        backgroundColor: secondaryColor,
        scrollable: true,
        contentPadding: EdgeInsets.all(defaultPadding * 2),
        actionsPadding: EdgeInsets.all(defaultPadding * 2),
        content: Container(
          width: Responsive.metadataDialogWidth(context),
          height: Responsive.metadataDialogHeight(context),
          child: SingleChildScrollView(
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(children: [
                  Text(
                    "Edit Metadata",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: defaultPadding)),
                  TextFormField(
                    keyboardType: TextInputType.name,
                    initialValue: widget.file.name,
                    decoration: InputDecoration(
                      label: Text("Name"),
                      fillColor: secondaryColor,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    onSaved: (value) => _filename = value!,
                    onFieldSubmitted: (value) {
                      _pushData();
                    },
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: defaultPadding)),
                  TextFormField(
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 3,
                    maxLength: 250,
                    initialValue: widget.file.metadata.description,
                    decoration: InputDecoration(
                      hintText: "Lorem ipsum...",
                      label: Text("Description"),
                      fillColor: secondaryColor,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    onSaved: (value) => _description = value!,
                    onFieldSubmitted: (value) {
                      _pushData();
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: defaultPadding),
                  ),
                  _tagsWidget()
                ]),
              ),
            ),
          ),
        ),
        actions: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            ButtonTheme(
              minWidth: 25.0,
              height: 25.0,
              child: ElevatedButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: defaultPadding * 1.5,
                    vertical:
                        defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Close"),
              ),
            ),
            ButtonTheme(
              minWidth: 25.0,
              height: 25.0,
              child: ElevatedButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: defaultPadding * 1.5,
                    vertical:
                        defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
                  ),
                ),
                onPressed: () {
                  _pushData();
                },
                child: Text("Save"),
              ),
            ),
          ])
        ],
      ),
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
          Padding(
            padding: EdgeInsets.only(bottom: defaultPadding / 2),
          ),
        ] else
          SizedBox(),
        _tagsTextField(),
        Padding(
          padding: EdgeInsets.only(bottom: defaultPadding / 2),
        ),
        _displayTagSuggestions(),
      ],
    );
  }

  Widget _tagsTextField() {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              focusNode: _focusNode,
              controller: _tagsEditingController,
              decoration: InputDecoration(
                hintText: "Add Tags",
                label: Text("Tags"),
                fillColor: secondaryColor,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
              ),
              validator: (value) => _validateTag(value!),
              onChanged: (String value) async {
                _filterTagSuggestions();
              },
              onFieldSubmitted: (value) {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  _addTag(value);
                  _tagsEditingController.clear();
                  _focusNode.requestFocus();
                }
              },
              textInputAction: TextInputAction.search,
            ),
          ),
          if (_inputTags.isNotEmpty) ...[
            Padding(padding: EdgeInsets.only(right: defaultPadding)),
            InkWell(
              child: Icon(Icons.clear, color: primaryColor70),
              onTap: () => _tagsEditingController.clear(),
            )
          ],
        ],
      ),
    );
  }

  Widget tagChip({tag, onTap, action}) {
    return InkWell(
        onTap: onTap,
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
                  color: primaryColor70,
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

  _validateTag(String tag) {
    final RegExp validCharacters = RegExp(r'^[a-zA-Z0-9]+$');
    if (tag.isEmpty)
      return "Empty value";
    else if (tag.split(" ").length > 1)
      return "Name tag should be one word";
    else if (!validCharacters.hasMatch(tag))
      return "Name tag may only contain only letters and numbers.";
    else
      return null;
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
    for (int index = 0;
        _inputTags.isNotEmpty && index < _tags.length;
        index++) {
      String tag = _tags[index];
      if (tag.toLowerCase().trim().contains(_inputTags.toLowerCase())) {
        _tempList.add(tag);
      }
    }
    for (int index = 0;
        _tempList.length < 10 && index < _tags.length;
        index++) {
      String tag = _tags[index];
      if (!_tempList.contains(tag)) _tempList.add(tag);
    }
    setState(() {
      _tagsSuggestions = _tempList;
    });
  }

  Widget _buildTagsSuggestionWidget() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (_tagsSuggestions.length > 0) ...[
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
                      _tagsEditingController.clear();
                    },
                    action: 'add',
                  ))
              .toList(),
        ),
      ]
    ]);
  }
}
