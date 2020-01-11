import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'FirstPage.dart';

class SingIn extends StatefulWidget {
  List<DocumentSnapshot> animeData, mangaData;
  SingIn({@required this.animeData, @required this.mangaData});

  @override
  SingInState createState() => SingInState();
}

class SingInState extends State<SingIn> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String email, password, name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Login to MyAnimePal",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          actions: <Widget>[
            Image.network(
                "https://firebasestorage.googleapis.com/v0/b/myanimepal.appspot.com/o/MyAnimePalLogo.png?alt=media&token=57926b6e-1808-43c8-9d99-e4b5572ef93e")
          ],
        ),
        body: Container(
            color: Color.fromARGB(255, 0, 0, 20),
            child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Text(
                        "MyAnimePal",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 48),
                      child: TextFormField(
                        validator: (input) {
                          if (input.isEmpty) {
                            return "Please try again";
                          }
                        },
                        onSaved: (input) {
                          email = input;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: "Enter your e-mail",
                          labelStyle: TextStyle(color: Colors.black),
                          icon: Icon(
                            Icons.email,
                            color: Colors.white,
                          ),
                        ),
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height / 30),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 48),
                      child: TextFormField(
                          validator: (input) {
                            if (input.isEmpty) {
                              return "Please try again";
                            }
                          },
                          onSaved: (input) {
                            password = input;
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: "Enter your password",
                            labelStyle: TextStyle(color: Colors.black),
                            icon: Icon(
                              Icons.vpn_key,
                              color: Colors.white,
                            ),
                          ),
                          style: TextStyle(fontSize: 20, color: Colors.black),
                          obscureText: true),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height / 30),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 48),
                      child: TextFormField(
                        validator: (input) {
                          if (input.isEmpty) {
                            return "Please try again";
                          }
                        },
                        onSaved: (input) {
                          name = input;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: "Enter your username",
                          labelStyle: TextStyle(color: Colors.black),
                          icon: Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                        ),
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height / 40),
                    RaisedButton(
                      onPressed: _signIn,
                      child: Text("Sign in"),
                    ),
                    RaisedButton(
                      onPressed: _signUp,
                      child: Text(
                        "Sign up",
                      ),
                    )
                  ],
                ))));
  }

  Future<void> _signIn() async {
    FormState state = formKey.currentState;
    if (state.validate()) {
      state.save();
      try {
        var result = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => FirstPage(
                user: result.user,
                animeData: widget.animeData,
                mangaData: widget.mangaData)));
      } catch (e) {
        log(e.toString());
      }
    }
  }

  Future<void> _signUp() async {
    FormState state = formKey.currentState;
    if (state.validate()) {
      state.save();
      try {
        var result = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        var info = UserUpdateInfo();
        info.displayName = name;
        await result.user.updateProfile(info);
        await result.user.reload();
        FirebaseUser newUser = await FirebaseAuth.instance.currentUser();
        await _addUserToDatabase(newUser);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => FirstPage(
                user: newUser,
                animeData: widget.animeData,
                mangaData: widget.mangaData)));
      } catch (e) {}
    }
  }

  _addUserToDatabase(FirebaseUser user) async {
    Firestore.instance
        .collection('users')
        .document(user.displayName)
        .collection('animes')
        .document("empty")
        .setData({"empty": "empty"});
    Firestore.instance
        .collection('users')
        .document(user.displayName)
        .collection('mangas')
        .document("empty")
        .setData({"empty": "empty"});
  }
}
