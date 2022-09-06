import 'dart:collection';

import 'package:admin/UI/responsive.dart';
import 'package:admin/UI/screens/dashboard/components/readers_list.dart';
import 'package:admin/api/api_controller.dart';
import 'package:admin/controllers/user_provider.dart';
import 'package:admin/support/extensions/string_capitalization.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart';

import '../../../../models/document.dart';
import '../../../../models/user.dart';
import '../../../constants.dart';
import 'feedback_dialog.dart';

class PopupShare extends StatefulWidget {
  PopupShare({
    Key? key,
    required this.file,
  }) : super(key: key);

  Document file;

  @override
  _PopupShareState createState() => _PopupShareState();
}

class _PopupShareState extends State<PopupShare> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _typeAheadController = TextEditingController();

  String get _input => _typeAheadController.text.trim();

  late List<User> _selectedUsers = List.empty(growable: true);

  HashSet<User> _suggestions = new HashSet();

  late FocusNode _focusNode;

  refreshState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  @override
  void initState() {
    _initSuggestions();
    super.initState();
    _focusNode = FocusNode();
    _typeAheadController.addListener(() => refreshState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    _typeAheadController.dispose();
  }

  void _initSuggestions() async{
    List<User>? result = await new ApiController().getShareSuggestions();
    if(result!=null)
      setState(() {_suggestions = HashSet.from(result);});
  }

  void _pushData() async {
    if(_selectedUsers.length <= 0){
      FeedbackDialog(
          type: CoolAlertType.error,
          context: context,
          title: "ERROR",
          message: "No users selected")
          .show();
      return;
  }
    Response? response =
        await new ApiController().addReaders(widget.file, _selectedUsers);
    switch (response!.statusCode) {
      case 200:
        {
          FeedbackDialog(
                  type: CoolAlertType.success,
                  context: context,
                  title: "SUCCESS",
                  message: "")
              .show().whenComplete(() => Navigator.pop(context));

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
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context),
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        scrollable: true,
        contentPadding: EdgeInsets.all(defaultPadding * 2),
        actionsPadding: EdgeInsets.all(defaultPadding * 2),
        backgroundColor: secondaryColor,
        content: Container(
            width: Responsive.shareDialogWidth(context),
            height: Responsive.shareDialogHeight(context),
            child: SingleChildScrollView(
                child: Center(
                    child: Form(
                        key: _formKey,
                        child: Column(children: [
                          Text(
                            "Share \"" + widget.file.name + "\"",
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: defaultPadding),
                          ),
                          if (_selectedUsers.length > 0) ...[
                            Wrap(
                              alignment: WrapAlignment.start,
                              children: _selectedUsers
                                  .map((user) => chip(
                                        user: user,
                                        onTap: () => _removeUser(user),
                                        action: 'remove',
                                      ))
                                  .toSet()
                                  .toList(),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(bottom: defaultPadding / 2),
                            ),
                          ] else
                            SizedBox(),
                          _formField(),
                          Padding(
                              padding: EdgeInsets.only(bottom: defaultPadding)),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    flex: 5,
                                    child: ReadersList(
                                        title: "People with reading access",
                                        document: widget.file))
                              ]),
                        ]))))),
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
                  Navigator.pop(context);
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
                child: Text("Confirm"),
              ),
            ),
          ])
        ],
      ),
    );
  }

  _formField(){
    return TypeAheadFormField(
      validator: (value) => _validateEmail(value!),
      textFieldConfiguration: TextFieldConfiguration(
        onChanged: (String value) async {
          if (_getSuggestions(value).isNotEmpty) return;
          if (_validateEmail(value) == null) {
            User? user = await _getUser(value);
            if (user != null) _suggestions.add(user);
          }
        },
        onSubmitted: (String value) async {
          if (_formKey.currentState!.validate() &&
              _suggestions.isNotEmpty) {
            _addUser(_getSuggestions(value).first);
            _typeAheadController.clear();
          }
        },
        controller: _typeAheadController,
        focusNode: _focusNode,
        autofocus: true,
        decoration: InputDecoration(
          labelText: 'Add users',
          fillColor: secondaryColor,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
                Radius.circular(10)),
          ),
        ),
      ),
      suggestionsCallback: (pattern) async {
        return _getSuggestions(pattern);
      },
      suggestionsBoxDecoration: SuggestionsBoxDecoration(
          borderRadius:
          BorderRadius.all(Radius.circular(10)),
          shadowColor: Colors.white70,
          constraints: BoxConstraints(
              maxHeight:
              Responsive.shareDialogHeight(context) *
                  5 /
                  4)),
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
      itemBuilder: (context, User suggestion) {
        return ListTile(
          leading: SvgPicture.asset(
            "assets/icons/menu_profile.svg",
            color: Colors.white,
            height: 20,
          ),
          title: Text(suggestion.username.capitalize),
          subtitle: Text(
            suggestion.email.toLowerCase(),
            style: Theme.of(context)
                .textTheme
                .subtitle1!
                .copyWith(color: Colors.white54),
          ),
        );
      },
      onSuggestionSelected: (User suggestion) {
        _addUser(suggestion);
        _typeAheadController.clear();
      },
    );
  }

  _validateEmail(String? value) {
    return value != null && EmailValidator.validate(value)
        ? null
        : "* " +
            "Enter a valid email";
  }

  Future<User?> _getUser(String email) async {
    if(new UserProvider().currentUser!.email == email) return null;
    User fakeUser = new User(id: "", username: "", email: email);
    if (_suggestions.contains(fakeUser))
      return Future.value(_suggestions.lookup(fakeUser));
    else
      return await new ApiController().searchUserByEmail(email);
    // TODO: aggiustare searchUserByEmailContains
  }

  HashSet<User> _getSuggestions(String pattern) {
    if (_input.isEmpty) return _suggestions;

    HashSet<User> _tempList = new HashSet();
    _suggestions.forEach((element) {
      String username = element.username;
      String email = element.email;
      if (email.toLowerCase().trim().contains(_input.toLowerCase()) ||
          username.toLowerCase().trim().contains(_input.toLowerCase())) {
        _tempList.add(element);
      }
    });
    return _tempList;
  }

  Widget chip({required User user, required onTap, required action}) {
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
                  user.email,
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

  _addUser(User user) async {
    if (!_selectedUsers.contains(user))
      setState(() {
        _selectedUsers.add(user);
      });
  }

  _removeUser(User user) async {
    if (_selectedUsers.contains(user)) {
      setState(() {
        _selectedUsers.remove(user);
      });
    }
  }
}
