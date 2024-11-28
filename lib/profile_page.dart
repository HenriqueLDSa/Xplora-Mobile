import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;

  final TextEditingController nameController =
      TextEditingController(text: "Henrique Lacerda");
  final TextEditingController emailController =
      TextEditingController(text: "henriquesa951@gmail.com");
  final TextEditingController passwordController =
      TextEditingController(text: "****************");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: FractionallySizedBox(
                  widthFactor: 0.7,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              bottom: 0,
                              right: 0,
                              child: IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.edit_square,
                                    size: 30, color: Color(0xFF9B4DFF)),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
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
                              side: BorderSide(
                                color: Color(0xFF6A0DAD),
                              ),
                            ),
                            child: Text(
                              isEditing ? "Save Changes" : "Edit Profile",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6A0DAD),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        SizedBox(height: 60),
                        isEditing
                            ? SizedBox(
                                width: 220,
                                child: TextField(
                                  controller: nameController,
                                  decoration:
                                      InputDecoration(labelText: "Name"),
                                ),
                              )
                            : Text(
                                nameController.text,
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                        SizedBox(height: 30),
                        isEditing
                            ? SizedBox(
                                width: 220,
                                child: TextField(
                                  controller: emailController,
                                  decoration:
                                      InputDecoration(labelText: "Email"),
                                ),
                              )
                            : Text(
                                emailController.text,
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                              ),
                        SizedBox(height: 30),
                        isEditing
                            ? SizedBox(
                                width: 220,
                                child: TextField(
                                  controller: passwordController,
                                  obscureText: true,
                                  decoration:
                                      InputDecoration(labelText: "Password"),
                                ),
                              )
                            : Text(
                                passwordController.text,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                              ),
                        SizedBox(height: 60),
                        SizedBox(
                          width: 150,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF6A0DAD),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
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
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
