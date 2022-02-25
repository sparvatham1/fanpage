import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fanpage/userlogin.dart';
import 'package:intl/intl.dart';
import 'package:fanpage/user_register.dart';

class Main_Screen extends StatefulWidget {
  const Main_Screen({Key? key}) : super(key: key);
  // Main_Screen(this.role);

  @override
  _Main_ScreenState createState() => _Main_ScreenState();
}

class _Main_ScreenState extends State<Main_Screen> {
  var _messageBody = "";
  var format = DateFormat("d/M/y hh:mm a");

  FirebaseAuth auth = FirebaseAuth.instance;

  CollectionReference messages =
  FirebaseFirestore.instance.collection("messages");

  final Stream<QuerySnapshot> _messageStream =
  FirebaseFirestore.instance.collection('messages').snapshots();

  String role = "";

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        // user is null
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const User_Register()));
      } else {
        // fetch user role
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get()
            .then((DocumentSnapshot documentSnapshot) {
          setState(() {
            role = documentSnapshot['role'];
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            backgroundColor: Colors.blue,
            centerTitle: true,
            title: role == ""
                ? null
                : role == "ADMIN"
                ? const Text('Admin Main Screen')
                : const Text("Customer Main Screen"),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text("Want to Logout?",
                              textAlign: TextAlign.center),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () =>
                              {Navigator.of(context).pop()},
                              child: const Text('No'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const User_Login()));
                              },
                              child: const Text('Yes'),
                            ),
                          ],
                        ));
                  },
                  child: const Icon(Icons.logout),
                ),
              )
            ],
            automaticallyImplyLeading: false),

        // body
        body: role == ""
            ? const Center(
          child: CircularProgressIndicator(
              strokeWidth: 4.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
        )
            : StreamBuilder<QuerySnapshot>(
          stream: _messageStream,
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text("Something not Working Properly");
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Please wait as it is Loading..");
            }

            if (snapshot.data!.docs.isEmpty) {
              return const Center(
                  child: Text(
                      'Message Section Empty. Please Tap on + button to start posting Messages'));
            }

            return ListView(
              children:
              snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;

                return Column(
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Text(format
                            .format(data['createdAt'].toDate())
                            .toString())),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(data['body']),
                        tileColor: Colors.yellow,
                      ),
                    ),
                  ],
                );
              }).toList(),
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: role == ""
            ? null
            : role == 'ADMIN'
            ? (Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: FloatingActionButton(
            onPressed: () {
              showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text(
                      'Type Message Here',
                      textAlign: TextAlign.center,
                    ),
                    content: TextFormField(
                      onChanged: (val) {
                        setState(() {
                          _messageBody = val;
                        });
                      },
                      decoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.red,
                              width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.yellow,
                              width: 2.0),
                        ),
                        hintText: 'type your message here...',
                      ),
                      minLines:
                      6, // any number you need (It works as the rows for the textarea)
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () =>
                        {Navigator.of(context).pop()},
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () => {
                          messages
                              .add({
                            "body": _messageBody,
                            "createdAt": DateTime.now(),
                          })
                              .then((value) =>
                          {Navigator.of(context).pop()})
                              .catchError((error) => {
                            print(
                                "error while posting message")
                          })
                        },
                        child: const Text('Send'),
                      ),
                    ],
                  ));
            },
            child: const Icon(Icons.add),
            backgroundColor: Colors.red,
          ),
        ))
            : null);
  }
}