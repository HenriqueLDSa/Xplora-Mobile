import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xplora/welcome.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
}
