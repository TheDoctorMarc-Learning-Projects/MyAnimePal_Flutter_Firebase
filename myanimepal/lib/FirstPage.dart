import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:search_widget/search_widget.dart';
import 'DescriptionPage.dart';

class FirstPage extends StatefulWidget
{
  FirebaseUser user; 
  List<DocumentSnapshot> animeData, mangaData, aniMangaData;
  FirstPage({@required this.user, @required this.animeData, @required this.mangaData})
  {
    aniMangaData = animeData + mangaData; 
  }  

  @override
  FirstPageState createState() => FirstPageState();
}

class FirstPageState extends State<FirstPage>
{
  DocumentSnapshot selectedItem; 
  bool animes = true; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          title: Text(
            "Viewing " + widget.user.displayName + " MyAnimePal's",
            style: TextStyle(color: Colors.black, fontSize: 15),
          ),
          backgroundColor: Colors.white,
          actions: <Widget>[
            Image.network(
                "https://firebasestorage.googleapis.com/v0/b/myanimepal.appspot.com/o/MyAnimePalLogo.png?alt=media&token=57926b6e-1808-43c8-9d99-e4b5572ef93e")
          ],
        ),
        body: Column
        (
          children: <Widget>
          [
            searchBar(),
            SizedBox(height: 10),
            toggleAniMangaViewButton(),
            SizedBox(height: 10),
            (animes) ? animangaList("animes") : animangaList("mangas"),
          ]
        )
      ); 
  }

  searchBar()
  {
    return 
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
                return Container(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      item.documentID,
                      style: const TextStyle(fontSize: 16),
                    ));
              },
              selectedItemBuilder: (item, deleteSelectedItem) {
                return Container(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      item.documentID,
                      style: const TextStyle(fontSize: 16),
                    ));
              },

              // TODO: go to the anime specific page when clicked
              onItemSelected: (item) {
                setState(() {
                  selectedItem = item;
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          DescriptionPage(user: widget.user, aniManga: item)));
                });
              }); 
    
  }

  toggleAniMangaViewButton()
  {
    return FloatingActionButton
    (
       child: Text
       ("Toggle View",
        textAlign: TextAlign.center,
       ),
       onPressed: ()
       {
         setState(() {
           animes = !animes; 
         });
       },
    ); 

  }

  animangaList(String list)
  {
    return  StreamBuilder
        (
          stream: Firestore.instance.collection(list).snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot)
          {
            if(!snapshot.hasData)
            {
              return Center(child: CircularProgressIndicator());
            }
             return Flexible 
             (
                // TODO: this is just a test. display only X ammunt of animes and mangas,
                // separe them, add a button to see the  anime/ manga page
               child: ListView.builder
              (
                itemCount: (list == "animes") ? widget.animeData.length : widget.mangaData.length,
                itemBuilder: (context, index)
                {
                  Map<String, dynamic> data = (list == "animes") ? widget.animeData[index].data : widget.mangaData[index].data;
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
        ); 

  }
}
