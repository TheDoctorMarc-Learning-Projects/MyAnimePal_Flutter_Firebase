import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:search_widget/search_widget.dart'; 

 _loadAniMangaData() async
 {
  QuerySnapshot animesSnapshot = await Firestore.instance.collection("animes").getDocuments();
  QuerySnapshot mangasSnapshot = await Firestore.instance.collection("mangas").getDocuments();
  return animesSnapshot.documents + mangasSnapshot.documents; 
 }

void main() async
{
  var aniMangaData = await _loadAniMangaData(); 
  runApp(MyAnimePal(aniMangaData: aniMangaData));
} 
 

class MyAnimePal extends StatelessWidget {

  List<DocumentSnapshot> aniMangaData; 
  MyAnimePal({this.aniMangaData}); 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Anime Pal',
      home: SingIn(aniMangaData: aniMangaData,)
     
    );
  }
}

class FirstPage extends StatefulWidget
{
  FirebaseUser user; 
  List<DocumentSnapshot> aniMangaData;
  FirstPage({@required this.user, @required this.aniMangaData}); // TODO: pass the user variable to the user list page

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
         title: Text("Viewing " + widget.user.displayName + " MyAnimePal's", style: TextStyle(color: Colors.black, fontSize: 15),),
          backgroundColor: Colors.white,
          actions: <Widget>
          [
            Image.network("https://firebasestorage.googleapis.com/v0/b/myanimepal.appspot.com/o/MyAnimePalLogo.png?alt=media&token=57926b6e-1808-43c8-9d99-e4b5572ef93e")
          ],
        ),
        body: Column
        (
          children: <Widget>
          [
            SearchWidget<DocumentSnapshot>
            (
              dataList: widget.aniMangaData,
              listContainerHeight: MediaQuery.of(context).size.height / 4,
              queryBuilder: (query, list) {
                return list
                    .where((item) => item.documentID
                        .toLowerCase()
                        .contains(query.toLowerCase()))
                    .toList();
              },

              popupListItemBuilder: (item) {
                return Container
                (
                  padding: const EdgeInsets.all(12),
                  child: Text
                  (
                  item.documentID,
                  style: const TextStyle(fontSize: 16),
                  )
                );
              },

              // TODO: go to the anime specific page when clicked

            ),
          StreamBuilder
        (
          stream: Firestore.instance.collection("animes").snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot)
          {
            if(!snapshot.hasData)
            {
              return Center(child: CircularProgressIndicator());
            }
             return Flexible 
             (
                // TODO: this is just a test. display only X ammount of animes and mangas,
                // separe them, add a button to see the  anime/ manga page
               child: ListView.builder
              (
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index)
                {
                  Map<String, dynamic> data = widget.aniMangaData[index].data;
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

              ),
             );
          },
        ),
          ]
        )
      ); 
  }

}

class SingIn extends StatefulWidget
{
  List<DocumentSnapshot> aniMangaData;
  SingIn ({this.aniMangaData}); 

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
         Navigator.of(context).push(MaterialPageRoute(builder: (context) => FirstPage(user: result.user, aniMangaData: widget.aniMangaData))); 
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
         Navigator.of(context).push(MaterialPageRoute(builder: (context) => FirstPage(user: newUser, aniMangaData: widget.aniMangaData))); 

      }
      catch(e)
      {

      }
    }
  }

  
}