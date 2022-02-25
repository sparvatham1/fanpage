import 'package:fanpage/userlogin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fanpage/mainscreen.dart';
import 'package:fanpage/user_register.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_button/sign_button.dart';

class User_Login extends StatefulWidget {
  const User_Login({Key? key}) : super(key: key);

  @override
  _User_LoginState createState() => _User_LoginState();
}

class _User_LoginState extends State<User_Login> {
  final _formKey = GlobalKey<FormState>();

  var _email = "";
  var _password = "";
  var userCredentialsObj;
  var _role = "";

  // create firebae instance
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference users = FirebaseFirestore.instance.collection("users");
  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    // Once signed in, return the UserCredential
    //_role="CUSTOMER";
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("FanPage Login"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 150.0, horizontal: 30.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // text field for email
                TextFormField(
                  decoration: const InputDecoration(hintText: "Email"),
                  textAlign: TextAlign.start,
                  keyboardType: TextInputType.emailAddress,

                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                  onChanged: (val) {
                    setState(() {
                      _email = val.trim();
                    });
                  },
                ),

                // text field for password
                TextFormField(
                  decoration: const InputDecoration(hintText: "Password"),
                  textAlign: TextAlign.start,

                  obscureText: true,
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },

                  onChanged: (val) {
                    setState(() {
                      _password = val.trim();
                    });
                  },
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all(Colors.red),
                    ),
                    onPressed: () async {
                      // Validate returns true if the form is valid, or false otherwise.
                      // print(_formKey.currentState);
                      if (_formKey.currentState!.validate()) {
                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("please wait while we check ur entry..")),
                        );

                        // signin with email and password using firebase APIs
                        try {
                          UserCredential userCredential = await FirebaseAuth
                              .instance
                              .signInWithEmailAndPassword(
                              email: _email, password: _password);

                          userCredentialsObj = userCredential;
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'user-not-found') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                  Text("There is no User by this Email")),
                            );
                          } else if (e.code == 'wrong-password') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Password is Wrong... Try Again")),
                            );
                          }
                        }

                        // check if user is ADMIN OR CUSTOMER
                        FirebaseFirestore.instance
                            .collection('users')
                            .where('email', isEqualTo: _email)
                            .get()
                            .then((QuerySnapshot querySnapshot) {
                          for (var i = 0; i < querySnapshot.docs.length; i++) {
                            var doc = querySnapshot.docs[i];

                            //Finding Admin
                            if (doc["role"].toString() == "ADMIN") {
                              _role = doc["role"].toString();
                              break;
                            }
                          }

                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) =>const Main_Screen()));
                        });
                      }
                    },
                    child: const Text('Log In'),
                  ),
                ),
                SignInButton(buttonType: ButtonType.google,
                    onPressed: () {signInWithGoogle();
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const Main_Screen()));}
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const User_Register()));
                  },
                  child: const Text("Click here to Register",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.red,
                      )),
                )
              ],
            ),
          )),
    );
  }
}