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
  FirebaseUser user; 
  FirstPage({@required this.user}); 

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
         title: Text("Viewing " + widget.user.displayName + "'s MyAnimePal", style: TextStyle(color: Colors.black, fontSize: 15),),
          backgroundColor: Colors.white,
          actions: <Widget>
          [
            Image.network("https://firebasestorage.googleapis.com/v0/b/myanimepal.appspot.com/o/MyAnimePalLogo.png?alt=media&token=57926b6e-1808-43c8-9d99-e4b5572ef93e")
          ],
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
  String email, password, name; 

 @override
  Widget build(BuildContext context) 
  {
     return Scaffold (
        appBar: AppBar
        (
          title: Text("Login to MyAnimePal", style: TextStyle(color: Colors.black),),
          backgroundColor: Colors.white,
          actions: <Widget>
          [
            Image.network("https://firebasestorage.googleapis.com/v0/b/myanimepal.appspot.com/o/MyAnimePalLogo.png?alt=media&token=57926b6e-1808-43c8-9d99-e4b5572ef93e")
          ],
        ),
        body: Container
        (
          color: Color.fromARGB(255, 0, 0, 20),
          child: Form
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
              decoration: InputDecoration(filled: true, fillColor: Colors.white, labelText: "Enter your e-mail",
              labelStyle: TextStyle(color: Colors.black)),
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),

             SizedBox(height: MediaQuery.of(context).size.height / 30),

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
              decoration: InputDecoration(filled: true, fillColor: Colors.white, labelText: "Enter your password",
              labelStyle: TextStyle(color: Colors.black)),
              style: TextStyle(fontSize: 20, color: Colors.black),
              obscureText: true
            ),

             SizedBox(height: MediaQuery.of(context).size.height / 30),

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
                name = input; 
              },
              decoration: InputDecoration(filled: true, fillColor: Colors.white, labelText: "Enter your username",
              labelStyle: TextStyle(color: Colors.black)),
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),

             SizedBox(height: MediaQuery.of(context).size.height / 40),

            RaisedButton
            (
              onPressed: _signIn,
              child: Text("Sign in"),
            ),

            
            RaisedButton
            (
              onPressed: _signUp,
              child: Text("Sign up",),
            )


          ],

        )
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
         var result = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password:  password);
         Navigator.of(context).push(MaterialPageRoute(builder: (context) => FirstPage(user: result.user))); 
      }
      catch(e)
      {

      }
    }
  }

Future<void> _signUp() async
  {
    FormState state = formKey.currentState; 
    if(state.validate())
    {
      state.save();
      try
      {
         var result  = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password:  password); 
         var info = UserUpdateInfo(); 
         info.displayName = name; 
         await result.user.updateProfile(info); 
         await result.user.reload();
         FirebaseUser newUser = await FirebaseAuth.instance.currentUser(); 
         await _addUserToDatabase(newUser); 
         Navigator.of(context).push(MaterialPageRoute(builder: (context) => FirstPage(user: newUser))); 

      }
      catch(e)
      {

      }
    }
  }


_addUserToDatabase(FirebaseUser user) async 
{
  Firestore.instance.collection('users').document(user.displayName).collection('animes').document("empty").setData({"empty" : "empty"});
  Firestore.instance.collection('users').document(user.displayName).collection('mangas').document("empty").setData({"empty" : "empty"});
}
  
}

