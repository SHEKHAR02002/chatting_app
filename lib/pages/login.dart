import 'package:chatting_app/models/usermodel.dart';
import 'package:chatting_app/pages/homepage.dart';
import 'package:chatting_app/pages/singup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController email1Controller = TextEditingController();
  TextEditingController password1Controller = TextEditingController();
  void check() {
    String email = email1Controller.text.trim();
    String pass1 = password1Controller.text.trim();

    if (email == "" || pass1 == "") {
      print("Filed is empty");
    } else {
      login(email, pass1);
    }
  }

  void login(String email, String pass1) async {
    UserCredential? Credential;
    try {
      Credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pass1);
    } on FirebaseAuthException catch (ex) {
      print(ex.code.toString());
    }

    if (Credential != null) {
      String uid = Credential.user!.uid;

      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      UserModel userModel =
          UserModel.fromMap(userData.data() as Map<String, dynamic>);
      print("login sucess");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(
                  userModel: userModel,
                  firebaseUser: Credential!.user!,
                )),
      );
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
              "Login",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              "Email",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: email1Controller,
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
            ElevatedButton(
                onPressed: () {
                  check();
                },
                child: const Text("Login")),
            InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SingUpPage()),
                  );
                },
                child: const Text(
                  "Not have account?click here",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )),
          ]),
        ),
      ),
    );
  }
}
