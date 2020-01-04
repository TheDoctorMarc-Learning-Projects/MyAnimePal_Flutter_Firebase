import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyAnimePal());

class MyAnimePal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Anime Pal',
      home: Scaffold
      (
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
      ),
    );
  }
}
