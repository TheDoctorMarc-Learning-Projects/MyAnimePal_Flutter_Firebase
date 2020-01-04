import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() => runApp(MyAnimePal());

class MyAnimePal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Anime Pal',
      home: SingIn()
     
    );
  }
}

class FirstPage extends StatefulWidget
{
   FirstPage(); 

  @override
  FirstPageState createState() => FirstPageState();
}

class FirstPageState extends State<FirstPage>
{
 @override
  Widget build(BuildContext context) {
    return Scaffold (
        appBar: AppBar
        (
          title: Text("MyAnimePal"),
        ),
        body: StreamBuilder
        (
          stream: Firestore.instance.collection("animes").snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot)
          {
            if(!snapshot.hasData)
            {
              return Center(child: CircularProgressIndicator());
            }
             return ListView.builder
              (
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index)
                {
                  Map<String, dynamic> data = snapshot.data.documents[index].data; 
                  return Column
                  (
                    children: <Widget>
                      [
                        Image.network
                        (
                          data["ImagePath"]
                        ),
                        ListTile
                        (
                          title: Text(data["Genre"], textScaleFactor:  1.3,),
                          leading: Text("Mean Score: " + data["Mean Score"].toString(), textScaleFactor:  1.3,),
                        )
                      ],
                   
                    ); 
           
                },

              ); 
          },
        ),
      ); 
  }

}

class SingIn extends StatefulWidget
{
@override
  SingInState createState() => SingInState();
}


class SingInState extends State<SingIn>
{
  final GlobalKey<FormState> formKey = GlobalKey<FormState>(); 
  String email, password; 

 @override
  Widget build(BuildContext context) 
  {
     return Scaffold (
        appBar: AppBar
        (
          title: Text("Login to MyAnimePal"),
        ),
        body: Form
        (
          key: formKey,
          child: Column
        (
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>
          [
            TextFormField
            (
              validator: (input)
              {
                if(input.isEmpty)
                {
                  return "Please try again"; 
                }
              },
              onSaved: (input) {
                email = input; 
              },
              decoration: InputDecoration( labelText: "Enter your e-mail", hintText: "example@gmail.com"),
              style: TextStyle(fontSize: 20),
            ),

            TextFormField
            (
              validator: (input)
              {
                if(input.isEmpty)
                {
                  return "Please try again"; 
                }
              },
              onSaved: (input) {
                password = input; 
              },
              decoration: InputDecoration( labelText: "Enter your password"),
              style: TextStyle(fontSize: 20),
              obscureText: true
            ),

            RaisedButton
            (
              onPressed: _signIn,
              child: Text("Sign in"),
            )

          ],

        )
        )
     ); 

  }

  Future<void> _signIn() async
  {
    FormState state = formKey.currentState; 
    if(state.validate())
    {
      state.save();
      try
      {
         await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password:  password); 
         Navigator.of(context).push(MaterialPageRoute(builder: (context) => FirstPage())); 
      }
      catch(e)
      {

      }
    }
  }
  
}