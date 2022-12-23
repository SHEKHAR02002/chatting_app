import 'package:chatting_app/models/usermodel.dart';
import 'package:chatting_app/pages/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SingUpPage extends StatefulWidget {
  const SingUpPage({super.key});

  @override
  State<SingUpPage> createState() => _SingUpPageState();
}

class _SingUpPageState extends State<SingUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController password1Controller = TextEditingController();
  TextEditingController password2Controller = TextEditingController();
  TextEditingController nameController = TextEditingController();

  void checkValues() {
    String email = emailController.text.trim();
    String pass1 = password1Controller.text.trim();
    String pass2 = password2Controller.text.trim();
    String name = nameController.text.trim();

    if (email == "" || pass1 == "" || pass2 == "" || name == "") {
      print("Filed is empty");
    } else if (pass1 != pass2) {
      print("Password is not match");
    } else {
      singup(email, pass1, name);
    }
  }

  void singup(String email, String password, String name) async {
    UserCredential? Credential;
    try {
      Credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      print(ex.code.toString());
    }

    if (Credential != null) {
      String uid = Credential.user!.uid;
      UserModel newUser = UserModel(uid, name, email);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(newUser.toMap())
          .then((value) {
        print("User added");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: SingleChildScrollView(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text(
            "Sing Up",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            "Email",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: "Email"),
          ),
          const Text(
            "Password",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: password1Controller,
            decoration: const InputDecoration(labelText: "password"),
          ),
          const Text(
            "confirm Password",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            controller: password2Controller,
            decoration: const InputDecoration(labelText: "confirm password"),
          ),
          const Text(
            "Full Name",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Enter Name"),
          ),
          ElevatedButton(
              onPressed: () {
                checkValues();
              },
              child: const Text("Singup")),
          InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text(
                "have account?click here",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )),
        ]),
      ),
    ));
  }
}
