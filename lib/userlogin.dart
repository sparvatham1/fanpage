import 'package:fanpage/user_register.dart';
import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fanpage/mainscreen.dart';
import 'package:fanpage/userlogin.dart';
import 'package:fanpage/splash.dart';

class User_Register extends StatelessWidget {
  const User_Register({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Fanpage",
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.yellow,
          title: const Text("Fanpage User_Register"),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: const User_Register_Form(),
      ),
    );
  }
}

class User_Register_Form extends StatefulWidget {
  const User_Register_Form({Key? key}) : super(key: key);

  @override
  _User_Register_FormState createState() => _User_Register_FormState();
}

class _User_Register_FormState extends State<User_Register_Form> {
  final _formKey = GlobalKey<FormState>();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  var _email = "";
  var _password = "";
  var _firstName = "";
  var _lastName = "";
  var _role = "CUSTOMER";
  var userCredentialsObj;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical:1.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // text field for first name
                TextFormField(
                  decoration: const InputDecoration(hintText: "First Name"),
                  textAlign: TextAlign.start,
                  keyboardType: TextInputType.text,

                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                  onChanged: (val) {
                    setState(() {
                      _firstName = val;
                    });
                  },
                ),

                // text field for last name
                TextFormField(
                  decoration: const InputDecoration(hintText: "Last Name"),
                  textAlign: TextAlign.start,

                  keyboardType: TextInputType.text,

                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                  onChanged: (val) {
                    setState(() {
                      _lastName = val;
                    });
                  },
                ),

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
                      _email = val;
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
                      _password = val;
                    });
                  },
                ),

                // this is padding for register button
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all(Colors.red)),
                    onPressed: () async {
                      // Validate returns true if the form is valid, or false otherwise.
                      if (_formKey.currentState!.validate()) {
                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Logging you In...")),
                        );

                        // call the firebase function
                        try {
                          UserCredential userCredential = await FirebaseAuth
                              .instance
                              .createUserWithEmailAndPassword(
                              email: _email, password: _password);

                          userCredentialsObj = userCredential;
                        } on FirebaseAuthException catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "Failed with error code: ${e.code} | error message: ${e.message}"),
                          ));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("error occurred $e"),
                          ));
                        }
                        CollectionReference users =
                        FirebaseFirestore.instance.collection("users");

                        users
                            .doc(userCredentialsObj.user!.uid)
                            .set({
                          'firstName': _firstName,
                          'lastName': _lastName,
                          'email': _email,
                          'password': _password,
                          'role': _role,
                        })
                            .then((value) => {
                          showDialog<String>(
                              context: context,
                              builder: (BuildContext context) =>
                                  AlertDialog(
                                    title: const Text('Congratulations'),
                                    content: const Text(
                                        'Your Credentials are Registered Successfully.'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () => {
                                          // finally navigate after login
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Main_Screen()))
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ))
                        })
                            .catchError((error) => {
                          showDialog<String>(
                              context: context,
                              builder: (BuildContext context) =>
                                  AlertDialog(
                                    title:
                                    const Text('Error Occurred!'),
                                    content: const Text(
                                        'Error in saving your data to firestore. Please try again.'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () => {
                                          // finally navigate after login
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                  const SplashScreen()))
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ))
                        });
                      }
                    },
                    child: const Text('Register'),
                  ),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const User_Login()));
                  },
                  child: const Text("Click Here if Already Registered!",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.red,
                      )),
                ),

                Text(_email),
                Text(_password),
              ],
            ),
          ),
        ),
      ),
    );
  }
}