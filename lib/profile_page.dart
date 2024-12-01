import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xplora/welcome.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _errorMessage = "";
  bool isEditing = false;

  final TextEditingController _newFirstNameController =
      TextEditingController(text: "");
  final TextEditingController _newLastNameController =
      TextEditingController(text: "");
  final TextEditingController _newEmailController =
      TextEditingController(text: "");
  final TextEditingController _currentPasswordController =
      TextEditingController(text: "");
  final TextEditingController _newPasswordController =
      TextEditingController(text: "");
  final TextEditingController _confirmNewPasswordController =
      TextEditingController(text: "");

  String? userIdText;
  String? firstNameText;
  String? lastNameText;
  String? emailText;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/default_profile.png',
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.edit_square,
                              size: 30, color: Color(0xFF9B4DFF)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 150,
                    child: OutlinedButton(
                      onPressed: () {
                        if (isEditing) {
                          _updateUserInfo();
                        }

                        setState(() {
                          isEditing = !isEditing;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(
                          color: Color(0xFF6A0DAD),
                        ),
                      ),
                      child: Text(
                        isEditing ? "Save Changes" : "Edit Profile",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6A0DAD),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: isEditing ? _buildEditingFields() : _buildProfileInfo(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () {
                    _logout(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A0DAD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditingFields() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 220,
            child: TextField(
              controller: _newFirstNameController,
              decoration: const InputDecoration(labelText: "First Name"),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 220,
            child: TextField(
              controller: _newLastNameController,
              decoration: const InputDecoration(labelText: "Last Name"),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 220,
            child: TextField(
              controller: _newEmailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 220,
            child: TextField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Current Password"),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 220,
            child: TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password"),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 220,
            child: TextField(
              controller: _confirmNewPasswordController,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: "Confirm New Password"),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$firstNameText $lastNameText',
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 50),
        Text(
          emailText ?? "No Email",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 50),
        const Text(
          "****************",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  void _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      userIdText = prefs.getString("userId");
      firstNameText = prefs.getString("firstName");
      lastNameText = prefs.getString("lastName");
      emailText = prefs.getString("email");
    });
  }

  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => WelcomePage()),
      (route) => false,
    );
  }

  Future<void> _updateUserInfo() async {
    bool passwordsMatch = _doesPasswordsMatch(
        _newPasswordController.text, _confirmNewPasswordController.text);
    if (!passwordsMatch) {
      Fluttertoast.showToast(
        msg: "Passwords must match",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    bool isNewPasswordValid = _validatePassword(_newPasswordController.text);
    if (!isNewPasswordValid) {
      Fluttertoast.showToast(
        msg: _errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    bool isPasswordCorrect =
        await _isCorrectPassword(_currentPasswordController.text);
    if (!isPasswordCorrect) {
      return;
    }

    String url = "https://xplora.fun/api/users/$userIdText";
    final response = await http.put(
      Uri.parse(url),
      body: jsonEncode({
        'first_name': _newFirstNameController.text,
        'last_name': _newLastNameController.text,
        'email': _newEmailController.text,
        'password': _newPasswordController.text,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    var jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      if (_newFirstNameController.text != "" &&
          _newLastNameController.text != "" &&
          _newEmailController.text != "") {
        final prefs = await SharedPreferences.getInstance();

        prefs.setString('firstName', _newFirstNameController.text);
        prefs.setString('lastName', _newLastNameController.text);
        prefs.setString('email', _newEmailController.text);

        setState(() {
          firstNameText = _newFirstNameController.text;
          lastNameText = _newLastNameController.text;
          emailText = _newEmailController.text;
        });
      }

      Fluttertoast.showToast(
        msg: jsonResponse['message'],
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
      );

      return;
    }

    Fluttertoast.showToast(
      msg: jsonResponse['error'],
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  Future<bool> _isCorrectPassword(String password) async {
    String url = "https://xplora.fun/api/users/$userIdText/password";
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'password': password}),
    );

    if (response.statusCode == 200) {
      return true;
    }

    var jsonResponse = json.decode(response.body);

    Fluttertoast.showToast(
        msg: jsonResponse['message'],
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white);

    return false;
  }

  bool _validatePassword(String password) {
    _errorMessage = '';

    if (password.length < 8) {
      _errorMessage += '• Password must be longer than 8 characters\n';
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      _errorMessage += '• Uppercase letter is missing\n';
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      _errorMessage += '• Lowercase letter is missing\n';
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      _errorMessage += '• Digit is missing\n';
    }

    if (!password.contains(RegExp(r'[!@#%^&*(),.?":{}|<>]'))) {
      _errorMessage += '• Special character is missing\n';
    }

    return _errorMessage.isEmpty;
  }

  bool _doesPasswordsMatch(String newPassword, String confirmPassword) {
    return newPassword == confirmPassword;
  }
}
