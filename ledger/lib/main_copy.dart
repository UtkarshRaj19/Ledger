import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beautiful Login Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoginButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    // Add listener to text controllers to check for changes in input fields
    _usernameController.addListener(_updateLoginButtonStatus);
    _passwordController.addListener(_updateLoginButtonStatus);
  }

  void _updateLoginButtonStatus() {
    // Check if both username and password fields have input
    bool isInputValid =
        _usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    // Update the state to enable or disable the login button
    setState(() {
      _isLoginButtonEnabled = isInputValid;
    });
  }

  @override
  void dispose() {
    // Dispose of text controllers to prevent memory leaks
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoginButtonEnabled) {
      const String apiUrl = 'https://wpoc2ga7ki.execute-api.ap-southeast-1.amazonaws.com/dev/v1/AdminLogin';

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          body: {
            'Username': _usernameController.text,
            'Password': _passwordController.text,
          },
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = json.decode(response.body);
          if (responseData['status'] == true){
            Fluttertoast.showToast(
              msg: "Login successful",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
          }
          else{
            Fluttertoast.showToast(
              msg: "Invalid Username/Password",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
          }
          } else {
          Fluttertoast.showToast(
              msg: "Some Error Occoured",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
        }
      } catch (e) {
        Fluttertoast.showToast(
              msg: "Server Error",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueAccent, Color.fromARGB(255, 11, 131, 119)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Username Input Field
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: 'Username',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Password Input Field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Login Button
ElevatedButton(
                onPressed: _isLoginButtonEnabled ? _handleLogin : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 30,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: _isLoginButtonEnabled
                      ? Colors.white // Enabled color
                      : Colors.white.withOpacity(0.5), // Disabled color
                  textStyle: const TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
