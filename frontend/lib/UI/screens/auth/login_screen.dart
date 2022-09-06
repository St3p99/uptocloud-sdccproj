import 'package:admin/UI/constants.dart';
import 'package:admin/UI/screens/auth/signup_screen.dart';
import 'package:admin/support/extensions/string_capitalization.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import '../../../controllers/user_provider.dart';
import '../../../support/constants.dart';
import '../../../support/login_result.dart';
import '../../responsive.dart';
import '../dashboard/components/feedback_dialog.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginResult _loginResult;
  late LoginStatus _loginStatus;
  late String _email;
  late String _password;
  bool _obscureText = true;
  final _formKey = GlobalKey<FormState>();
  UserProvider userProvider = new UserProvider();

  @override
  void initState() {
    userProvider.addListener(() {
      _handleLoginStatus();
    });
    _handleLoginStatus();
    checkAutoLogIn(); // TODO: add future builder
    super.initState();
  }

  _handleLoginStatus() {
    setState(() {
      _loginStatus = userProvider.loginStatus;
    });
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          body: SafeArea(
              child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Theme(
                          data: Theme.of(context),
                          child: _buildContent(context)
                      ),
                      ]
                  )
              )
          )
      )
      ,
    );
  }

  _buildContent(BuildContext context) {
    return Container(
        width: Responsive.isDesktop(context)
            ? MediaQuery.of(context).size.width * 0.3
            : Responsive.isTablet(context)
            ? MediaQuery.of(context).size.width * 0.5
            : MediaQuery.of(context).size.width * 0.85,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: secondaryColor,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(defaultPadding * 2),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Login",
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleLarge,
                ),
                const SizedBox(
                  height: defaultPadding,
                ),
                Text(
                  "The safest site on the web for storing your data!",
                  style: Theme
                      .of(context)
                      .textTheme
                      .subtitle1,
                ),
                const SizedBox(height: defaultPadding),
                _buildForm(),
                const SizedBox(height: defaultPadding),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MaterialButton(
                      child: Text(
                        "Forget password? I'm sorry!",
                        style: Theme
                            .of(context)
                            .textTheme
                            .labelSmall,
                      ),
                      onPressed: () {},
                    ),
                    Padding(
                        padding: EdgeInsets.only(right: defaultPadding / 2)),
                    MaterialButton(
                      child: Text(
                        "Signup",
                        style: Theme
                            .of(context)
                            .textTheme
                            .labelLarge,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, SignupScreen.routeName);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: defaultPadding),
                GestureDetector(
                    onTap: () => _login(),
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      child: Material(
                        child: Center(
                          child: Text(
                            "Login",
                            style: Theme
                                .of(context)
                                .textTheme
                                .subtitle1,
                          ),
                        ),
                        elevation: 24,
                        color: primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32)),
                      ),
                    ))
              ],
            ),
          ),
        ));
  }

  _buildForm(){
    return Form(
      key: _formKey,
      child: Column(children: [
        TextFormField(
          decoration: InputDecoration(
            hintText: "Please write your email address",
            label: Text("email"),
            fillColor: secondaryColor,
            filled: true,
            border: OutlineInputBorder(
              borderRadius:
              const BorderRadius.all(Radius.circular(10)),
            ),
          ),
          validator: (value) => _validateEmail(value!),
          onSaved: (value) => _email = value!,
          onFieldSubmitted: (value) {
            // _email = value;
            _login();
          },
        ),
        const SizedBox(
          height: defaultPadding,
        ),
        TextFormField(
          obscureText: _obscureText,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: Icon(
                // Based on passwordVisible state choose the icon
                _obscureText
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: primaryColor,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
            label: Text("password"),
            hintText: "Please write your password",
            fillColor: secondaryColor,
            filled: true,
            border: OutlineInputBorder(
              borderRadius:
              const BorderRadius.all(Radius.circular(10)),
            ),
          ),
          validator: (value) => _validatePassword(value!),
          onSaved: (value) => _password = value!,
          onFieldSubmitted: (value) {
            // _password = value;
            _login();
          },

        ),
      ]),
    );
  }

  _validateEmail(String value) {
    if (DEBUG_MODE) return null;
    if (value.isEmpty) {
      return "* " +
          "Required";
    }
    else if (EmailValidator.validate(value))
      return null;
    else
      return "* " +
          "Enter a valid email";
  }

  _validatePassword(String value) {
    if (DEBUG_MODE) return null;
    if (value.isEmpty)
      return "* " +
          "Required";
    else if (value.length < 6)
      return "Password should be at least 6 characters";
    else if (value.length > 15)
      return "Password should not be greater than 25 characters";
    else
      return null;
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      print('password $_password');
      print('email $_email');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Processing Data'),
        duration: Duration(hours: 1),
      ));

      LoginResult loginResult = await userProvider.login(_email, _password);
      print(loginResult.name);
      setState(() {
        _loginResult = loginResult;
      });
      switch (_loginResult) {
        case LoginResult.logged:
          {}
          break;
        case LoginResult.error_wrong_credentials:
          {
            ScaffoldMessenger.of(context).clearSnackBars();
            FeedbackDialog(
                type: CoolAlertType.error,
                context: context, title: "Invalid credentials", message: "Verify your email and password and try again.").show();
          }
          break;
        default:
          {
            ScaffoldMessenger.of(context).clearSnackBars();
            FeedbackDialog(
                type: CoolAlertType.error,
                context: context, title: "UNKNOWN ERROR").show();
          }
          break;
      }
    }
  }

  void checkAutoLogIn() async {
    bool result = await userProvider.autoLogin();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Processing Data'),
      duration: Duration(hours: 1),
    ));
    if (result) print("AUTOLOGIN");
    else ScaffoldMessenger.of(context).clearSnackBars();
  }
}
