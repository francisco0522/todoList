import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_core/amplify_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:todolist/todoList.dart';
import 'amplifyconfiguration.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // gives our app awareness about whether we are succesfully connected to AWS
  bool _amplifyConfigured = false;

  // Instantiate Amplify

  Amplify amplifyInstance = Amplify();

  // controllers for text input
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // sign status
  bool isSignUpComplete = false;
  bool isSignedIn = false;

  @override
  void initState() {
    super.initState();

    // amplify is configured on startup
    _configureAmplify();

  }

  @override
  void dispose() {
    // Clean up the controller
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  void _configureAmplify() async {
    if (!mounted) return;

    // configured the Auth Api
 

    AmplifyAuthCognito authPlugin = AmplifyAuthCognito();
    amplifyInstance.addPlugin(authPlugins: [authPlugin]);

    await amplifyInstance.configure(amplifyconfig);
    try {
      setState(() {
        _amplifyConfigured = true;
      });
    } catch (e) {
      print(e);
    }
  }


 // Register User, we pass the Login data (Username, Password and the options)
  Future<String> _registerUser(LoginData data) async {
    try {
      Map<String, dynamic> userAttributes = {
        "email": emailController.text,
      };
      SignUpResult res = await Amplify.Auth.signUp(
          username: data.name,
          password: data.password,
          options: CognitoSignUpOptions(userAttributes: userAttributes));
      setState(() {
        isSignUpComplete = res.isSignUpComplete;
        //if it is successful, just print Complete, if not, print Not Complete
        print("Sign up: " + (isSignUpComplete ? "Complete" : "Not Complete"));
      });
    } on AuthError catch (e) {
      print(e);
      return "Register Error: " + e.toString();
    }
  }

// SignIn User, we pass the Login data (Username, Password)
  Future<String> _signIn(LoginData data) async {
    try {
      SignInResult res = await Amplify.Auth.signIn(
        username: data.name,
        password: data.password,
      );
      setState(() {
        isSignedIn = res.isSignedIn;
      });
//if it is successful, go to TodoListPage
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  TodoListStatePage()),
          (Route<dynamic> route) => false);
    } on AuthError catch (e) {
      print(e);
      return 'Log In Error: ' + e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FlutterLogin(
          onLogin: _signIn,
          onSignup: _registerUser,
          onRecoverPassword: (_) => null,
          title: 'To-Do List'),
    );
  }
}
