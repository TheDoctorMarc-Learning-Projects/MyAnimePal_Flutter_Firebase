import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'LoginPage.dart'; 


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
